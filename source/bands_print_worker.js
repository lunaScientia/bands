// Node for Max: bounded file processing. No network, npm or Live API here.
'use strict';
const fs = require('fs');
const path = require('path');
const NAMES = ['Ultra Low', 'Sub', 'Bass', 'Mids', 'High-Mids', 'Presence', 'High', 'Ultra High'];
const CHANNELS = 17; // eight stereo bands, then the sample-synchronous host beat phase
const BLOCK = 8192;
const MAX_BYTES = 3 * 1024 ** 3;

function nativePath(s) {
    s = String(s || '');
    // Max's macOS path convention: "Macintosh HD:/path/to/file".
    if (process.platform === 'darwin' && /^[^/:]+:\//.test(s)) {
        const colon = s.indexOf(':');
        const relative = s.slice(colon + 1);
        const volume = '/Volumes/' + s.slice(0, colon) + relative;
        return fs.existsSync(volume) ? volume : relative;
    }
    return s;
}
function safeName(s) {
    return String(s).replace(/[\x00-\x1f<>:"/\\|?*]/g, '_').replace(/[. ]+$/g, '').slice(0, 70) || 'Reference';
}
function ranges(edges, rate) {
    const cuts = edges.map(f => Math.min(f, rate * .49));
    return NAMES.map((name, i) => name + ' ' + (i ? cuts[i - 1] : 0) + '-' + (i < 7 ? cuts[i] : rate / 2) + ' Hz');
}
function prepare(config) {
    if (!Number.isFinite(config.rate) || config.rate < 22050 || config.rate > 384000 ||
        !Number.isFinite(config.start) || config.start < 0 || !Number.isFinite(config.length) || config.length <= 0 ||
        !Number.isFinite(config.preStart) || config.preStart < 0 || config.preStart > config.start || config.preStart % 1 ||
        !Array.isArray(config.edges) || config.edges.length !== 7 ||
        config.edges.some((f, i) => !Number.isFinite(f) || f <= 0 || (i && f <= config.edges[i - 1]))) {
        throw Error('Invalid print range, sample rate or crossovers.');
    }
    let base = nativePath(config.folder);
    if (!base && config.setPath) base = path.join(path.dirname(nativePath(config.setPath)), 'Samples', 'Processed', 'BANDS');
    if (!path.isAbsolute(base)) throw Error('Choose an output folder first.');
    fs.mkdirSync(base, {recursive: true});
    const folder = fs.mkdtempSync(path.join(base, 'BANDS-' + safeName(config.reference) + '-'));
    const labels = ranges(config.edges, config.rate);
    const files = labels.map((label, i) => path.join(folder, String(i + 1).padStart(2, '0') + ' ' + safeName(label) + '.wav'));
    const job = {...config, folder, labels, files, raw: path.join(folder, '.capture.wav')};
    fs.writeFileSync(path.join(folder, 'print.json'), JSON.stringify({version: '1.3.0', ...config, labels}, null, 2));
    return job;
}
function readExactly(fd, length, position) {
    const b = Buffer.alloc(length);
    let n = 0;
    while (n < length) {
        const got = fs.readSync(fd, b, n, length - n, position + n);
        if (!got) throw Error('Incomplete capture file.');
        n += got;
    }
    return b;
}
function waveInfo(fd, pcm = false) {
    const size = fs.fstatSync(fd).size;
    const head = readExactly(fd, 12, 0);
    if (head.toString('ascii', 0, 4) !== 'RIFF' || head.toString('ascii', 8) !== 'WAVE') throw Error('Capture is not a WAV file.');
    let fmt, data;
    for (let p = 12; p + 8 <= size;) {
        const h = readExactly(fd, 8, p), tag = h.toString('ascii', 0, 4), n = h.readUInt32LE(4);
        if (p + 8 + n > size) throw Error('Capture is still being written or disk is full.');
        if (tag === 'fmt ') {
            if (n < 16 || n > 4096) throw Error('Invalid WAV format.');
            const b = readExactly(fd, n, p + 8);
            let format = b.readUInt16LE(0);
            if (format === 65534 && n >= 40) format = b.readUInt16LE(24);
            fmt = {format, channels: b.readUInt16LE(2), rate: b.readUInt32LE(4), align: b.readUInt16LE(12), bits: b.readUInt16LE(14)};
        }
        if (tag === 'data') {data = {offset: p + 8, bytes: n}; break;}
        p += 8 + n + (n % 2);
    }
    const supported = fmt && (pcm ? (fmt.format === 1 && [8,16,24,32].includes(fmt.bits)) ||
        (fmt.format === 3 && [32,64].includes(fmt.bits)) : fmt.format === 3 && fmt.bits === 32);
    if (!supported || !data || fmt.align !== fmt.channels * fmt.bits / 8 || !data.bytes || data.bytes % fmt.align) {
        throw Error('Expected a complete 32-bit float WAV capture.');
    }
    return {...fmt, ...data, frames: data.bytes / fmt.align, little: true, unsigned: fmt.bits === 8};
}
function waveHeader(channels, rate, frames) {
    // IEEE float WAV with the mandatory fact chunk; avoids normalization/clipping.
    const h = Buffer.alloc(56), bytes = frames * channels * 4;
    h.write('RIFF'); h.writeUInt32LE(48 + bytes, 4); h.write('WAVEfmt ', 8);
    h.writeUInt32LE(16, 16); h.writeUInt16LE(3, 20); h.writeUInt16LE(channels, 22);
    h.writeUInt32LE(rate, 24); h.writeUInt32LE(rate * channels * 4, 28);
    h.writeUInt16LE(channels * 4, 32); h.writeUInt16LE(32, 34);
    h.write('fact', 36); h.writeUInt32LE(4, 40); h.writeUInt32LE(frames, 44);
    h.write('data', 48); h.writeUInt32LE(bytes, 52);
    return h;
}
function writeAll(fd, b, length = b.length, position = null) {
    let n = 0;
    while (n < length) {
        const wrote = fs.writeSync(fd, b, n, length - n, position === null ? null : position + n);
        if (!wrote) throw Error('Disk write stopped. Check free space.');
        n += wrote;
    }
}
const yieldIO = () => new Promise(resolve => setImmediate(resolve));

// Find both boundaries from a recorded plugphasor~ channel, not JS timers.
// Integer pre-roll position anchors the unwrapped quarter-note phase.
async function findRange(fd, info, job, cancelled) {
    let previous = 0, beat = job.preStart, moving = false, first = -1, last = -1;
    const b = Buffer.alloc(BLOCK * info.align), end = job.start + job.length;
    for (let base = 0; base < info.frames; base += BLOCK) {
        if (cancelled()) throw Error('Print cancelled.');
        const count = Math.min(BLOCK, info.frames - base);
        const got = fs.readSync(fd, b, 0, count * info.align, info.offset + base * info.align);
        if (got !== count * info.align) throw Error('Incomplete capture.');
        for (let i = 0; i < count; i++) {
            const phase = b.readFloatLE(i * info.align + 64), frame = base + i;
            if (!Number.isFinite(phase) || phase < 0 || phase > 1) throw Error('Invalid host clock.');
            if (!moving) {
                if (phase === 0) continue;
                // Recording must begin while transport is stopped at an integer beat.
                if (phase > .01 || frame < 2) throw Error('Host clock did not start from the requested pre-roll position.');
                moving = true;
                // At song start, retain the sample at phase zero immediately before
                // the first positive phase. No leading stopped-transport silence.
                if (job.start === job.preStart) first = frame - 1;
            } else {
                let step = phase - previous;
                if (step < -.5) {beat++; step++;}
                if (step <= 0 || step > .005) throw Error('Transport stopped or jumped during the print.');
            }
            const position = beat + phase;
            // Half-sample tolerance selects the nearest sample to a beat boundary.
            // Bias exact half-sample ties forward; float32 phase quantization must
            // not make start and end choose opposite sides of the same tie.
            const epsilon = moving && previous !== 0 ? Math.max(0, Math.min(.0001, ((phase - previous + 1) % 1) * .5) - 1e-7) : 0;
            if (first < 0 && position + epsilon >= job.start) first = frame;
            if (position + epsilon >= end) {last = frame; break;}
            previous = phase;
        }
        if (last >= 0) break;
        await yieldIO();
    }
    if (first < 0 || last <= first) throw Error('Capture ended before the complete Loop range was recorded.');
    return {first, last, frames: last - first};
}
async function split(job, cancelled = () => false, progress = () => {}) {
    const input = fs.openSync(job.raw, 'r'), handles = [], parts = [];
    try {
        const info = waveInfo(input);
        if (info.channels !== CHANNELS || info.rate !== job.rate) throw Error('Capture channel count or sample rate changed.');
        const range = await findRange(input, info, job, cancelled);
        const inputBuffer = Buffer.alloc(BLOCK * info.align);
        const output = NAMES.map(() => Buffer.alloc(BLOCK * 8));
        for (const file of job.files) {
            const part = file + '.part';
            handles.push(fs.openSync(part, 'wx')); parts.push(part);
            writeAll(handles[handles.length - 1], waveHeader(2, info.rate, range.frames));
        }
        let lastProgress = 0;
        for (let done = 0; done < range.frames; done += BLOCK) {
            if (cancelled()) throw Error('Print cancelled.');
            const count = Math.min(BLOCK, range.frames - done);
            if (fs.readSync(input, inputBuffer, 0, count * info.align, info.offset + (range.first + done) * info.align) !== count * info.align) throw Error('Incomplete capture.');
            for (let band = 0; band < 8; band++) {
                for (let frame = 0; frame < count; frame++) {
                    const start = frame * info.align + band * 8;
                    inputBuffer.copy(output[band], frame * 8, start, start + 8);
                }
                writeAll(handles[band], output[band], count * 8);
            }
            if (Date.now() - lastProgress > 150) {progress(Math.floor(100 * (done + count) / range.frames)); lastProgress = Date.now();}
            await yieldIO();
        }
        for (const fd of handles) {fs.fsyncSync(fd); fs.closeSync(fd);}
        handles.length = 0;
        if (cancelled()) throw Error('Print cancelled.');
        for (let i = 0; i < parts.length; i++) fs.renameSync(parts[i], job.files[i]);
        const result = {files: job.files, labels: job.labels, folder: job.folder, rate: info.rate, frames: range.frames, first: range.first, last: range.last};
        fs.writeFileSync(path.join(job.folder, 'result.json'), JSON.stringify(result, null, 2));
        fs.unlinkSync(job.raw);
        return result;
    } finally {
        fs.closeSync(input);
        for (const fd of handles) fs.closeSync(fd);
        for (const part of parts) {try {fs.unlinkSync(part);} catch (_) {}}
    }
}
// AIFF/AIFC PCM and floating point, including the common little-endian variant.
function aiffInfo(fd) {
    const size=fs.fstatSync(fd).size, head=readExactly(fd,12,0);
    const kind=head.toString('ascii',8,12);
    if(head.toString('ascii',0,4)!=='FORM' || !['AIFF','AIFC'].includes(kind)) throw Error('Unsupported source format.');
    let fmt, data;
    for(let p=12;p+8<=size;) {
        const h=readExactly(fd,8,p), tag=h.toString('ascii',0,4), n=h.readUInt32BE(4);
        if(p+8+n>size) throw Error('Incomplete AIFF source.');
        if(tag==='COMM') {
            if(n<18 || n>4096 || (kind==='AIFC' && n<22)) throw Error('Invalid AIFF format.');
            const b=readExactly(fd,n,p+8), codec=kind==='AIFF'?'NONE':b.toString('ascii',18,22);
            const exponent=b.readUInt16BE(8), mantissa=b.readUInt32BE(10)*2**32+b.readUInt32BE(14);
            const rate=mantissa*2**((exponent&32767)-16383-63)*(exponent&32768?-1:1);
            if(!['NONE','twos','sowt','fl32','FL32','fl64','FL64'].includes(codec)) throw Error('Compressed AIFF needs conversion.');
            const bits=b.readUInt16BE(6), channels=b.readUInt16BE(0);
            fmt={channels,bits,rate,frames:b.readUInt32BE(2),align:channels*bits/8,
                format:/^fl/i.test(codec)?3:1,little:codec==='sowt',unsigned:false};
        }
        if(tag==='SSND') {
            if(n<8) throw Error('Invalid AIFF audio chunk.');
            const offset=readExactly(fd,8,p+8).readUInt32BE(0);
            if(offset>n-8) throw Error('Invalid AIFF data offset.');
            data={offset:p+16+offset,bytes:n-8-offset};
        }
        p+=8+n+(n%2);
    }
    if(!fmt || !data || !fmt.frames || fmt.frames*fmt.align>data.bytes ||
        !(fmt.format===1?[8,16,24,32]:[32,64]).includes(fmt.bits)) throw Error('Unsupported AIFF samples.');
    return {...fmt,...data};
}
function audioInfo(fd) {
    const magic=readExactly(fd,4,0).toString('ascii');
    const info=magic==='RIFF'?waveInfo(fd,true):aiffInfo(fd);
    if(![1,2].includes(info.channels)) throw Error('Use a mono or stereo source file.');
    if(!Number.isFinite(info.rate) || info.rate<22050 || info.rate>384000 || !Number.isInteger(info.rate)) throw Error('Unsupported source sample rate.');
    if(info.frames*8>MAX_BYTES) throw Error('Source is too long for one split. Export a shorter file.');
    return info;
}
function sampleReader(info) {
    if(info.format===3) {
        const method=info.bits===32?(info.little?'readFloatLE':'readFloatBE'):(info.little?'readDoubleLE':'readDoubleBE');
        return (b,p)=>b[method](p);
    }
    if(info.bits===8) return info.unsigned?(b,p)=>(b[p]-128)/128:(b,p)=>b.readInt8(p)/128;
    const bytes=info.bits/8, scale=2**(info.bits-1);
    return info.little?(b,p)=>b.readIntLE(p,bytes)/scale:(b,p)=>b.readIntBE(p,bytes)/scale;
}
function coefficients(f, rate) {
    f=Math.min(f,rate*.49);
    const w=2*Math.PI*f/rate,c=Math.cos(w),a=Math.sin(w)/Math.sqrt(2),a0=1+a,b1=-2*c/a0,b2=(1-a)/a0;
    return {lp:[(1-c)/2/a0,(1-c)/a0,(1-c)/2/a0,b1,b2],hp:[(1+c)/2/a0,-(1+c)/a0,(1+c)/2/a0,b1,b2],ap:[b2,b1,1,b1,b2]};
}
function filterBlock(data, count, q) {
    const [a0,a1,a2,b1,b2]=q;let z1=q[5],z2=q[6];
    for(let n=0;n<count;n++) {
        const x=data[n],y=a0*x+z1;
        z1=a1*x-b1*y+z2;z2=a2*x-b2*y;data[n]=y;
    }
    // Prevent inaudible recursive tails from entering the denormal range.
    q[5]=Math.abs(z1)<1e-30?0:z1;q[6]=Math.abs(z2)<1e-30?0:z2;
}
function makeBank(rate, edges) {
    const c=edges.map(f=>coefficients(f,rate)), stage=v=>new Float64Array([...v,0,0]);
    return Array.from({length:2},()=>c.map((v,i)=>({lp:[stage(v.lp),stage(v.lp)],hp:[stage(v.hp),stage(v.hp)],ap:c.slice(i+1).map(a=>stage(a.ap))})));
}
function createOfflineJob(config) {
    if(!Number.isFinite(config.start) || config.start<0 || !Array.isArray(config.edges) || config.edges.length!==7 ||
        config.edges.some((f,i)=>!Number.isFinite(f) || f<=0 || (i && f<=config.edges[i-1]))) throw Error('Invalid crossovers or destination position.');
    const source=nativePath(config.source);
    if(!path.isAbsolute(source) || !fs.statSync(source).isFile()) throw Error('The reference source file is unavailable.');
    let base=nativePath(config.folder);
    if(!base && config.setPath) base=path.join(path.dirname(nativePath(config.setPath)),'Samples','Processed','BANDS');
    if(!path.isAbsolute(base)) throw Error('Choose an output folder first.');
    fs.mkdirSync(base,{recursive:true});
    const folder=fs.mkdtempSync(path.join(base,'BANDS-'+safeName(config.reference)+'-'));
    return {...config,mode:'file',source,folder,decoded:path.join(folder,'.decoded.wav')};
}
async function readableSource(job, cancelled, stage) {
    let fd;
    try {fd=fs.openSync(job.source,'r');audioInfo(fd);return job.source;}
    catch(e) {
        if(process.platform!=='darwin') throw Error('Use a PCM WAV or AIFF source. Convert other formats first.');
    } finally {if(fd!==undefined)fs.closeSync(fd);}
    if(cancelled()) throw Error('Print cancelled.');
    // Core Audio's system converter is included with macOS. No shell, downloads
    // or external installation; source and destination are separate arguments.
    await new Promise((resolve,reject)=>{
        const child=require('child_process').spawn('/usr/bin/afconvert',[job.source,job.decoded,'-f','WAVE','-d','LEF32'],{stdio:['ignore','ignore','pipe']});
        let error='',limit=false,settled=false;
        const finish=e=>{if(settled)return;settled=true;clearInterval(timer);e?reject(e):resolve();};
        child.stderr.on('data',data=>{error=(error+data.toString()).slice(-1000);});
        child.on('error',()=>finish(Error('The system audio converter could not start. Use WAV or AIFF.')));
        child.on('close',code=>finish(cancelled()?Error('Print cancelled.'):limit?Error('Decoded source is too large. Export a shorter file.'):code?Error('Cannot decode this audio file. Convert it to WAV or AIFF first.'):null));
        const timer=setInterval(()=>{
            try {if(fs.statSync(job.decoded).size>MAX_BYTES)limit=true;}catch(_){}
            if(cancelled() || limit)child.kill('SIGTERM');else stage('Decoding source file...');
        },250);
        stage('Decoding source file...');
    });
    return job.decoded;
}
async function splitOffline(job, cancelled=()=>false, progress=()=>{}, stage=()=>{}) {
    let input;const handles=[],parts=[];
    try {
        const source=await readableSource(job,cancelled,stage);
        if(cancelled()) throw Error('Print cancelled.');
        input=fs.openSync(source,'r');const info=audioInfo(input),read=sampleReader(info),bank=makeBank(info.rate,job.edges);
        job.rate=info.rate;job.labels=ranges(job.edges,info.rate);
        job.files=job.labels.map((label,i)=>path.join(job.folder,String(i+1).padStart(2,'0')+' '+safeName(label)+'.wav'));
        const bytes=Buffer.alloc(BLOCK*info.align),high=new Float64Array(BLOCK),low=new Float64Array(BLOCK);
        const outputs=NAMES.map(()=>Buffer.alloc(BLOCK*8));let lastProgress=0;
        for(const file of job.files) {
            const part=file+'.part';handles.push(fs.openSync(part,'wx'));parts.push(part);
            writeAll(handles[handles.length-1],waveHeader(2,info.rate,info.frames));
        }
        for(let done=0;done<info.frames;done+=BLOCK) {
            if(cancelled()) throw Error('Print cancelled.');
            const count=Math.min(BLOCK,info.frames-done);
            if(fs.readSync(input,bytes,0,count*info.align,info.offset+done*info.align)!==count*info.align) throw Error('Incomplete source file.');
            for(let ch=0;ch<2;ch++) {
                for(let n=0;n<count;n++) {
                    const x=read(bytes,n*info.align+(info.channels===1?0:ch*info.bits/8));
                    if(!Number.isFinite(x)) throw Error('Source contains invalid audio samples.');
                    high[n]=x;
                }
                for(let band=0;band<8;band++) {
                    let samples=high;
                    if(band<7) {
                        low.set(high);const s=bank[ch][band];
                        for(const q of s.lp)filterBlock(low,count,q);
                        for(const q of s.ap)filterBlock(low,count,q);
                        samples=low;
                        for(const q of s.hp)filterBlock(high,count,q);
                    }
                    for(let n=0;n<count;n++) {
                        const y=samples[n];
                        if(!Number.isFinite(y) || Math.abs(y)>3.402823466e38) throw Error('Source level exceeds float audio range.');
                        outputs[band].writeFloatLE(y,n*8+ch*4);
                    }
                }
            }
            for(let band=0;band<8;band++)writeAll(handles[band],outputs[band],count*8);
            if(Date.now()-lastProgress>150){progress(Math.floor(100*(done+count)/info.frames));lastProgress=Date.now();}
            await yieldIO();
        }
        for(const fd of handles){fs.fsyncSync(fd);fs.closeSync(fd);}handles.length=0;
        if(cancelled()) throw Error('Print cancelled.');
        for(let i=0;i<parts.length;i++)fs.renameSync(parts[i],job.files[i]);
        const result={files:job.files,labels:job.labels,folder:job.folder,rate:info.rate,frames:info.frames,mode:'file'};
        fs.writeFileSync(path.join(job.folder,'print.json'),JSON.stringify({version:'1.3.0',mode:'file',source:job.source,edges:job.edges,start:job.start,...result},null,2));
        return result;
    } finally {
        if(input!==undefined)fs.closeSync(input);
        for(const fd of handles)fs.closeSync(fd);
        for(const file of parts.concat(job.decoded)){try{fs.unlinkSync(file);}catch(_){}}
    }
}
function discard(job) {
    // Only remove our temporary capture; completed WAVs are never deleted.
    if (job) {try {fs.unlinkSync(job.raw);} catch (_) {}}
}
module.exports = {prepare, split, waveInfo, waveHeader, findRange, safeName, nativePath, MAX_BYTES,
    audioInfo, aiffInfo, coefficients, makeBank, filterBlock, createOfflineJob, splitOffline};

if (process.env.MAX_ENV) {
    const max = require('max-api');
    let job = null, busy = false, cancelled = false;
    max.addHandler('offline', async json => {
        if(busy || job)return max.outlet('failed','Previous print is still finishing.');
        busy=true;cancelled=false;
        try {
            job=createOfflineJob(JSON.parse(json));
            const result=await splitOffline(job,()=>cancelled,value=>max.outlet('progress',value),text=>max.outlet('stage',text));
            max.outlet('finished',JSON.stringify(result));
        } catch(e){max.outlet('failed',e.message);}
        finally{job=null;busy=false;}
    });
    max.addHandler('prepare', json => {
        if (busy || job) return max.outlet('failed', 'Previous print is still finishing.');
        try {cancelled = false; job = prepare(JSON.parse(json)); max.outlet('prepared', job.raw, job.folder);}
        catch (e) {max.outlet('failed', e.message);}
    });
    max.addHandler('finish', async () => {
        if (!job || busy) return;
        busy = true;
        try {
            const result = await split(job, () => cancelled, value => max.outlet('progress', value));
            max.outlet('finished', JSON.stringify(result));
        } catch (e) {max.outlet('failed', e.message);}
        finally {discard(job); job = null; busy = false;}
    });
    max.addHandler('cancel', () => {
        cancelled = true;
        if (!busy) {discard(job); job = null; max.outlet('cancelled');}
    });
    max.addHandler('ping', () => max.outlet('ready'));
    max.outlet('ready');
}
