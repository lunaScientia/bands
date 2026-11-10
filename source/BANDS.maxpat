{
  "patcher": {
    "fileversion": 1,
    "appversion": {
      "major": 9,
      "minor": 1,
      "revision": 0,
      "architecture": "x64",
      "modernui": 1
    },
    "classnamespace": "box",
    "rect": [
      80.0,
      100.0,
      1340.0,
      169.0
    ],
    "openrect": [
      0.0,
      0.0,
      1340.0,
      169.0
    ],
    "openinpresentation": 1,
    "default_fontsize": 11.0,
    "default_fontname": "Arial",
    "bgcolor": [
      0.065,
      0.085,
      0.105,
      1.0
    ],
    "bglocked": 1,
    "boxes": [
      {
        "box": {
          "id": "in",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            30,
            220,
            250,
            22
          ],
          "text": "plugin~"
        }
      },
      {
        "box": {
          "id": "out",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            310,
            220,
            250,
            22
          ],
          "text": "plugout~"
        }
      },
      {
        "box": {
          "id": "control",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            590,
            220,
            250,
            22
          ],
          "text": "js bands_control.js ---bands"
        }
      },
      {
        "box": {
          "id": "printcontrol",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            870,
            220,
            250,
            22
          ],
          "text": "js bands_print.js ---bands"
        }
      },
      {
        "box": {
          "id": "printbus",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            220,
            250,
            22
          ],
          "text": "r ---bands-print-command"
        }
      },
      {
        "box": {
          "id": "printworker",
          "maxclass": "node.codebox",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1430,
            220,
            250,
            22
          ],
          "varname": "printworker",
          "code": "// Node for Max: bounded file processing. No network, npm or Live API here.\n'use strict';\nconst fs = require('fs');\nconst path = require('path');\nconst NAMES = ['Ultra Low', 'Sub', 'Bass', 'Mids', 'High-Mids', 'Presence', 'High', 'Ultra High'];\nconst CHANNELS = 17; // eight stereo bands, then the sample-synchronous host beat phase\nconst BLOCK = 8192;\nconst MAX_BYTES = 3 * 1024 ** 3;\n\nfunction nativePath(s) {\n    s = String(s || '');\n    // Max's macOS path convention: \"Macintosh HD:/path/to/file\".\n    if (process.platform === 'darwin' && /^[^/:]+:\\//.test(s)) {\n        const colon = s.indexOf(':');\n        const relative = s.slice(colon + 1);\n        const volume = '/Volumes/' + s.slice(0, colon) + relative;\n        return fs.existsSync(volume) ? volume : relative;\n    }\n    return s;\n}\nfunction safeName(s) {\n    return String(s).replace(/[\\x00-\\x1f<>:\"/\\\\|?*]/g, '_').replace(/[. ]+$/g, '').slice(0, 70) || 'Reference';\n}\nfunction ranges(edges, rate) {\n    const cuts = edges.map(f => Math.min(f, rate * .49));\n    return NAMES.map((name, i) => name + ' ' + (i ? cuts[i - 1] : 0) + '-' + (i < 7 ? cuts[i] : rate / 2) + ' Hz');\n}\nfunction prepare(config) {\n    if (!Number.isFinite(config.rate) || config.rate < 22050 || config.rate > 384000 ||\n        !Number.isFinite(config.start) || config.start < 0 || !Number.isFinite(config.length) || config.length <= 0 ||\n        !Number.isFinite(config.preStart) || config.preStart < 0 || config.preStart > config.start || config.preStart % 1 ||\n        !Array.isArray(config.edges) || config.edges.length !== 7 ||\n        config.edges.some((f, i) => !Number.isFinite(f) || f <= 0 || (i && f <= config.edges[i - 1]))) {\n        throw Error('Invalid print range, sample rate or crossovers.');\n    }\n    let base = nativePath(config.folder);\n    if (!base && config.setPath) base = path.join(path.dirname(nativePath(config.setPath)), 'Samples', 'Processed', 'BANDS');\n    if (!path.isAbsolute(base)) throw Error('Choose an output folder first.');\n    fs.mkdirSync(base, {recursive: true});\n    const folder = fs.mkdtempSync(path.join(base, 'BANDS-' + safeName(config.reference) + '-'));\n    const labels = ranges(config.edges, config.rate);\n    const files = labels.map((label, i) => path.join(folder, String(i + 1).padStart(2, '0') + ' ' + safeName(label) + '.wav'));\n    const job = {...config, folder, labels, files, raw: path.join(folder, '.capture.wav')};\n    fs.writeFileSync(path.join(folder, 'print.json'), JSON.stringify({version: '1.3.0', ...config, labels}, null, 2));\n    return job;\n}\nfunction readExactly(fd, length, position) {\n    const b = Buffer.alloc(length);\n    let n = 0;\n    while (n < length) {\n        const got = fs.readSync(fd, b, n, length - n, position + n);\n        if (!got) throw Error('Incomplete capture file.');\n        n += got;\n    }\n    return b;\n}\nfunction waveInfo(fd, pcm = false) {\n    const size = fs.fstatSync(fd).size;\n    const head = readExactly(fd, 12, 0);\n    if (head.toString('ascii', 0, 4) !== 'RIFF' || head.toString('ascii', 8) !== 'WAVE') throw Error('Capture is not a WAV file.');\n    let fmt, data;\n    for (let p = 12; p + 8 <= size;) {\n        const h = readExactly(fd, 8, p), tag = h.toString('ascii', 0, 4), n = h.readUInt32LE(4);\n        if (p + 8 + n > size) throw Error('Capture is still being written or disk is full.');\n        if (tag === 'fmt ') {\n            if (n < 16 || n > 4096) throw Error('Invalid WAV format.');\n            const b = readExactly(fd, n, p + 8);\n            let format = b.readUInt16LE(0);\n            if (format === 65534 && n >= 40) format = b.readUInt16LE(24);\n            fmt = {format, channels: b.readUInt16LE(2), rate: b.readUInt32LE(4), align: b.readUInt16LE(12), bits: b.readUInt16LE(14)};\n        }\n        if (tag === 'data') {data = {offset: p + 8, bytes: n}; break;}\n        p += 8 + n + (n % 2);\n    }\n    const supported = fmt && (pcm ? (fmt.format === 1 && [8,16,24,32].includes(fmt.bits)) ||\n        (fmt.format === 3 && [32,64].includes(fmt.bits)) : fmt.format === 3 && fmt.bits === 32);\n    if (!supported || !data || fmt.align !== fmt.channels * fmt.bits / 8 || !data.bytes || data.bytes % fmt.align) {\n        throw Error('Expected a complete 32-bit float WAV capture.');\n    }\n    return {...fmt, ...data, frames: data.bytes / fmt.align, little: true, unsigned: fmt.bits === 8};\n}\nfunction waveHeader(channels, rate, frames) {\n    // IEEE float WAV with the mandatory fact chunk; avoids normalization/clipping.\n    const h = Buffer.alloc(56), bytes = frames * channels * 4;\n    h.write('RIFF'); h.writeUInt32LE(48 + bytes, 4); h.write('WAVEfmt ', 8);\n    h.writeUInt32LE(16, 16); h.writeUInt16LE(3, 20); h.writeUInt16LE(channels, 22);\n    h.writeUInt32LE(rate, 24); h.writeUInt32LE(rate * channels * 4, 28);\n    h.writeUInt16LE(channels * 4, 32); h.writeUInt16LE(32, 34);\n    h.write('fact', 36); h.writeUInt32LE(4, 40); h.writeUInt32LE(frames, 44);\n    h.write('data', 48); h.writeUInt32LE(bytes, 52);\n    return h;\n}\nfunction writeAll(fd, b, length = b.length, position = null) {\n    let n = 0;\n    while (n < length) {\n        const wrote = fs.writeSync(fd, b, n, length - n, position === null ? null : position + n);\n        if (!wrote) throw Error('Disk write stopped. Check free space.');\n        n += wrote;\n    }\n}\nconst yieldIO = () => new Promise(resolve => setImmediate(resolve));\n\n// Find both boundaries from a recorded plugphasor~ channel, not JS timers.\n// Integer pre-roll position anchors the unwrapped quarter-note phase.\nasync function findRange(fd, info, job, cancelled) {\n    let previous = 0, beat = job.preStart, moving = false, first = -1, last = -1;\n    const b = Buffer.alloc(BLOCK * info.align), end = job.start + job.length;\n    for (let base = 0; base < info.frames; base += BLOCK) {\n        if (cancelled()) throw Error('Print cancelled.');\n        const count = Math.min(BLOCK, info.frames - base);\n        const got = fs.readSync(fd, b, 0, count * info.align, info.offset + base * info.align);\n        if (got !== count * info.align) throw Error('Incomplete capture.');\n        for (let i = 0; i < count; i++) {\n            const phase = b.readFloatLE(i * info.align + 64), frame = base + i;\n            if (!Number.isFinite(phase) || phase < 0 || phase > 1) throw Error('Invalid host clock.');\n            if (!moving) {\n                if (phase === 0) continue;\n                // Recording must begin while transport is stopped at an integer beat.\n                if (phase > .01 || frame < 2) throw Error('Host clock did not start from the requested pre-roll position.');\n                moving = true;\n                // At song start, retain the sample at phase zero immediately before\n                // the first positive phase. No leading stopped-transport silence.\n                if (job.start === job.preStart) first = frame - 1;\n            } else {\n                let step = phase - previous;\n                if (step < -.5) {beat++; step++;}\n                if (step <= 0 || step > .005) throw Error('Transport stopped or jumped during the print.');\n            }\n            const position = beat + phase;\n            // Half-sample tolerance selects the nearest sample to a beat boundary.\n            // Bias exact half-sample ties forward; float32 phase quantization must\n            // not make start and end choose opposite sides of the same tie.\n            const epsilon = moving && previous !== 0 ? Math.max(0, Math.min(.0001, ((phase - previous + 1) % 1) * .5) - 1e-7) : 0;\n            if (first < 0 && position + epsilon >= job.start) first = frame;\n            if (position + epsilon >= end) {last = frame; break;}\n            previous = phase;\n        }\n        if (last >= 0) break;\n        await yieldIO();\n    }\n    if (first < 0 || last <= first) throw Error('Capture ended before the complete Loop range was recorded.');\n    return {first, last, frames: last - first};\n}\nasync function split(job, cancelled = () => false, progress = () => {}) {\n    const input = fs.openSync(job.raw, 'r'), handles = [], parts = [];\n    try {\n        const info = waveInfo(input);\n        if (info.channels !== CHANNELS || info.rate !== job.rate) throw Error('Capture channel count or sample rate changed.');\n        const range = await findRange(input, info, job, cancelled);\n        const inputBuffer = Buffer.alloc(BLOCK * info.align);\n        const output = NAMES.map(() => Buffer.alloc(BLOCK * 8));\n        for (const file of job.files) {\n            const part = file + '.part';\n            handles.push(fs.openSync(part, 'wx')); parts.push(part);\n            writeAll(handles[handles.length - 1], waveHeader(2, info.rate, range.frames));\n        }\n        let lastProgress = 0;\n        for (let done = 0; done < range.frames; done += BLOCK) {\n            if (cancelled()) throw Error('Print cancelled.');\n            const count = Math.min(BLOCK, range.frames - done);\n            if (fs.readSync(input, inputBuffer, 0, count * info.align, info.offset + (range.first + done) * info.align) !== count * info.align) throw Error('Incomplete capture.');\n            for (let band = 0; band < 8; band++) {\n                for (let frame = 0; frame < count; frame++) {\n                    const start = frame * info.align + band * 8;\n                    inputBuffer.copy(output[band], frame * 8, start, start + 8);\n                }\n                writeAll(handles[band], output[band], count * 8);\n            }\n            if (Date.now() - lastProgress > 150) {progress(Math.floor(100 * (done + count) / range.frames)); lastProgress = Date.now();}\n            await yieldIO();\n        }\n        for (const fd of handles) {fs.fsyncSync(fd); fs.closeSync(fd);}\n        handles.length = 0;\n        if (cancelled()) throw Error('Print cancelled.');\n        for (let i = 0; i < parts.length; i++) fs.renameSync(parts[i], job.files[i]);\n        const result = {files: job.files, labels: job.labels, folder: job.folder, rate: info.rate, frames: range.frames, first: range.first, last: range.last};\n        fs.writeFileSync(path.join(job.folder, 'result.json'), JSON.stringify(result, null, 2));\n        fs.unlinkSync(job.raw);\n        return result;\n    } finally {\n        fs.closeSync(input);\n        for (const fd of handles) fs.closeSync(fd);\n        for (const part of parts) {try {fs.unlinkSync(part);} catch (_) {}}\n    }\n}\n// AIFF/AIFC PCM and floating point, including the common little-endian variant.\nfunction aiffInfo(fd) {\n    const size=fs.fstatSync(fd).size, head=readExactly(fd,12,0);\n    const kind=head.toString('ascii',8,12);\n    if(head.toString('ascii',0,4)!=='FORM' || !['AIFF','AIFC'].includes(kind)) throw Error('Unsupported source format.');\n    let fmt, data;\n    for(let p=12;p+8<=size;) {\n        const h=readExactly(fd,8,p), tag=h.toString('ascii',0,4), n=h.readUInt32BE(4);\n        if(p+8+n>size) throw Error('Incomplete AIFF source.');\n        if(tag==='COMM') {\n            if(n<18 || n>4096 || (kind==='AIFC' && n<22)) throw Error('Invalid AIFF format.');\n            const b=readExactly(fd,n,p+8), codec=kind==='AIFF'?'NONE':b.toString('ascii',18,22);\n            const exponent=b.readUInt16BE(8), mantissa=b.readUInt32BE(10)*2**32+b.readUInt32BE(14);\n            const rate=mantissa*2**((exponent&32767)-16383-63)*(exponent&32768?-1:1);\n            if(!['NONE','twos','sowt','fl32','FL32','fl64','FL64'].includes(codec)) throw Error('Compressed AIFF needs conversion.');\n            const bits=b.readUInt16BE(6), channels=b.readUInt16BE(0);\n            fmt={channels,bits,rate,frames:b.readUInt32BE(2),align:channels*bits/8,\n                format:/^fl/i.test(codec)?3:1,little:codec==='sowt',unsigned:false};\n        }\n        if(tag==='SSND') {\n            if(n<8) throw Error('Invalid AIFF audio chunk.');\n            const offset=readExactly(fd,8,p+8).readUInt32BE(0);\n            if(offset>n-8) throw Error('Invalid AIFF data offset.');\n            data={offset:p+16+offset,bytes:n-8-offset};\n        }\n        p+=8+n+(n%2);\n    }\n    if(!fmt || !data || !fmt.frames || fmt.frames*fmt.align>data.bytes ||\n        !(fmt.format===1?[8,16,24,32]:[32,64]).includes(fmt.bits)) throw Error('Unsupported AIFF samples.');\n    return {...fmt,...data};\n}\nfunction audioInfo(fd) {\n    const magic=readExactly(fd,4,0).toString('ascii');\n    const info=magic==='RIFF'?waveInfo(fd,true):aiffInfo(fd);\n    if(![1,2].includes(info.channels)) throw Error('Use a mono or stereo source file.');\n    if(!Number.isFinite(info.rate) || info.rate<22050 || info.rate>384000 || !Number.isInteger(info.rate)) throw Error('Unsupported source sample rate.');\n    if(info.frames*8>MAX_BYTES) throw Error('Source is too long for one split. Export a shorter file.');\n    return info;\n}\nfunction sampleReader(info) {\n    if(info.format===3) {\n        const method=info.bits===32?(info.little?'readFloatLE':'readFloatBE'):(info.little?'readDoubleLE':'readDoubleBE');\n        return (b,p)=>b[method](p);\n    }\n    if(info.bits===8) return info.unsigned?(b,p)=>(b[p]-128)/128:(b,p)=>b.readInt8(p)/128;\n    const bytes=info.bits/8, scale=2**(info.bits-1);\n    return info.little?(b,p)=>b.readIntLE(p,bytes)/scale:(b,p)=>b.readIntBE(p,bytes)/scale;\n}\nfunction coefficients(f, rate) {\n    f=Math.min(f,rate*.49);\n    const w=2*Math.PI*f/rate,c=Math.cos(w),a=Math.sin(w)/Math.sqrt(2),a0=1+a,b1=-2*c/a0,b2=(1-a)/a0;\n    return {lp:[(1-c)/2/a0,(1-c)/a0,(1-c)/2/a0,b1,b2],hp:[(1+c)/2/a0,-(1+c)/a0,(1+c)/2/a0,b1,b2],ap:[b2,b1,1,b1,b2]};\n}\nfunction filterBlock(data, count, q) {\n    const [a0,a1,a2,b1,b2]=q;let z1=q[5],z2=q[6];\n    for(let n=0;n<count;n++) {\n        const x=data[n],y=a0*x+z1;\n        z1=a1*x-b1*y+z2;z2=a2*x-b2*y;data[n]=y;\n    }\n    // Prevent inaudible recursive tails from entering the denormal range.\n    q[5]=Math.abs(z1)<1e-30?0:z1;q[6]=Math.abs(z2)<1e-30?0:z2;\n}\nfunction makeBank(rate, edges) {\n    const c=edges.map(f=>coefficients(f,rate)), stage=v=>new Float64Array([...v,0,0]);\n    return Array.from({length:2},()=>c.map((v,i)=>({lp:[stage(v.lp),stage(v.lp)],hp:[stage(v.hp),stage(v.hp)],ap:c.slice(i+1).map(a=>stage(a.ap))})));\n}\nfunction createOfflineJob(config) {\n    if(!Number.isFinite(config.start) || config.start<0 || !Array.isArray(config.edges) || config.edges.length!==7 ||\n        config.edges.some((f,i)=>!Number.isFinite(f) || f<=0 || (i && f<=config.edges[i-1]))) throw Error('Invalid crossovers or destination position.');\n    const source=nativePath(config.source);\n    if(!path.isAbsolute(source) || !fs.statSync(source).isFile()) throw Error('The reference source file is unavailable.');\n    let base=nativePath(config.folder);\n    if(!base && config.setPath) base=path.join(path.dirname(nativePath(config.setPath)),'Samples','Processed','BANDS');\n    if(!path.isAbsolute(base)) throw Error('Choose an output folder first.');\n    fs.mkdirSync(base,{recursive:true});\n    const folder=fs.mkdtempSync(path.join(base,'BANDS-'+safeName(config.reference)+'-'));\n    return {...config,mode:'file',source,folder,decoded:path.join(folder,'.decoded.wav')};\n}\nasync function readableSource(job, cancelled, stage) {\n    let fd;\n    try {fd=fs.openSync(job.source,'r');audioInfo(fd);return job.source;}\n    catch(e) {\n        if(process.platform!=='darwin') throw Error('Use a PCM WAV or AIFF source. Convert other formats first.');\n    } finally {if(fd!==undefined)fs.closeSync(fd);}\n    if(cancelled()) throw Error('Print cancelled.');\n    // Core Audio's system converter is included with macOS. No shell, downloads\n    // or external installation; source and destination are separate arguments.\n    await new Promise((resolve,reject)=>{\n        const child=require('child_process').spawn('/usr/bin/afconvert',[job.source,job.decoded,'-f','WAVE','-d','LEF32'],{stdio:['ignore','ignore','pipe']});\n        let error='',limit=false,settled=false;\n        const finish=e=>{if(settled)return;settled=true;clearInterval(timer);e?reject(e):resolve();};\n        child.stderr.on('data',data=>{error=(error+data.toString()).slice(-1000);});\n        child.on('error',()=>finish(Error('The system audio converter could not start. Use WAV or AIFF.')));\n        child.on('close',code=>finish(cancelled()?Error('Print cancelled.'):limit?Error('Decoded source is too large. Export a shorter file.'):code?Error('Cannot decode this audio file. Convert it to WAV or AIFF first.'):null));\n        const timer=setInterval(()=>{\n            try {if(fs.statSync(job.decoded).size>MAX_BYTES)limit=true;}catch(_){}\n            if(cancelled() || limit)child.kill('SIGTERM');else stage('Decoding source file...');\n        },250);\n        stage('Decoding source file...');\n    });\n    return job.decoded;\n}\nasync function splitOffline(job, cancelled=()=>false, progress=()=>{}, stage=()=>{}) {\n    let input;const handles=[],parts=[];\n    try {\n        const source=await readableSource(job,cancelled,stage);\n        if(cancelled()) throw Error('Print cancelled.');\n        input=fs.openSync(source,'r');const info=audioInfo(input),read=sampleReader(info),bank=makeBank(info.rate,job.edges);\n        job.rate=info.rate;job.labels=ranges(job.edges,info.rate);\n        job.files=job.labels.map((label,i)=>path.join(job.folder,String(i+1).padStart(2,'0')+' '+safeName(label)+'.wav'));\n        const bytes=Buffer.alloc(BLOCK*info.align),high=new Float64Array(BLOCK),low=new Float64Array(BLOCK);\n        const outputs=NAMES.map(()=>Buffer.alloc(BLOCK*8));let lastProgress=0;\n        for(const file of job.files) {\n            const part=file+'.part';handles.push(fs.openSync(part,'wx'));parts.push(part);\n            writeAll(handles[handles.length-1],waveHeader(2,info.rate,info.frames));\n        }\n        for(let done=0;done<info.frames;done+=BLOCK) {\n            if(cancelled()) throw Error('Print cancelled.');\n            const count=Math.min(BLOCK,info.frames-done);\n            if(fs.readSync(input,bytes,0,count*info.align,info.offset+done*info.align)!==count*info.align) throw Error('Incomplete source file.');\n            for(let ch=0;ch<2;ch++) {\n                for(let n=0;n<count;n++) {\n                    const x=read(bytes,n*info.align+(info.channels===1?0:ch*info.bits/8));\n                    if(!Number.isFinite(x)) throw Error('Source contains invalid audio samples.');\n                    high[n]=x;\n                }\n                for(let band=0;band<8;band++) {\n                    let samples=high;\n                    if(band<7) {\n                        low.set(high);const s=bank[ch][band];\n                        for(const q of s.lp)filterBlock(low,count,q);\n                        for(const q of s.ap)filterBlock(low,count,q);\n                        samples=low;\n                        for(const q of s.hp)filterBlock(high,count,q);\n                    }\n                    for(let n=0;n<count;n++) {\n                        const y=samples[n];\n                        if(!Number.isFinite(y) || Math.abs(y)>3.402823466e38) throw Error('Source level exceeds float audio range.');\n                        outputs[band].writeFloatLE(y,n*8+ch*4);\n                    }\n                }\n            }\n            for(let band=0;band<8;band++)writeAll(handles[band],outputs[band],count*8);\n            if(Date.now()-lastProgress>150){progress(Math.floor(100*(done+count)/info.frames));lastProgress=Date.now();}\n            await yieldIO();\n        }\n        for(const fd of handles){fs.fsyncSync(fd);fs.closeSync(fd);}handles.length=0;\n        if(cancelled()) throw Error('Print cancelled.');\n        for(let i=0;i<parts.length;i++)fs.renameSync(parts[i],job.files[i]);\n        const result={files:job.files,labels:job.labels,folder:job.folder,rate:info.rate,frames:info.frames,mode:'file'};\n        fs.writeFileSync(path.join(job.folder,'print.json'),JSON.stringify({version:'1.3.0',mode:'file',source:job.source,edges:job.edges,start:job.start,...result},null,2));\n        return result;\n    } finally {\n        if(input!==undefined)fs.closeSync(input);\n        for(const fd of handles)fs.closeSync(fd);\n        for(const file of parts.concat(job.decoded)){try{fs.unlinkSync(file);}catch(_){}}\n    }\n}\nfunction discard(job) {\n    // Only remove our temporary capture; completed WAVs are never deleted.\n    if (job) {try {fs.unlinkSync(job.raw);} catch (_) {}}\n}\nmodule.exports = {prepare, split, waveInfo, waveHeader, findRange, safeName, nativePath, MAX_BYTES,\n    audioInfo, aiffInfo, coefficients, makeBank, filterBlock, createOfflineJob, splitOffline};\n\nif (process.env.MAX_ENV) {\n    const max = require('max-api');\n    let job = null, busy = false, cancelled = false;\n    max.addHandler('offline', async json => {\n        if(busy || job)return max.outlet('failed','Previous print is still finishing.');\n        busy=true;cancelled=false;\n        try {\n            job=createOfflineJob(JSON.parse(json));\n            const result=await splitOffline(job,()=>cancelled,value=>max.outlet('progress',value),text=>max.outlet('stage',text));\n            max.outlet('finished',JSON.stringify(result));\n        } catch(e){max.outlet('failed',e.message);}\n        finally{job=null;busy=false;}\n    });\n    max.addHandler('prepare', json => {\n        if (busy || job) return max.outlet('failed', 'Previous print is still finishing.');\n        try {cancelled = false; job = prepare(JSON.parse(json)); max.outlet('prepared', job.raw, job.folder);}\n        catch (e) {max.outlet('failed', e.message);}\n    });\n    max.addHandler('finish', async () => {\n        if (!job || busy) return;\n        busy = true;\n        try {\n            const result = await split(job, () => cancelled, value => max.outlet('progress', value));\n            max.outlet('finished', JSON.stringify(result));\n        } catch (e) {max.outlet('failed', e.message);}\n        finally {discard(job); job = null; busy = false;}\n    });\n    max.addHandler('cancel', () => {\n        cancelled = true;\n        if (!busy) {discard(job); job = null; max.outlet('cancelled');}\n    });\n    max.addHandler('ping', () => max.outlet('ready'));\n    max.outlet('ready');\n}\n",
          "saved_object_attributes": {
            "autostart": 0,
            "defer": 1,
            "watch": 0,
            "restart": 0
          }
        }
      },
      {
        "box": {
          "id": "printdialog",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            30,
            285,
            250,
            22
          ],
          "text": "opendialog fold"
        }
      },
      {
        "box": {
          "id": "printfoldermsg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            285,
            250,
            22
          ],
          "text": "prepend folder"
        }
      },
      {
        "box": {
          "id": "printdialogcancel",
          "maxclass": "message",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            285,
            250,
            22
          ],
          "text": "foldercancel"
        }
      },
      {
        "box": {
          "id": "viewbus",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            285,
            250,
            22
          ],
          "text": "r ---bands-view"
        }
      },
      {
        "box": {
          "id": "cmd",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            285,
            250,
            22
          ],
          "text": "r ---bands-command"
        }
      },
      {
        "box": {
          "id": "view",
          "maxclass": "jsui",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            0,
            0,
            530,
            143
          ],
          "presentation": 1,
          "presentation_rect": [
            0,
            0,
            530,
            143
          ],
          "filename": "bands_view.js",
          "jsarguments": [
            "---bands",
            0
          ],
          "parameter_enable": 0,
          "border": 0
        }
      },
      {
        "box": {
          "id": "clock",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            285,
            250,
            22
          ],
          "text": "qmetro 33"
        }
      },
      {
        "box": {
          "id": "clockon",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            350,
            250,
            22
          ],
          "text": "loadmess 1"
        }
      },
      {
        "box": {
          "id": "dev",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            310,
            350,
            250,
            22
          ],
          "text": "live.thisdevice"
        }
      },
      {
        "box": {
          "id": "defer",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            350,
            250,
            22
          ],
          "text": "deferlow"
        }
      },
      {
        "box": {
          "id": "init",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            870,
            350,
            250,
            22
          ],
          "text": "t b b"
        }
      },
      {
        "box": {
          "id": "initmsg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            350,
            250,
            22
          ],
          "text": "prepend init"
        }
      },
      {
        "box": {
          "id": "load",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            350,
            250,
            22
          ],
          "text": "loadbang"
        }
      },
      {
        "box": {
          "id": "loaddefer",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            415,
            250,
            22
          ],
          "text": "deferlow"
        }
      },
      {
        "box": {
          "id": "dsp",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 6,
          "patching_rect": [
            310,
            415,
            250,
            22
          ],
          "text": "dspstate~"
        }
      },
      {
        "box": {
          "id": "sr",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            415,
            250,
            22
          ],
          "text": "prepend samplerate"
        }
      },
      {
        "box": {
          "id": "printdsp",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            415,
            250,
            22
          ],
          "text": "prepend dspstate"
        }
      },
      {
        "box": {
          "id": "splits",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            12,
            146,
            65,
            18
          ],
          "text": "SPLITS / Hz",
          "presentation": 1,
          "presentation_rect": [
            12,
            146,
            65,
            18
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "splits",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "edge0",
          "maxclass": "live.numbox",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            80,
            146,
            58,
            18
          ],
          "presentation": 1,
          "presentation_rect": [
            80,
            146,
            58,
            18
          ],
          "parameter_enable": 1,
          "varname": "edge0",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Crossover 1",
              "parameter_shortname": "Split 1",
              "parameter_type": 0,
              "parameter_mmin": 15.0,
              "parameter_mmax": 49.0,
              "parameter_initial": [
                30.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 3
            }
          },
          "fontsize": 10.0
        }
      },
      {
        "box": {
          "id": "fpack0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            415,
            250,
            22
          ],
          "text": "pack 0. 60"
        }
      },
      {
        "box": {
          "id": "fline0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            1430,
            415,
            250,
            22
          ],
          "text": "line 30. 10"
        }
      },
      {
        "box": {
          "id": "fmsg0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            480,
            250,
            22
          ],
          "text": "prepend crossover 0"
        }
      },
      {
        "box": {
          "id": "edge1",
          "maxclass": "live.numbox",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            143,
            146,
            58,
            18
          ],
          "presentation": 1,
          "presentation_rect": [
            143,
            146,
            58,
            18
          ],
          "parameter_enable": 1,
          "varname": "edge1",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Crossover 2",
              "parameter_shortname": "Split 2",
              "parameter_type": 0,
              "parameter_mmin": 50.0,
              "parameter_mmax": 139.0,
              "parameter_initial": [
                80.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 3
            }
          },
          "fontsize": 10.0
        }
      },
      {
        "box": {
          "id": "fpack1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            480,
            250,
            22
          ],
          "text": "pack 0. 60"
        }
      },
      {
        "box": {
          "id": "fline1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            590,
            480,
            250,
            22
          ],
          "text": "line 80. 10"
        }
      },
      {
        "box": {
          "id": "fmsg1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            480,
            250,
            22
          ],
          "text": "prepend crossover 1"
        }
      },
      {
        "box": {
          "id": "edge2",
          "maxclass": "live.numbox",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            206,
            146,
            58,
            18
          ],
          "presentation": 1,
          "presentation_rect": [
            206,
            146,
            58,
            18
          ],
          "parameter_enable": 1,
          "varname": "edge2",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Crossover 3",
              "parameter_shortname": "Split 3",
              "parameter_type": 0,
              "parameter_mmin": 140.0,
              "parameter_mmax": 599.0,
              "parameter_initial": [
                250.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 3
            }
          },
          "fontsize": 10.0
        }
      },
      {
        "box": {
          "id": "fpack2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            480,
            250,
            22
          ],
          "text": "pack 0. 60"
        }
      },
      {
        "box": {
          "id": "fline2",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            1430,
            480,
            250,
            22
          ],
          "text": "line 250. 10"
        }
      },
      {
        "box": {
          "id": "fmsg2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            545,
            250,
            22
          ],
          "text": "prepend crossover 2"
        }
      },
      {
        "box": {
          "id": "edge3",
          "maxclass": "live.numbox",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            269,
            146,
            58,
            18
          ],
          "presentation": 1,
          "presentation_rect": [
            269,
            146,
            58,
            18
          ],
          "parameter_enable": 1,
          "varname": "edge3",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Crossover 4",
              "parameter_shortname": "Split 4",
              "parameter_type": 0,
              "parameter_mmin": 600.0,
              "parameter_mmax": 2999.0,
              "parameter_initial": [
                2000.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 3
            }
          },
          "fontsize": 10.0
        }
      },
      {
        "box": {
          "id": "fpack3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            545,
            250,
            22
          ],
          "text": "pack 0. 60"
        }
      },
      {
        "box": {
          "id": "fline3",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            590,
            545,
            250,
            22
          ],
          "text": "line 2000. 10"
        }
      },
      {
        "box": {
          "id": "fmsg3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            545,
            250,
            22
          ],
          "text": "prepend crossover 3"
        }
      },
      {
        "box": {
          "id": "edge4",
          "maxclass": "live.numbox",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            332,
            146,
            58,
            18
          ],
          "presentation": 1,
          "presentation_rect": [
            332,
            146,
            58,
            18
          ],
          "parameter_enable": 1,
          "varname": "edge4",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Crossover 5",
              "parameter_shortname": "Split 5",
              "parameter_type": 0,
              "parameter_mmin": 3000.0,
              "parameter_mmax": 4999.0,
              "parameter_initial": [
                4000.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 3
            }
          },
          "fontsize": 10.0
        }
      },
      {
        "box": {
          "id": "fpack4",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            545,
            250,
            22
          ],
          "text": "pack 0. 60"
        }
      },
      {
        "box": {
          "id": "fline4",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            1430,
            545,
            250,
            22
          ],
          "text": "line 4000. 10"
        }
      },
      {
        "box": {
          "id": "fmsg4",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            610,
            250,
            22
          ],
          "text": "prepend crossover 4"
        }
      },
      {
        "box": {
          "id": "edge5",
          "maxclass": "live.numbox",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            395,
            146,
            58,
            18
          ],
          "presentation": 1,
          "presentation_rect": [
            395,
            146,
            58,
            18
          ],
          "parameter_enable": 1,
          "varname": "edge5",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Crossover 6",
              "parameter_shortname": "Split 6",
              "parameter_type": 0,
              "parameter_mmin": 5000.0,
              "parameter_mmax": 9999.0,
              "parameter_initial": [
                6000.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 3
            }
          },
          "fontsize": 10.0
        }
      },
      {
        "box": {
          "id": "fpack5",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            610,
            250,
            22
          ],
          "text": "pack 0. 60"
        }
      },
      {
        "box": {
          "id": "fline5",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            590,
            610,
            250,
            22
          ],
          "text": "line 6000. 10"
        }
      },
      {
        "box": {
          "id": "fmsg5",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            610,
            250,
            22
          ],
          "text": "prepend crossover 5"
        }
      },
      {
        "box": {
          "id": "edge6",
          "maxclass": "live.numbox",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            458,
            146,
            58,
            18
          ],
          "presentation": 1,
          "presentation_rect": [
            458,
            146,
            58,
            18
          ],
          "parameter_enable": 1,
          "varname": "edge6",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Crossover 7",
              "parameter_shortname": "Split 7",
              "parameter_type": 0,
              "parameter_mmin": 10000.0,
              "parameter_mmax": 18000.0,
              "parameter_initial": [
                12000.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 3
            }
          },
          "fontsize": 10.0
        }
      },
      {
        "box": {
          "id": "fpack6",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            610,
            250,
            22
          ],
          "text": "pack 0. 60"
        }
      },
      {
        "box": {
          "id": "fline6",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            1430,
            610,
            250,
            22
          ],
          "text": "line 12000. 10"
        }
      },
      {
        "box": {
          "id": "fmsg6",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            675,
            250,
            22
          ],
          "text": "prepend crossover 6"
        }
      },
      {
        "box": {
          "id": "stripe0",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            542,
            7,
            75,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            542,
            7,
            75,
            3
          ],
          "bgcolor": [
            0.69,
            0.53,
            1,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label0",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            542,
            16,
            80,
            17
          ],
          "text": "ULTRA LOW",
          "presentation": 1,
          "presentation_rect": [
            542,
            16,
            80,
            17
          ],
          "textcolor": [
            0.69,
            0.53,
            1,
            1
          ],
          "fontsize": 10,
          "varname": "label0",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range0",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            542,
            34,
            80,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            542,
            34,
            80,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range0",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain0",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            550,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            550,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain0",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Ultra Low Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.69,
            0.53,
            1,
            1
          ],
          "activeneedlecolor": [
            0.69,
            0.53,
            1,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain0msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            675,
            250,
            22
          ],
          "text": "prepend gain 0"
        }
      },
      {
        "box": {
          "id": "solo0",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            542,
            125,
            35,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            542,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo0",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Ultra Low Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.69,
            0.53,
            1,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo0msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            675,
            250,
            22
          ],
          "text": "prepend solo 0"
        }
      },
      {
        "box": {
          "id": "mute0",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            582,
            125,
            35,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            582,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute0",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Ultra Low Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.69,
            0.53,
            1,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute0msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            675,
            250,
            22
          ],
          "text": "prepend mute 0"
        }
      },
      {
        "box": {
          "id": "stripe1",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            625,
            7,
            75,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            625,
            7,
            75,
            3
          ],
          "bgcolor": [
            0.3,
            0.64,
            1,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label1",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            625,
            16,
            80,
            17
          ],
          "text": "SUB",
          "presentation": 1,
          "presentation_rect": [
            625,
            16,
            80,
            17
          ],
          "textcolor": [
            0.3,
            0.64,
            1,
            1
          ],
          "fontsize": 10,
          "varname": "label1",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range1",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            625,
            34,
            80,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            625,
            34,
            80,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range1",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain1",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            633,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            633,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain1",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Sub Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.3,
            0.64,
            1,
            1
          ],
          "activeneedlecolor": [
            0.3,
            0.64,
            1,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain1msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            675,
            250,
            22
          ],
          "text": "prepend gain 1"
        }
      },
      {
        "box": {
          "id": "solo1",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            625,
            125,
            35,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            625,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo1",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Sub Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.3,
            0.64,
            1,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo1msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            675,
            250,
            22
          ],
          "text": "prepend solo 1"
        }
      },
      {
        "box": {
          "id": "mute1",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            665,
            125,
            35,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            665,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute1",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Sub Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.3,
            0.64,
            1,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute1msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            740,
            250,
            22
          ],
          "text": "prepend mute 1"
        }
      },
      {
        "box": {
          "id": "stripe2",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            708,
            7,
            75,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            708,
            7,
            75,
            3
          ],
          "bgcolor": [
            0.22,
            0.85,
            0.76,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label2",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            708,
            16,
            80,
            17
          ],
          "text": "BASS",
          "presentation": 1,
          "presentation_rect": [
            708,
            16,
            80,
            17
          ],
          "textcolor": [
            0.22,
            0.85,
            0.76,
            1
          ],
          "fontsize": 10,
          "varname": "label2",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range2",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            708,
            34,
            80,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            708,
            34,
            80,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range2",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain2",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            716,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            716,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain2",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Bass Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.22,
            0.85,
            0.76,
            1
          ],
          "activeneedlecolor": [
            0.22,
            0.85,
            0.76,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain2msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            740,
            250,
            22
          ],
          "text": "prepend gain 2"
        }
      },
      {
        "box": {
          "id": "solo2",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            708,
            125,
            35,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            708,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo2",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Bass Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.22,
            0.85,
            0.76,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo2msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            740,
            250,
            22
          ],
          "text": "prepend solo 2"
        }
      },
      {
        "box": {
          "id": "mute2",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            748,
            125,
            35,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            748,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute2",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Bass Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.22,
            0.85,
            0.76,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute2msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            740,
            250,
            22
          ],
          "text": "prepend mute 2"
        }
      },
      {
        "box": {
          "id": "stripe3",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            791,
            7,
            75,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            791,
            7,
            75,
            3
          ],
          "bgcolor": [
            0.94,
            0.72,
            0.36,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label3",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            791,
            16,
            80,
            17
          ],
          "text": "MIDS",
          "presentation": 1,
          "presentation_rect": [
            791,
            16,
            80,
            17
          ],
          "textcolor": [
            0.94,
            0.72,
            0.36,
            1
          ],
          "fontsize": 10,
          "varname": "label3",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range3",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            791,
            34,
            80,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            791,
            34,
            80,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range3",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain3",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            799,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            799,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain3",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Mids Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.94,
            0.72,
            0.36,
            1
          ],
          "activeneedlecolor": [
            0.94,
            0.72,
            0.36,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain3msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            740,
            250,
            22
          ],
          "text": "prepend gain 3"
        }
      },
      {
        "box": {
          "id": "solo3",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            791,
            125,
            35,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            791,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo3",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Mids Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.94,
            0.72,
            0.36,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo3msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            740,
            250,
            22
          ],
          "text": "prepend solo 3"
        }
      },
      {
        "box": {
          "id": "mute3",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            831,
            125,
            35,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            831,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute3",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Mids Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.94,
            0.72,
            0.36,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute3msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            805,
            250,
            22
          ],
          "text": "prepend mute 3"
        }
      },
      {
        "box": {
          "id": "stripe4",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            874,
            7,
            75,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            874,
            7,
            75,
            3
          ],
          "bgcolor": [
            0.98,
            0.57,
            0.32,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label4",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            874,
            16,
            80,
            17
          ],
          "text": "HIGH-MIDS",
          "presentation": 1,
          "presentation_rect": [
            874,
            16,
            80,
            17
          ],
          "textcolor": [
            0.98,
            0.57,
            0.32,
            1
          ],
          "fontsize": 10,
          "varname": "label4",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range4",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            874,
            34,
            80,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            874,
            34,
            80,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range4",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain4",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            882,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            882,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain4",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "High-Mids Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.98,
            0.57,
            0.32,
            1
          ],
          "activeneedlecolor": [
            0.98,
            0.57,
            0.32,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain4msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            805,
            250,
            22
          ],
          "text": "prepend gain 4"
        }
      },
      {
        "box": {
          "id": "solo4",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            874,
            125,
            35,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            874,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo4",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "High-Mids Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.98,
            0.57,
            0.32,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo4msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            805,
            250,
            22
          ],
          "text": "prepend solo 4"
        }
      },
      {
        "box": {
          "id": "mute4",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            914,
            125,
            35,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            914,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute4",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "High-Mids Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.98,
            0.57,
            0.32,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute4msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            805,
            250,
            22
          ],
          "text": "prepend mute 4"
        }
      },
      {
        "box": {
          "id": "stripe5",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            957,
            7,
            75,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            957,
            7,
            75,
            3
          ],
          "bgcolor": [
            0.95,
            0.43,
            0.49,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label5",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            957,
            16,
            80,
            17
          ],
          "text": "PRESENCE",
          "presentation": 1,
          "presentation_rect": [
            957,
            16,
            80,
            17
          ],
          "textcolor": [
            0.95,
            0.43,
            0.49,
            1
          ],
          "fontsize": 10,
          "varname": "label5",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range5",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            957,
            34,
            80,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            957,
            34,
            80,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range5",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain5",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            965,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            965,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain5",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Presence Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.95,
            0.43,
            0.49,
            1
          ],
          "activeneedlecolor": [
            0.95,
            0.43,
            0.49,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain5msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            805,
            250,
            22
          ],
          "text": "prepend gain 5"
        }
      },
      {
        "box": {
          "id": "solo5",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            957,
            125,
            35,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            957,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo5",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Presence Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.95,
            0.43,
            0.49,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo5msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            805,
            250,
            22
          ],
          "text": "prepend solo 5"
        }
      },
      {
        "box": {
          "id": "mute5",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            997,
            125,
            35,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            997,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute5",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Presence Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.95,
            0.43,
            0.49,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute5msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            870,
            250,
            22
          ],
          "text": "prepend mute 5"
        }
      },
      {
        "box": {
          "id": "stripe6",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            1040,
            7,
            75,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            1040,
            7,
            75,
            3
          ],
          "bgcolor": [
            0.9,
            0.48,
            0.79,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label6",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            1040,
            16,
            80,
            17
          ],
          "text": "HIGH",
          "presentation": 1,
          "presentation_rect": [
            1040,
            16,
            80,
            17
          ],
          "textcolor": [
            0.9,
            0.48,
            0.79,
            1
          ],
          "fontsize": 10,
          "varname": "label6",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range6",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            1040,
            34,
            80,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            1040,
            34,
            80,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range6",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain6",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1048,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            1048,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain6",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "High Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.9,
            0.48,
            0.79,
            1
          ],
          "activeneedlecolor": [
            0.9,
            0.48,
            0.79,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain6msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            870,
            250,
            22
          ],
          "text": "prepend gain 6"
        }
      },
      {
        "box": {
          "id": "solo6",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1040,
            125,
            35,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            1040,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo6",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "High Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.9,
            0.48,
            0.79,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo6msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            870,
            250,
            22
          ],
          "text": "prepend solo 6"
        }
      },
      {
        "box": {
          "id": "mute6",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1080,
            125,
            35,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            1080,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute6",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "High Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.9,
            0.48,
            0.79,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute6msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            870,
            250,
            22
          ],
          "text": "prepend mute 6"
        }
      },
      {
        "box": {
          "id": "stripe7",
          "maxclass": "panel",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            1123,
            7,
            75,
            3
          ],
          "presentation": 1,
          "presentation_rect": [
            1123,
            7,
            75,
            3
          ],
          "bgcolor": [
            0.66,
            0.78,
            0.97,
            1
          ],
          "border": 0
        }
      },
      {
        "box": {
          "id": "label7",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            1123,
            16,
            80,
            17
          ],
          "text": "ULTRA HIGH",
          "presentation": 1,
          "presentation_rect": [
            1123,
            16,
            80,
            17
          ],
          "textcolor": [
            0.66,
            0.78,
            0.97,
            1
          ],
          "fontsize": 10,
          "varname": "label7",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "range7",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            1123,
            34,
            80,
            17
          ],
          "text": "",
          "presentation": 1,
          "presentation_rect": [
            1123,
            34,
            80,
            17
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "range7",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "gain7",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1131,
            58,
            60,
            60
          ],
          "presentation": 1,
          "presentation_rect": [
            1131,
            58,
            60,
            60
          ],
          "parameter_enable": 1,
          "varname": "gain7",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Ultra High Gain",
              "parameter_shortname": "Gain",
              "parameter_type": 0,
              "parameter_mmin": -60.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0,
          "activefgdialcolor": [
            0.66,
            0.78,
            0.97,
            1
          ],
          "activeneedlecolor": [
            0.66,
            0.78,
            0.97,
            1
          ]
        }
      },
      {
        "box": {
          "id": "gain7msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            870,
            250,
            22
          ],
          "text": "prepend gain 7"
        }
      },
      {
        "box": {
          "id": "solo7",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1123,
            125,
            35,
            20
          ],
          "text": "S",
          "presentation": 1,
          "presentation_rect": [
            1123,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "solo7",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Ultra High Solo",
              "parameter_shortname": "S",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "S",
          "activebgoncolor": [
            0.66,
            0.78,
            0.97,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "solo7msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            870,
            250,
            22
          ],
          "text": "prepend solo 7"
        }
      },
      {
        "box": {
          "id": "mute7",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1163,
            125,
            35,
            20
          ],
          "text": "M",
          "presentation": 1,
          "presentation_rect": [
            1163,
            125,
            35,
            20
          ],
          "parameter_enable": 1,
          "varname": "mute7",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Ultra High Mute",
              "parameter_shortname": "M",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Off",
                "On"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "M",
          "activebgoncolor": [
            0.66,
            0.78,
            0.97,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "bgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textcolor": [
            0.7,
            0.76,
            0.8,
            1
          ],
          "textoncolor": [
            0.07,
            0.09,
            0.11,
            1
          ]
        }
      },
      {
        "box": {
          "id": "mute7msg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            935,
            250,
            22
          ],
          "text": "prepend mute 7"
        }
      },
      {
        "box": {
          "id": "trimtitle",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            1221,
            15,
            95,
            18
          ],
          "text": "OUTPUT",
          "presentation": 1,
          "presentation_rect": [
            1221,
            15,
            95,
            18
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 10,
          "varname": "trimtitle",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "trim",
          "maxclass": "live.dial",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1234,
            52,
            60,
            61
          ],
          "presentation": 1,
          "presentation_rect": [
            1234,
            52,
            60,
            61
          ],
          "parameter_enable": 1,
          "varname": "trim",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Output Trim",
              "parameter_shortname": "Trim",
              "parameter_type": 0,
              "parameter_mmin": -24.0,
              "parameter_mmax": 12.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 4
            }
          },
          "fontsize": 10.0,
          "showname": 0
        }
      },
      {
        "box": {
          "id": "trimmsg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            935,
            250,
            22
          ],
          "text": "prepend trim"
        }
      },
      {
        "box": {
          "id": "original",
          "maxclass": "live.text",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1218,
            122,
            99,
            21
          ],
          "text": "Original",
          "presentation": 1,
          "presentation_rect": [
            1218,
            122,
            99,
            21
          ],
          "parameter_enable": 1,
          "varname": "original",
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Listen to Original",
              "parameter_shortname": "Original",
              "parameter_type": 2,
              "parameter_mmin": 0.0,
              "parameter_mmax": 1.0,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1,
              "parameter_unitstyle": 0,
              "parameter_enum": [
                "Bands",
                "Original"
              ]
            }
          },
          "fontsize": 10.0,
          "texton": "Original",
          "activebgoncolor": [
            0.45,
            0.62,
            0.64,
            1
          ],
          "activebgcolor": [
            0.16,
            0.19,
            0.22,
            1
          ],
          "textoncolor": [
            0.06,
            0.08,
            0.1,
            1
          ]
        }
      },
      {
        "box": {
          "id": "originalmsg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            935,
            250,
            22
          ],
          "text": "prepend original"
        }
      },
      {
        "box": {
          "id": "reset",
          "maxclass": "textbutton",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            1218,
            148,
            99,
            17
          ],
          "text": "Reset mix",
          "presentation": 1,
          "presentation_rect": [
            1218,
            148,
            99,
            17
          ],
          "parameter_enable": 0,
          "fontsize": 9
        }
      },
      {
        "box": {
          "id": "resetmsg",
          "maxclass": "message",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            935,
            250,
            22
          ],
          "text": "command reset"
        }
      },
      {
        "box": {
          "id": "printstatus",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            645,
            149,
            350,
            16
          ],
          "text": "Whole source file -> 8 tracks / fast",
          "presentation": 1,
          "presentation_rect": [
            645,
            149,
            350,
            16
          ],
          "textcolor": [
            0.62,
            0.68,
            0.72,
            1
          ],
          "fontsize": 9,
          "varname": "printstatus",
          "ignoreclick": 1
        }
      },
      {
        "box": {
          "id": "printmode",
          "maxclass": "textbutton",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            547,
            148,
            90,
            17
          ],
          "text": "File: fast",
          "presentation": 1,
          "presentation_rect": [
            547,
            148,
            90,
            17
          ],
          "parameter_enable": 0,
          "fontsize": 9,
          "varname": "printmode"
        }
      },
      {
        "box": {
          "id": "printmodeclick",
          "maxclass": "message",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            935,
            250,
            22
          ],
          "text": "mode"
        }
      },
      {
        "box": {
          "id": "printbutton",
          "maxclass": "textbutton",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            1005,
            148,
            110,
            17
          ],
          "text": "Split File",
          "presentation": 1,
          "presentation_rect": [
            1005,
            148,
            110,
            17
          ],
          "parameter_enable": 0,
          "fontsize": 9,
          "varname": "printbutton"
        }
      },
      {
        "box": {
          "id": "printbuttonclick",
          "maxclass": "message",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            935,
            250,
            22
          ],
          "text": "print"
        }
      },
      {
        "box": {
          "id": "printfolder",
          "maxclass": "textbutton",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            1120,
            148,
            79,
            17
          ],
          "text": "Folder...",
          "presentation": 1,
          "presentation_rect": [
            1120,
            148,
            79,
            17
          ],
          "parameter_enable": 0,
          "fontsize": 9,
          "varname": "printfolder"
        }
      },
      {
        "box": {
          "id": "printfolderclick",
          "maxclass": "message",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1000,
            250,
            22
          ],
          "text": "choosefolder"
        }
      },
      {
        "box": {
          "id": "rlp0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1000,
            250,
            22
          ],
          "text": "r ---bands-lp0"
        }
      },
      {
        "box": {
          "id": "rhp0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1000,
            250,
            22
          ],
          "text": "r ---bands-hp0"
        }
      },
      {
        "box": {
          "id": "rap0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1000,
            250,
            22
          ],
          "text": "r ---bands-ap0"
        }
      },
      {
        "box": {
          "id": "rlp1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1000,
            250,
            22
          ],
          "text": "r ---bands-lp1"
        }
      },
      {
        "box": {
          "id": "rhp1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1000,
            250,
            22
          ],
          "text": "r ---bands-hp1"
        }
      },
      {
        "box": {
          "id": "rap1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1065,
            250,
            22
          ],
          "text": "r ---bands-ap1"
        }
      },
      {
        "box": {
          "id": "rlp2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1065,
            250,
            22
          ],
          "text": "r ---bands-lp2"
        }
      },
      {
        "box": {
          "id": "rhp2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1065,
            250,
            22
          ],
          "text": "r ---bands-hp2"
        }
      },
      {
        "box": {
          "id": "rap2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1065,
            250,
            22
          ],
          "text": "r ---bands-ap2"
        }
      },
      {
        "box": {
          "id": "rlp3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1065,
            250,
            22
          ],
          "text": "r ---bands-lp3"
        }
      },
      {
        "box": {
          "id": "rhp3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1065,
            250,
            22
          ],
          "text": "r ---bands-hp3"
        }
      },
      {
        "box": {
          "id": "rap3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1130,
            250,
            22
          ],
          "text": "r ---bands-ap3"
        }
      },
      {
        "box": {
          "id": "rlp4",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1130,
            250,
            22
          ],
          "text": "r ---bands-lp4"
        }
      },
      {
        "box": {
          "id": "rhp4",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1130,
            250,
            22
          ],
          "text": "r ---bands-hp4"
        }
      },
      {
        "box": {
          "id": "rap4",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1130,
            250,
            22
          ],
          "text": "r ---bands-ap4"
        }
      },
      {
        "box": {
          "id": "rlp5",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1130,
            250,
            22
          ],
          "text": "r ---bands-lp5"
        }
      },
      {
        "box": {
          "id": "rhp5",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1130,
            250,
            22
          ],
          "text": "r ---bands-hp5"
        }
      },
      {
        "box": {
          "id": "rap5",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1195,
            250,
            22
          ],
          "text": "r ---bands-ap5"
        }
      },
      {
        "box": {
          "id": "rlp6",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1195,
            250,
            22
          ],
          "text": "r ---bands-lp6"
        }
      },
      {
        "box": {
          "id": "rhp6",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1195,
            250,
            22
          ],
          "text": "r ---bands-hp6"
        }
      },
      {
        "box": {
          "id": "rap6",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1195,
            250,
            22
          ],
          "text": "r ---bands-ap6"
        }
      },
      {
        "box": {
          "id": "0lp0a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1195,
            250,
            22
          ],
          "text": "biquad~ 3.844633506779265e-06 7.68926701355853e-06 3.844633506779265e-06 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "0lp0b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1195,
            250,
            22
          ],
          "text": "biquad~ 3.844633506779265e-06 7.68926701355853e-06 3.844633506779265e-06 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "0hp0a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1260,
            250,
            22
          ],
          "text": "biquad~ 0.99722704990447009 -1.9944540998089402 0.99722704990447009 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "0hp0b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1260,
            250,
            22
          ],
          "text": "biquad~ 0.99722704990447009 -1.9944540998089402 0.99722704990447009 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "0comp0_1",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1260,
            250,
            22
          ],
          "text": "biquad~ 0.98529951312821462 -1.9851906578962613 1 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "0comp0_2",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1260,
            250,
            22
          ],
          "text": "biquad~ 0.95477455992103966 -1.9537279491407762 1 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "0comp0_3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1260,
            250,
            22
          ],
          "text": "biquad~ 0.69059892324149708 -1.6329931618554523 1 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "0comp0_4",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1260,
            250,
            22
          ],
          "text": "biquad~ 0.47759225007251715 -1.279632424997809 1 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "0comp0_5",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1325,
            250,
            22
          ],
          "text": "biquad~ 0.33333333333333331 -0.94280904158206347 1 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "0comp0_6",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1325,
            250,
            22
          ],
          "text": "biquad~ 0.17157287525380996 -7.1738148582371984e-17 1 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "0lp1a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1325,
            250,
            22
          ],
          "text": "biquad~ 2.7213807988313326e-05 5.4427615976626652e-05 2.7213807988313326e-05 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "0lp1b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1325,
            250,
            22
          ],
          "text": "biquad~ 2.7213807988313326e-05 5.4427615976626652e-05 2.7213807988313326e-05 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "0hp1a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1325,
            250,
            22
          ],
          "text": "biquad~ 0.99262254275611894 -1.9852450855122379 0.99262254275611894 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "0hp1b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1325,
            250,
            22
          ],
          "text": "biquad~ 0.99262254275611894 -1.9852450855122379 0.99262254275611894 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "0comp1_2",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1390,
            250,
            22
          ],
          "text": "biquad~ 0.95477455992103966 -1.9537279491407762 1 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "0comp1_3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1390,
            250,
            22
          ],
          "text": "biquad~ 0.69059892324149708 -1.6329931618554523 1 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "0comp1_4",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1390,
            250,
            22
          ],
          "text": "biquad~ 0.47759225007251715 -1.279632424997809 1 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "0comp1_5",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1390,
            250,
            22
          ],
          "text": "biquad~ 0.33333333333333331 -0.94280904158206347 1 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "0comp1_6",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1390,
            250,
            22
          ],
          "text": "biquad~ 0.17157287525380996 -7.1738148582371984e-17 1 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "0lp2a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1390,
            250,
            22
          ],
          "text": "biquad~ 0.00026165269506587055 0.0005233053901317411 0.00026165269506587055 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "0lp2b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1455,
            250,
            22
          ],
          "text": "biquad~ 0.00026165269506587055 0.0005233053901317411 0.00026165269506587055 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "0hp2a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1455,
            250,
            22
          ],
          "text": "biquad~ 0.97712562726545404 -1.9542512545309081 0.97712562726545404 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "0hp2b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1455,
            250,
            22
          ],
          "text": "biquad~ 0.97712562726545404 -1.9542512545309081 0.97712562726545404 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "0comp2_3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1455,
            250,
            22
          ],
          "text": "biquad~ 0.69059892324149708 -1.6329931618554523 1 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "0comp2_4",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1455,
            250,
            22
          ],
          "text": "biquad~ 0.47759225007251715 -1.279632424997809 1 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "0comp2_5",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1455,
            250,
            22
          ],
          "text": "biquad~ 0.33333333333333331 -0.94280904158206347 1 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "0comp2_6",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1520,
            250,
            22
          ],
          "text": "biquad~ 0.17157287525380996 -7.1738148582371984e-17 1 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "0lp3a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1520,
            250,
            22
          ],
          "text": "biquad~ 0.01440144034651121 0.02880288069302242 0.01440144034651121 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "0lp3b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1520,
            250,
            22
          ],
          "text": "biquad~ 0.01440144034651121 0.02880288069302242 0.01440144034651121 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "0hp3a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1520,
            250,
            22
          ],
          "text": "biquad~ 0.83089802127423729 -1.6617960425484746 0.83089802127423729 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "0hp3b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1520,
            250,
            22
          ],
          "text": "biquad~ 0.83089802127423729 -1.6617960425484746 0.83089802127423729 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "0comp3_4",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1520,
            250,
            22
          ],
          "text": "biquad~ 0.47759225007251715 -1.279632424997809 1 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "0comp3_5",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1585,
            250,
            22
          ],
          "text": "biquad~ 0.33333333333333331 -0.94280904158206347 1 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "0comp3_6",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1585,
            250,
            22
          ],
          "text": "biquad~ 0.17157287525380996 -7.1738148582371984e-17 1 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "0lp4a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1585,
            250,
            22
          ],
          "text": "biquad~ 0.049489956268677041 0.098979912537354081 0.049489956268677041 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "0lp4b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1585,
            250,
            22
          ],
          "text": "biquad~ 0.049489956268677041 0.098979912537354081 0.049489956268677041 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "0hp4a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1585,
            250,
            22
          ],
          "text": "biquad~ 0.68930616876758155 -1.3786123375351631 0.68930616876758155 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "0hp4b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1585,
            250,
            22
          ],
          "text": "biquad~ 0.68930616876758155 -1.3786123375351631 0.68930616876758155 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "0comp4_5",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1650,
            250,
            22
          ],
          "text": "biquad~ 0.33333333333333331 -0.94280904158206347 1 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "0comp4_6",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1650,
            250,
            22
          ],
          "text": "biquad~ 0.17157287525380996 -7.1738148582371984e-17 1 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "0lp5a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1650,
            250,
            22
          ],
          "text": "biquad~ 0.097631072937817476 0.19526214587563495 0.097631072937817476 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "0lp5b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1650,
            250,
            22
          ],
          "text": "biquad~ 0.097631072937817476 0.19526214587563495 0.097631072937817476 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "0hp5a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1650,
            250,
            22
          ],
          "text": "biquad~ 0.56903559372884915 -1.1380711874576983 0.56903559372884915 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "0hp5b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1650,
            250,
            22
          ],
          "text": "biquad~ 0.56903559372884915 -1.1380711874576983 0.56903559372884915 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "0comp5_6",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1715,
            250,
            22
          ],
          "text": "biquad~ 0.17157287525380996 -7.1738148582371984e-17 1 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "0lp6a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1715,
            250,
            22
          ],
          "text": "biquad~ 0.29289321881345243 0.58578643762690485 0.29289321881345243 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "0lp6b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1715,
            250,
            22
          ],
          "text": "biquad~ 0.29289321881345243 0.58578643762690485 0.29289321881345243 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "0hp6a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1715,
            250,
            22
          ],
          "text": "biquad~ 0.29289321881345248 -0.58578643762690497 0.29289321881345248 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "0hp6b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1715,
            250,
            22
          ],
          "text": "biquad~ 0.29289321881345248 -0.58578643762690497 0.29289321881345248 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "1lp0a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1715,
            250,
            22
          ],
          "text": "biquad~ 3.844633506779265e-06 7.68926701355853e-06 3.844633506779265e-06 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "1lp0b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1780,
            250,
            22
          ],
          "text": "biquad~ 3.844633506779265e-06 7.68926701355853e-06 3.844633506779265e-06 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "1hp0a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1780,
            250,
            22
          ],
          "text": "biquad~ 0.99722704990447009 -1.9944540998089402 0.99722704990447009 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "1hp0b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1780,
            250,
            22
          ],
          "text": "biquad~ 0.99722704990447009 -1.9944540998089402 0.99722704990447009 -1.9944464105419266 0.99446178907595373"
        }
      },
      {
        "box": {
          "id": "1comp0_1",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1780,
            250,
            22
          ],
          "text": "biquad~ 0.98529951312821462 -1.9851906578962613 1 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "1comp0_2",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1780,
            250,
            22
          ],
          "text": "biquad~ 0.95477455992103966 -1.9537279491407762 1 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "1comp0_3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1780,
            250,
            22
          ],
          "text": "biquad~ 0.69059892324149708 -1.6329931618554523 1 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "1comp0_4",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1845,
            250,
            22
          ],
          "text": "biquad~ 0.47759225007251715 -1.279632424997809 1 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "1comp0_5",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1845,
            250,
            22
          ],
          "text": "biquad~ 0.33333333333333331 -0.94280904158206347 1 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "1comp0_6",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1845,
            250,
            22
          ],
          "text": "biquad~ 0.17157287525380996 -7.1738148582371984e-17 1 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "1lp1a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1845,
            250,
            22
          ],
          "text": "biquad~ 2.7213807988313326e-05 5.4427615976626652e-05 2.7213807988313326e-05 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "1lp1b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1845,
            250,
            22
          ],
          "text": "biquad~ 2.7213807988313326e-05 5.4427615976626652e-05 2.7213807988313326e-05 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "1hp1a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1845,
            250,
            22
          ],
          "text": "biquad~ 0.99262254275611894 -1.9852450855122379 0.99262254275611894 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "1hp1b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1910,
            250,
            22
          ],
          "text": "biquad~ 0.99262254275611894 -1.9852450855122379 0.99262254275611894 -1.9851906578962613 0.98529951312821462"
        }
      },
      {
        "box": {
          "id": "1comp1_2",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1910,
            250,
            22
          ],
          "text": "biquad~ 0.95477455992103966 -1.9537279491407762 1 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "1comp1_3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1910,
            250,
            22
          ],
          "text": "biquad~ 0.69059892324149708 -1.6329931618554523 1 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "1comp1_4",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1910,
            250,
            22
          ],
          "text": "biquad~ 0.47759225007251715 -1.279632424997809 1 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "1comp1_5",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1910,
            250,
            22
          ],
          "text": "biquad~ 0.33333333333333331 -0.94280904158206347 1 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "1comp1_6",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1910,
            250,
            22
          ],
          "text": "biquad~ 0.17157287525380996 -7.1738148582371984e-17 1 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "1lp2a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            1975,
            250,
            22
          ],
          "text": "biquad~ 0.00026165269506587055 0.0005233053901317411 0.00026165269506587055 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "1lp2b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            1975,
            250,
            22
          ],
          "text": "biquad~ 0.00026165269506587055 0.0005233053901317411 0.00026165269506587055 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "1hp2a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            1975,
            250,
            22
          ],
          "text": "biquad~ 0.97712562726545404 -1.9542512545309081 0.97712562726545404 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "1hp2b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            1975,
            250,
            22
          ],
          "text": "biquad~ 0.97712562726545404 -1.9542512545309081 0.97712562726545404 -1.9537279491407762 0.95477455992103966"
        }
      },
      {
        "box": {
          "id": "1comp2_3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            1975,
            250,
            22
          ],
          "text": "biquad~ 0.69059892324149708 -1.6329931618554523 1 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "1comp2_4",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            1975,
            250,
            22
          ],
          "text": "biquad~ 0.47759225007251715 -1.279632424997809 1 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "1comp2_5",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2040,
            250,
            22
          ],
          "text": "biquad~ 0.33333333333333331 -0.94280904158206347 1 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "1comp2_6",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            2040,
            250,
            22
          ],
          "text": "biquad~ 0.17157287525380996 -7.1738148582371984e-17 1 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "1lp3a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            2040,
            250,
            22
          ],
          "text": "biquad~ 0.01440144034651121 0.02880288069302242 0.01440144034651121 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "1lp3b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            2040,
            250,
            22
          ],
          "text": "biquad~ 0.01440144034651121 0.02880288069302242 0.01440144034651121 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "1hp3a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            2040,
            250,
            22
          ],
          "text": "biquad~ 0.83089802127423729 -1.6617960425484746 0.83089802127423729 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "1hp3b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            2040,
            250,
            22
          ],
          "text": "biquad~ 0.83089802127423729 -1.6617960425484746 0.83089802127423729 -1.6329931618554523 0.69059892324149708"
        }
      },
      {
        "box": {
          "id": "1comp3_4",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2105,
            250,
            22
          ],
          "text": "biquad~ 0.47759225007251715 -1.279632424997809 1 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "1comp3_5",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            2105,
            250,
            22
          ],
          "text": "biquad~ 0.33333333333333331 -0.94280904158206347 1 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "1comp3_6",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            2105,
            250,
            22
          ],
          "text": "biquad~ 0.17157287525380996 -7.1738148582371984e-17 1 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "1lp4a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            2105,
            250,
            22
          ],
          "text": "biquad~ 0.049489956268677041 0.098979912537354081 0.049489956268677041 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "1lp4b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            2105,
            250,
            22
          ],
          "text": "biquad~ 0.049489956268677041 0.098979912537354081 0.049489956268677041 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "1hp4a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            2105,
            250,
            22
          ],
          "text": "biquad~ 0.68930616876758155 -1.3786123375351631 0.68930616876758155 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "1hp4b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2170,
            250,
            22
          ],
          "text": "biquad~ 0.68930616876758155 -1.3786123375351631 0.68930616876758155 -1.279632424997809 0.47759225007251715"
        }
      },
      {
        "box": {
          "id": "1comp4_5",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            2170,
            250,
            22
          ],
          "text": "biquad~ 0.33333333333333331 -0.94280904158206347 1 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "1comp4_6",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            2170,
            250,
            22
          ],
          "text": "biquad~ 0.17157287525380996 -7.1738148582371984e-17 1 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "1lp5a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            2170,
            250,
            22
          ],
          "text": "biquad~ 0.097631072937817476 0.19526214587563495 0.097631072937817476 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "1lp5b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            2170,
            250,
            22
          ],
          "text": "biquad~ 0.097631072937817476 0.19526214587563495 0.097631072937817476 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "1hp5a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            2170,
            250,
            22
          ],
          "text": "biquad~ 0.56903559372884915 -1.1380711874576983 0.56903559372884915 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "1hp5b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2235,
            250,
            22
          ],
          "text": "biquad~ 0.56903559372884915 -1.1380711874576983 0.56903559372884915 -0.94280904158206347 0.33333333333333331"
        }
      },
      {
        "box": {
          "id": "1comp5_6",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            310,
            2235,
            250,
            22
          ],
          "text": "biquad~ 0.17157287525380996 -7.1738148582371984e-17 1 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "1lp6a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            590,
            2235,
            250,
            22
          ],
          "text": "biquad~ 0.29289321881345243 0.58578643762690485 0.29289321881345243 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "1lp6b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            870,
            2235,
            250,
            22
          ],
          "text": "biquad~ 0.29289321881345243 0.58578643762690485 0.29289321881345243 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "1hp6a",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            2235,
            250,
            22
          ],
          "text": "biquad~ 0.29289321881345248 -0.58578643762690497 0.29289321881345248 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "1hp6b",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            2235,
            250,
            22
          ],
          "text": "biquad~ 0.29289321881345248 -0.58578643762690497 0.29289321881345248 -7.1738148582371984e-17 0.17157287525380996"
        }
      },
      {
        "box": {
          "id": "printrec",
          "maxclass": "newobj",
          "numinlets": 17,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2300,
            250,
            22
          ],
          "text": "sfrecord~ 17 262144 @beginramp 0 @endramp 0",
          "varname": "printrec"
        }
      },
      {
        "box": {
          "id": "printphase",
          "maxclass": "newobj",
          "numinlets": 0,
          "numoutlets": 1,
          "patching_rect": [
            310,
            2300,
            250,
            22
          ],
          "text": "plugphasor~"
        }
      },
      {
        "box": {
          "id": "printtime",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            590,
            2300,
            250,
            22
          ],
          "text": "snapshot~ 100"
        }
      },
      {
        "box": {
          "id": "printtimemsg",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            870,
            2300,
            250,
            22
          ],
          "text": "prepend recorded"
        }
      },
      {
        "box": {
          "id": "gainr0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            2300,
            250,
            22
          ],
          "text": "r ---bands-gain0"
        }
      },
      {
        "box": {
          "id": "gainline0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            1430,
            2300,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "gainr1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2365,
            250,
            22
          ],
          "text": "r ---bands-gain1"
        }
      },
      {
        "box": {
          "id": "gainline1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            310,
            2365,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "gainr2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            2365,
            250,
            22
          ],
          "text": "r ---bands-gain2"
        }
      },
      {
        "box": {
          "id": "gainline2",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            870,
            2365,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "gainr3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            2365,
            250,
            22
          ],
          "text": "r ---bands-gain3"
        }
      },
      {
        "box": {
          "id": "gainline3",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            1430,
            2365,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "gainr4",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2430,
            250,
            22
          ],
          "text": "r ---bands-gain4"
        }
      },
      {
        "box": {
          "id": "gainline4",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            310,
            2430,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "gainr5",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            2430,
            250,
            22
          ],
          "text": "r ---bands-gain5"
        }
      },
      {
        "box": {
          "id": "gainline5",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            870,
            2430,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "gainr6",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            2430,
            250,
            22
          ],
          "text": "r ---bands-gain6"
        }
      },
      {
        "box": {
          "id": "gainline6",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            1430,
            2430,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "gainr7",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2495,
            250,
            22
          ],
          "text": "r ---bands-gain7"
        }
      },
      {
        "box": {
          "id": "gainline7",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            310,
            2495,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "trimr",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            590,
            2495,
            250,
            22
          ],
          "text": "r ---bands-trim"
        }
      },
      {
        "box": {
          "id": "trimline",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            870,
            2495,
            250,
            22
          ],
          "text": "line~ 1."
        }
      },
      {
        "box": {
          "id": "dryr",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            2495,
            250,
            22
          ],
          "text": "r ---bands-dry"
        }
      },
      {
        "box": {
          "id": "dryline",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 2,
          "patching_rect": [
            1430,
            2495,
            250,
            22
          ],
          "text": "line~ 0."
        }
      },
      {
        "box": {
          "id": "wetline",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2560,
            250,
            22
          ],
          "text": "!-~ 1."
        }
      },
      {
        "box": {
          "id": "sum0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            310,
            2560,
            250,
            22
          ],
          "text": "+~"
        }
      },
      {
        "box": {
          "id": "weighted0_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            590,
            2560,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted0_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            870,
            2560,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted0_2",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            2560,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted0_3",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            2560,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted0_4",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2625,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted0_5",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            310,
            2625,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted0_6",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            590,
            2625,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted0_7",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            870,
            2625,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "wet0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            2625,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "dry0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            2625,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "output0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2690,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "sum1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            310,
            2690,
            250,
            22
          ],
          "text": "+~"
        }
      },
      {
        "box": {
          "id": "weighted1_0",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            590,
            2690,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted1_1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            870,
            2690,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted1_2",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            2690,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted1_3",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            2690,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted1_4",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2755,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted1_5",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            310,
            2755,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted1_6",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            590,
            2755,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "weighted1_7",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            870,
            2755,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "wet1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1150,
            2755,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "dry1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            1430,
            2755,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "output1",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            30,
            2820,
            250,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "buffer0",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            310,
            2820,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec0 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer1",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            590,
            2820,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec1 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer2",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            870,
            2820,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec2 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1150,
            2820,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec3 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer4",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1430,
            2820,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec4 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer5",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            30,
            2885,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec5 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer6",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            310,
            2885,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec6 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer7",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            590,
            2885,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec7 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer8",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            870,
            2885,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec8 @samps 8192"
        }
      },
      {
        "box": {
          "id": "buffer9",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1150,
            2885,
            250,
            22
          ],
          "text": "buffer~ ---bands-spec9 @samps 8192"
        }
      },
      {
        "box": {
          "id": "fft",
          "maxclass": "newobj",
          "numinlets": 20,
          "numoutlets": 0,
          "patching_rect": [
            1430,
            2885,
            250,
            22
          ],
          "text": "pfft~ bands_fft 16384 4 args ---bands"
        }
      },
      {
        "box": {
          "id": "detail",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            30,
            2950,
            250,
            22
          ],
          "text": "p BANDS \u2014 Spectrum",
          "varname": "detail",
          "patcher": {
            "fileversion": 1,
            "appversion": {
              "major": 9,
              "minor": 1,
              "revision": 0,
              "architecture": "x64",
              "modernui": 1
            },
            "classnamespace": "box",
            "rect": [
              80.0,
              100.0,
              1060.0,
              560.0
            ],
            "openrect": [
              0.0,
              0.0,
              1060.0,
              560.0
            ],
            "openinpresentation": 1,
            "default_fontsize": 11.0,
            "default_fontname": "Arial",
            "bgcolor": [
              0.065,
              0.085,
              0.105,
              1.0
            ],
            "bglocked": 1,
            "boxes": [
              {
                "box": {
                  "id": "scope",
                  "maxclass": "jsui",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    0,
                    0,
                    1060,
                    560
                  ],
                  "presentation": 1,
                  "presentation_rect": [
                    0,
                    0,
                    1060,
                    560
                  ],
                  "filename": "bands_view.js",
                  "jsarguments": [
                    "---bands",
                    1
                  ],
                  "parameter_enable": 0,
                  "border": 0
                }
              },
              {
                "box": {
                  "id": "recv",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    276.0,
                    170.0,
                    22.0
                  ],
                  "text": "r ---bands-view"
                }
              },
              {
                "box": {
                  "id": "clk",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    304.0,
                    170.0,
                    22.0
                  ],
                  "text": "qmetro 33"
                }
              },
              {
                "box": {
                  "id": "on",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    332.0,
                    170.0,
                    22.0
                  ],
                  "text": "loadmess 1"
                }
              },
              {
                "box": {
                  "id": "cmd",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 0,
                  "patching_rect": [
                    30.0,
                    360.0,
                    170.0,
                    22.0
                  ],
                  "text": "s ---bands-command"
                }
              },
              {
                "box": {
                  "id": "window",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 2,
                  "patching_rect": [
                    30.0,
                    388.0,
                    170.0,
                    22.0
                  ],
                  "text": "thispatcher"
                }
              },
              {
                "box": {
                  "id": "front",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    416.0,
                    170.0,
                    22.0
                  ],
                  "text": "r ---bands-open"
                }
              },
              {
                "box": {
                  "id": "show",
                  "maxclass": "message",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    444.0,
                    170.0,
                    22.0
                  ],
                  "text": "window flags float, window exec, front, topmost 1"
                }
              },
              {
                "box": {
                  "id": "windowload",
                  "maxclass": "newobj",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    472.0,
                    170.0,
                    22.0
                  ],
                  "text": "loadbang"
                }
              },
              {
                "box": {
                  "id": "windowinit",
                  "maxclass": "message",
                  "numinlets": 1,
                  "numoutlets": 1,
                  "patching_rect": [
                    30.0,
                    500.0,
                    170.0,
                    22.0
                  ],
                  "text": "window flags float, window exec"
                }
              }
            ],
            "lines": [
              {
                "patchline": {
                  "source": [
                    "recv",
                    0
                  ],
                  "destination": [
                    "scope",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "on",
                    0
                  ],
                  "destination": [
                    "clk",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "clk",
                    0
                  ],
                  "destination": [
                    "scope",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "scope",
                    0
                  ],
                  "destination": [
                    "cmd",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "front",
                    0
                  ],
                  "destination": [
                    "show",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "show",
                    0
                  ],
                  "destination": [
                    "window",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "windowload",
                    0
                  ],
                  "destination": [
                    "windowinit",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "windowinit",
                    0
                  ],
                  "destination": [
                    "window",
                    0
                  ]
                }
              }
            ],
            "autosave": 0
          }
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "source": [
            "printbus",
            0
          ],
          "destination": [
            "printcontrol",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printcontrol",
            0
          ],
          "destination": [
            "printworker",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printworker",
            0
          ],
          "destination": [
            "printcontrol",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printcontrol",
            1
          ],
          "destination": [
            "printdialog",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printdialog",
            0
          ],
          "destination": [
            "printfoldermsg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printfoldermsg",
            0
          ],
          "destination": [
            "printcontrol",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printdialog",
            1
          ],
          "destination": [
            "printdialogcancel",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printdialogcancel",
            0
          ],
          "destination": [
            "printcontrol",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "cmd",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "viewbus",
            0
          ],
          "destination": [
            "view",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "view",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "clockon",
            0
          ],
          "destination": [
            "clock",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "clock",
            0
          ],
          "destination": [
            "view",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dev",
            0
          ],
          "destination": [
            "defer",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "defer",
            0
          ],
          "destination": [
            "init",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "init",
            0
          ],
          "destination": [
            "initmsg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "initmsg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "load",
            0
          ],
          "destination": [
            "loaddefer",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "loaddefer",
            0
          ],
          "destination": [
            "init",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dsp",
            1
          ],
          "destination": [
            "sr",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sr",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dsp",
            0
          ],
          "destination": [
            "printdsp",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printdsp",
            0
          ],
          "destination": [
            "printcontrol",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "init",
            1
          ],
          "destination": [
            "dsp",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "edge0",
            0
          ],
          "destination": [
            "fpack0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fpack0",
            0
          ],
          "destination": [
            "fline0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fline0",
            0
          ],
          "destination": [
            "fmsg0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fmsg0",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "edge1",
            0
          ],
          "destination": [
            "fpack1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fpack1",
            0
          ],
          "destination": [
            "fline1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fline1",
            0
          ],
          "destination": [
            "fmsg1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fmsg1",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "edge2",
            0
          ],
          "destination": [
            "fpack2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fpack2",
            0
          ],
          "destination": [
            "fline2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fline2",
            0
          ],
          "destination": [
            "fmsg2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fmsg2",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "edge3",
            0
          ],
          "destination": [
            "fpack3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fpack3",
            0
          ],
          "destination": [
            "fline3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fline3",
            0
          ],
          "destination": [
            "fmsg3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fmsg3",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "edge4",
            0
          ],
          "destination": [
            "fpack4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fpack4",
            0
          ],
          "destination": [
            "fline4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fline4",
            0
          ],
          "destination": [
            "fmsg4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fmsg4",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "edge5",
            0
          ],
          "destination": [
            "fpack5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fpack5",
            0
          ],
          "destination": [
            "fline5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fline5",
            0
          ],
          "destination": [
            "fmsg5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fmsg5",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "edge6",
            0
          ],
          "destination": [
            "fpack6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fpack6",
            0
          ],
          "destination": [
            "fline6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fline6",
            0
          ],
          "destination": [
            "fmsg6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fmsg6",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain0",
            0
          ],
          "destination": [
            "gain0msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain0msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo0",
            0
          ],
          "destination": [
            "solo0msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo0msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute0",
            0
          ],
          "destination": [
            "mute0msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute0msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain1",
            0
          ],
          "destination": [
            "gain1msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain1msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo1",
            0
          ],
          "destination": [
            "solo1msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo1msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute1",
            0
          ],
          "destination": [
            "mute1msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute1msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain2",
            0
          ],
          "destination": [
            "gain2msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain2msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo2",
            0
          ],
          "destination": [
            "solo2msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo2msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute2",
            0
          ],
          "destination": [
            "mute2msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute2msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain3",
            0
          ],
          "destination": [
            "gain3msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain3msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo3",
            0
          ],
          "destination": [
            "solo3msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo3msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute3",
            0
          ],
          "destination": [
            "mute3msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute3msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain4",
            0
          ],
          "destination": [
            "gain4msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain4msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo4",
            0
          ],
          "destination": [
            "solo4msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo4msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute4",
            0
          ],
          "destination": [
            "mute4msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute4msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain5",
            0
          ],
          "destination": [
            "gain5msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain5msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo5",
            0
          ],
          "destination": [
            "solo5msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo5msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute5",
            0
          ],
          "destination": [
            "mute5msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute5msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain6",
            0
          ],
          "destination": [
            "gain6msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain6msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo6",
            0
          ],
          "destination": [
            "solo6msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo6msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute6",
            0
          ],
          "destination": [
            "mute6msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute6msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain7",
            0
          ],
          "destination": [
            "gain7msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gain7msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo7",
            0
          ],
          "destination": [
            "solo7msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "solo7msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute7",
            0
          ],
          "destination": [
            "mute7msg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute7msg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "trim",
            0
          ],
          "destination": [
            "trimmsg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "trimmsg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "original",
            0
          ],
          "destination": [
            "originalmsg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "originalmsg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "reset",
            0
          ],
          "destination": [
            "resetmsg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "resetmsg",
            0
          ],
          "destination": [
            "control",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printmode",
            0
          ],
          "destination": [
            "printmodeclick",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printmodeclick",
            0
          ],
          "destination": [
            "printcontrol",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printbutton",
            0
          ],
          "destination": [
            "printbuttonclick",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printbuttonclick",
            0
          ],
          "destination": [
            "printcontrol",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printfolder",
            0
          ],
          "destination": [
            "printfolderclick",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printfolderclick",
            0
          ],
          "destination": [
            "printcontrol",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            0
          ],
          "destination": [
            "0lp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp0",
            0
          ],
          "destination": [
            "0lp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp0a",
            0
          ],
          "destination": [
            "0lp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp0",
            0
          ],
          "destination": [
            "0lp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            0
          ],
          "destination": [
            "0hp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp0",
            0
          ],
          "destination": [
            "0hp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp0a",
            0
          ],
          "destination": [
            "0hp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp0",
            0
          ],
          "destination": [
            "0hp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp0b",
            0
          ],
          "destination": [
            "0comp0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap1",
            0
          ],
          "destination": [
            "0comp0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp0_1",
            0
          ],
          "destination": [
            "0comp0_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap2",
            0
          ],
          "destination": [
            "0comp0_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp0_2",
            0
          ],
          "destination": [
            "0comp0_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap3",
            0
          ],
          "destination": [
            "0comp0_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp0_3",
            0
          ],
          "destination": [
            "0comp0_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap4",
            0
          ],
          "destination": [
            "0comp0_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp0_4",
            0
          ],
          "destination": [
            "0comp0_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap5",
            0
          ],
          "destination": [
            "0comp0_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp0_5",
            0
          ],
          "destination": [
            "0comp0_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap6",
            0
          ],
          "destination": [
            "0comp0_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp0b",
            0
          ],
          "destination": [
            "0lp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp1",
            0
          ],
          "destination": [
            "0lp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp1a",
            0
          ],
          "destination": [
            "0lp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp1",
            0
          ],
          "destination": [
            "0lp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp0b",
            0
          ],
          "destination": [
            "0hp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp1",
            0
          ],
          "destination": [
            "0hp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp1a",
            0
          ],
          "destination": [
            "0hp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp1",
            0
          ],
          "destination": [
            "0hp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp1b",
            0
          ],
          "destination": [
            "0comp1_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap2",
            0
          ],
          "destination": [
            "0comp1_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp1_2",
            0
          ],
          "destination": [
            "0comp1_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap3",
            0
          ],
          "destination": [
            "0comp1_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp1_3",
            0
          ],
          "destination": [
            "0comp1_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap4",
            0
          ],
          "destination": [
            "0comp1_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp1_4",
            0
          ],
          "destination": [
            "0comp1_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap5",
            0
          ],
          "destination": [
            "0comp1_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp1_5",
            0
          ],
          "destination": [
            "0comp1_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap6",
            0
          ],
          "destination": [
            "0comp1_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp1b",
            0
          ],
          "destination": [
            "0lp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp2",
            0
          ],
          "destination": [
            "0lp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp2a",
            0
          ],
          "destination": [
            "0lp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp2",
            0
          ],
          "destination": [
            "0lp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp1b",
            0
          ],
          "destination": [
            "0hp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp2",
            0
          ],
          "destination": [
            "0hp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp2a",
            0
          ],
          "destination": [
            "0hp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp2",
            0
          ],
          "destination": [
            "0hp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp2b",
            0
          ],
          "destination": [
            "0comp2_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap3",
            0
          ],
          "destination": [
            "0comp2_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp2_3",
            0
          ],
          "destination": [
            "0comp2_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap4",
            0
          ],
          "destination": [
            "0comp2_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp2_4",
            0
          ],
          "destination": [
            "0comp2_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap5",
            0
          ],
          "destination": [
            "0comp2_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp2_5",
            0
          ],
          "destination": [
            "0comp2_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap6",
            0
          ],
          "destination": [
            "0comp2_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp2b",
            0
          ],
          "destination": [
            "0lp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp3",
            0
          ],
          "destination": [
            "0lp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp3a",
            0
          ],
          "destination": [
            "0lp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp3",
            0
          ],
          "destination": [
            "0lp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp2b",
            0
          ],
          "destination": [
            "0hp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp3",
            0
          ],
          "destination": [
            "0hp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp3a",
            0
          ],
          "destination": [
            "0hp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp3",
            0
          ],
          "destination": [
            "0hp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp3b",
            0
          ],
          "destination": [
            "0comp3_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap4",
            0
          ],
          "destination": [
            "0comp3_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp3_4",
            0
          ],
          "destination": [
            "0comp3_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap5",
            0
          ],
          "destination": [
            "0comp3_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp3_5",
            0
          ],
          "destination": [
            "0comp3_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap6",
            0
          ],
          "destination": [
            "0comp3_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp3b",
            0
          ],
          "destination": [
            "0lp4a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp4",
            0
          ],
          "destination": [
            "0lp4a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp4a",
            0
          ],
          "destination": [
            "0lp4b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp4",
            0
          ],
          "destination": [
            "0lp4b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp3b",
            0
          ],
          "destination": [
            "0hp4a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp4",
            0
          ],
          "destination": [
            "0hp4a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp4a",
            0
          ],
          "destination": [
            "0hp4b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp4",
            0
          ],
          "destination": [
            "0hp4b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp4b",
            0
          ],
          "destination": [
            "0comp4_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap5",
            0
          ],
          "destination": [
            "0comp4_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp4_5",
            0
          ],
          "destination": [
            "0comp4_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap6",
            0
          ],
          "destination": [
            "0comp4_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp4b",
            0
          ],
          "destination": [
            "0lp5a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp5",
            0
          ],
          "destination": [
            "0lp5a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp5a",
            0
          ],
          "destination": [
            "0lp5b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp5",
            0
          ],
          "destination": [
            "0lp5b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp4b",
            0
          ],
          "destination": [
            "0hp5a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp5",
            0
          ],
          "destination": [
            "0hp5a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp5a",
            0
          ],
          "destination": [
            "0hp5b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp5",
            0
          ],
          "destination": [
            "0hp5b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp5b",
            0
          ],
          "destination": [
            "0comp5_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap6",
            0
          ],
          "destination": [
            "0comp5_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp5b",
            0
          ],
          "destination": [
            "0lp6a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp6",
            0
          ],
          "destination": [
            "0lp6a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp6a",
            0
          ],
          "destination": [
            "0lp6b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp6",
            0
          ],
          "destination": [
            "0lp6b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp5b",
            0
          ],
          "destination": [
            "0hp6a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp6",
            0
          ],
          "destination": [
            "0hp6a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp6a",
            0
          ],
          "destination": [
            "0hp6b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp6",
            0
          ],
          "destination": [
            "0hp6b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            1
          ],
          "destination": [
            "1lp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp0",
            0
          ],
          "destination": [
            "1lp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp0a",
            0
          ],
          "destination": [
            "1lp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp0",
            0
          ],
          "destination": [
            "1lp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            1
          ],
          "destination": [
            "1hp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp0",
            0
          ],
          "destination": [
            "1hp0a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp0a",
            0
          ],
          "destination": [
            "1hp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp0",
            0
          ],
          "destination": [
            "1hp0b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp0b",
            0
          ],
          "destination": [
            "1comp0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap1",
            0
          ],
          "destination": [
            "1comp0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp0_1",
            0
          ],
          "destination": [
            "1comp0_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap2",
            0
          ],
          "destination": [
            "1comp0_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp0_2",
            0
          ],
          "destination": [
            "1comp0_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap3",
            0
          ],
          "destination": [
            "1comp0_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp0_3",
            0
          ],
          "destination": [
            "1comp0_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap4",
            0
          ],
          "destination": [
            "1comp0_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp0_4",
            0
          ],
          "destination": [
            "1comp0_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap5",
            0
          ],
          "destination": [
            "1comp0_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp0_5",
            0
          ],
          "destination": [
            "1comp0_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap6",
            0
          ],
          "destination": [
            "1comp0_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp0b",
            0
          ],
          "destination": [
            "1lp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp1",
            0
          ],
          "destination": [
            "1lp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp1a",
            0
          ],
          "destination": [
            "1lp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp1",
            0
          ],
          "destination": [
            "1lp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp0b",
            0
          ],
          "destination": [
            "1hp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp1",
            0
          ],
          "destination": [
            "1hp1a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp1a",
            0
          ],
          "destination": [
            "1hp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp1",
            0
          ],
          "destination": [
            "1hp1b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp1b",
            0
          ],
          "destination": [
            "1comp1_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap2",
            0
          ],
          "destination": [
            "1comp1_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp1_2",
            0
          ],
          "destination": [
            "1comp1_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap3",
            0
          ],
          "destination": [
            "1comp1_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp1_3",
            0
          ],
          "destination": [
            "1comp1_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap4",
            0
          ],
          "destination": [
            "1comp1_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp1_4",
            0
          ],
          "destination": [
            "1comp1_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap5",
            0
          ],
          "destination": [
            "1comp1_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp1_5",
            0
          ],
          "destination": [
            "1comp1_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap6",
            0
          ],
          "destination": [
            "1comp1_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp1b",
            0
          ],
          "destination": [
            "1lp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp2",
            0
          ],
          "destination": [
            "1lp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp2a",
            0
          ],
          "destination": [
            "1lp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp2",
            0
          ],
          "destination": [
            "1lp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp1b",
            0
          ],
          "destination": [
            "1hp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp2",
            0
          ],
          "destination": [
            "1hp2a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp2a",
            0
          ],
          "destination": [
            "1hp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp2",
            0
          ],
          "destination": [
            "1hp2b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp2b",
            0
          ],
          "destination": [
            "1comp2_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap3",
            0
          ],
          "destination": [
            "1comp2_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp2_3",
            0
          ],
          "destination": [
            "1comp2_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap4",
            0
          ],
          "destination": [
            "1comp2_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp2_4",
            0
          ],
          "destination": [
            "1comp2_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap5",
            0
          ],
          "destination": [
            "1comp2_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp2_5",
            0
          ],
          "destination": [
            "1comp2_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap6",
            0
          ],
          "destination": [
            "1comp2_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp2b",
            0
          ],
          "destination": [
            "1lp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp3",
            0
          ],
          "destination": [
            "1lp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp3a",
            0
          ],
          "destination": [
            "1lp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp3",
            0
          ],
          "destination": [
            "1lp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp2b",
            0
          ],
          "destination": [
            "1hp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp3",
            0
          ],
          "destination": [
            "1hp3a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp3a",
            0
          ],
          "destination": [
            "1hp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp3",
            0
          ],
          "destination": [
            "1hp3b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp3b",
            0
          ],
          "destination": [
            "1comp3_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap4",
            0
          ],
          "destination": [
            "1comp3_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp3_4",
            0
          ],
          "destination": [
            "1comp3_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap5",
            0
          ],
          "destination": [
            "1comp3_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp3_5",
            0
          ],
          "destination": [
            "1comp3_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap6",
            0
          ],
          "destination": [
            "1comp3_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp3b",
            0
          ],
          "destination": [
            "1lp4a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp4",
            0
          ],
          "destination": [
            "1lp4a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp4a",
            0
          ],
          "destination": [
            "1lp4b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp4",
            0
          ],
          "destination": [
            "1lp4b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp3b",
            0
          ],
          "destination": [
            "1hp4a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp4",
            0
          ],
          "destination": [
            "1hp4a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp4a",
            0
          ],
          "destination": [
            "1hp4b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp4",
            0
          ],
          "destination": [
            "1hp4b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp4b",
            0
          ],
          "destination": [
            "1comp4_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap5",
            0
          ],
          "destination": [
            "1comp4_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp4_5",
            0
          ],
          "destination": [
            "1comp4_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap6",
            0
          ],
          "destination": [
            "1comp4_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp4b",
            0
          ],
          "destination": [
            "1lp5a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp5",
            0
          ],
          "destination": [
            "1lp5a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp5a",
            0
          ],
          "destination": [
            "1lp5b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp5",
            0
          ],
          "destination": [
            "1lp5b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp4b",
            0
          ],
          "destination": [
            "1hp5a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp5",
            0
          ],
          "destination": [
            "1hp5a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp5a",
            0
          ],
          "destination": [
            "1hp5b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp5",
            0
          ],
          "destination": [
            "1hp5b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp5b",
            0
          ],
          "destination": [
            "1comp5_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rap6",
            0
          ],
          "destination": [
            "1comp5_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp5b",
            0
          ],
          "destination": [
            "1lp6a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp6",
            0
          ],
          "destination": [
            "1lp6a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp6a",
            0
          ],
          "destination": [
            "1lp6b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rlp6",
            0
          ],
          "destination": [
            "1lp6b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp5b",
            0
          ],
          "destination": [
            "1hp6a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp6",
            0
          ],
          "destination": [
            "1hp6a",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp6a",
            0
          ],
          "destination": [
            "1hp6b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rhp6",
            0
          ],
          "destination": [
            "1hp6b",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp0_6",
            0
          ],
          "destination": [
            "printrec",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp0_6",
            0
          ],
          "destination": [
            "printrec",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp1_6",
            0
          ],
          "destination": [
            "printrec",
            2
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp1_6",
            0
          ],
          "destination": [
            "printrec",
            3
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp2_6",
            0
          ],
          "destination": [
            "printrec",
            4
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp2_6",
            0
          ],
          "destination": [
            "printrec",
            5
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp3_6",
            0
          ],
          "destination": [
            "printrec",
            6
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp3_6",
            0
          ],
          "destination": [
            "printrec",
            7
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp4_6",
            0
          ],
          "destination": [
            "printrec",
            8
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp4_6",
            0
          ],
          "destination": [
            "printrec",
            9
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp5_6",
            0
          ],
          "destination": [
            "printrec",
            10
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp5_6",
            0
          ],
          "destination": [
            "printrec",
            11
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp6b",
            0
          ],
          "destination": [
            "printrec",
            12
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp6b",
            0
          ],
          "destination": [
            "printrec",
            13
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp6b",
            0
          ],
          "destination": [
            "printrec",
            14
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp6b",
            0
          ],
          "destination": [
            "printrec",
            15
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printphase",
            0
          ],
          "destination": [
            "printrec",
            16
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printrec",
            0
          ],
          "destination": [
            "printtime",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printtime",
            0
          ],
          "destination": [
            "printtimemsg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "printtimemsg",
            0
          ],
          "destination": [
            "printcontrol",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr0",
            0
          ],
          "destination": [
            "gainline0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr1",
            0
          ],
          "destination": [
            "gainline1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr2",
            0
          ],
          "destination": [
            "gainline2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr3",
            0
          ],
          "destination": [
            "gainline3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr4",
            0
          ],
          "destination": [
            "gainline4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr5",
            0
          ],
          "destination": [
            "gainline5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr6",
            0
          ],
          "destination": [
            "gainline6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainr7",
            0
          ],
          "destination": [
            "gainline7",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "trimr",
            0
          ],
          "destination": [
            "trimline",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dryr",
            0
          ],
          "destination": [
            "dryline",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dryline",
            0
          ],
          "destination": [
            "wetline",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp0_6",
            0
          ],
          "destination": [
            "weighted0_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline0",
            0
          ],
          "destination": [
            "weighted0_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_0",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp1_6",
            0
          ],
          "destination": [
            "weighted0_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline1",
            0
          ],
          "destination": [
            "weighted0_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_1",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp2_6",
            0
          ],
          "destination": [
            "weighted0_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline2",
            0
          ],
          "destination": [
            "weighted0_2",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_2",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp3_6",
            0
          ],
          "destination": [
            "weighted0_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline3",
            0
          ],
          "destination": [
            "weighted0_3",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_3",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp4_6",
            0
          ],
          "destination": [
            "weighted0_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline4",
            0
          ],
          "destination": [
            "weighted0_4",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_4",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0comp5_6",
            0
          ],
          "destination": [
            "weighted0_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline5",
            0
          ],
          "destination": [
            "weighted0_5",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_5",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0lp6b",
            0
          ],
          "destination": [
            "weighted0_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline6",
            0
          ],
          "destination": [
            "weighted0_6",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_6",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "0hp6b",
            0
          ],
          "destination": [
            "weighted0_7",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline7",
            0
          ],
          "destination": [
            "weighted0_7",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_7",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sum0",
            0
          ],
          "destination": [
            "wet0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "wetline",
            0
          ],
          "destination": [
            "wet0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            0
          ],
          "destination": [
            "dry0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dryline",
            0
          ],
          "destination": [
            "dry0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "wet0",
            0
          ],
          "destination": [
            "output0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dry0",
            0
          ],
          "destination": [
            "output0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "trimline",
            0
          ],
          "destination": [
            "output0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "output0",
            0
          ],
          "destination": [
            "out",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp0_6",
            0
          ],
          "destination": [
            "weighted1_0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline0",
            0
          ],
          "destination": [
            "weighted1_0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_0",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp1_6",
            0
          ],
          "destination": [
            "weighted1_1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline1",
            0
          ],
          "destination": [
            "weighted1_1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_1",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp2_6",
            0
          ],
          "destination": [
            "weighted1_2",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline2",
            0
          ],
          "destination": [
            "weighted1_2",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_2",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp3_6",
            0
          ],
          "destination": [
            "weighted1_3",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline3",
            0
          ],
          "destination": [
            "weighted1_3",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_3",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp4_6",
            0
          ],
          "destination": [
            "weighted1_4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline4",
            0
          ],
          "destination": [
            "weighted1_4",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_4",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1comp5_6",
            0
          ],
          "destination": [
            "weighted1_5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline5",
            0
          ],
          "destination": [
            "weighted1_5",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_5",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1lp6b",
            0
          ],
          "destination": [
            "weighted1_6",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline6",
            0
          ],
          "destination": [
            "weighted1_6",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_6",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "1hp6b",
            0
          ],
          "destination": [
            "weighted1_7",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gainline7",
            0
          ],
          "destination": [
            "weighted1_7",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_7",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sum1",
            0
          ],
          "destination": [
            "wet1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "wetline",
            0
          ],
          "destination": [
            "wet1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            1
          ],
          "destination": [
            "dry1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dryline",
            0
          ],
          "destination": [
            "dry1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "wet1",
            0
          ],
          "destination": [
            "output1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "dry1",
            0
          ],
          "destination": [
            "output1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "trimline",
            0
          ],
          "destination": [
            "output1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "output1",
            0
          ],
          "destination": [
            "out",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            0
          ],
          "destination": [
            "fft",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "in",
            1
          ],
          "destination": [
            "fft",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "output0",
            0
          ],
          "destination": [
            "fft",
            2
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "output1",
            0
          ],
          "destination": [
            "fft",
            3
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_0",
            0
          ],
          "destination": [
            "fft",
            4
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_0",
            0
          ],
          "destination": [
            "fft",
            5
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_1",
            0
          ],
          "destination": [
            "fft",
            6
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_1",
            0
          ],
          "destination": [
            "fft",
            7
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_2",
            0
          ],
          "destination": [
            "fft",
            8
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_2",
            0
          ],
          "destination": [
            "fft",
            9
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_3",
            0
          ],
          "destination": [
            "fft",
            10
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_3",
            0
          ],
          "destination": [
            "fft",
            11
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_4",
            0
          ],
          "destination": [
            "fft",
            12
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_4",
            0
          ],
          "destination": [
            "fft",
            13
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_5",
            0
          ],
          "destination": [
            "fft",
            14
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_5",
            0
          ],
          "destination": [
            "fft",
            15
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_6",
            0
          ],
          "destination": [
            "fft",
            16
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_6",
            0
          ],
          "destination": [
            "fft",
            17
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted0_7",
            0
          ],
          "destination": [
            "fft",
            18
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "weighted1_7",
            0
          ],
          "destination": [
            "fft",
            19
          ]
        }
      }
    ],
    "autosave": 0,
    "devicewidth": 1340,
    "latency": 0,
    "enablehscroll": 0,
    "enablevscroll": 0,
    "description": "Eight-band stereo listening and low-end spectrum workbench.",
    "digest": "BANDS \u2014 eight-band spectrum and listening",
    "tags": "audio analysis spectrum crossover bass",
    "parameters": {
      "edge0": [
        "Crossover 1",
        "Split 1",
        0
      ],
      "edge1": [
        "Crossover 2",
        "Split 2",
        0
      ],
      "edge2": [
        "Crossover 3",
        "Split 3",
        0
      ],
      "edge3": [
        "Crossover 4",
        "Split 4",
        0
      ],
      "edge4": [
        "Crossover 5",
        "Split 5",
        0
      ],
      "edge5": [
        "Crossover 6",
        "Split 6",
        0
      ],
      "edge6": [
        "Crossover 7",
        "Split 7",
        0
      ],
      "gain0": [
        "Ultra Low Gain",
        "Gain",
        0
      ],
      "solo0": [
        "Ultra Low Solo",
        "S",
        0
      ],
      "mute0": [
        "Ultra Low Mute",
        "M",
        0
      ],
      "gain1": [
        "Sub Gain",
        "Gain",
        0
      ],
      "solo1": [
        "Sub Solo",
        "S",
        0
      ],
      "mute1": [
        "Sub Mute",
        "M",
        0
      ],
      "gain2": [
        "Bass Gain",
        "Gain",
        0
      ],
      "solo2": [
        "Bass Solo",
        "S",
        0
      ],
      "mute2": [
        "Bass Mute",
        "M",
        0
      ],
      "gain3": [
        "Mids Gain",
        "Gain",
        0
      ],
      "solo3": [
        "Mids Solo",
        "S",
        0
      ],
      "mute3": [
        "Mids Mute",
        "M",
        0
      ],
      "gain4": [
        "High-Mids Gain",
        "Gain",
        0
      ],
      "solo4": [
        "High-Mids Solo",
        "S",
        0
      ],
      "mute4": [
        "High-Mids Mute",
        "M",
        0
      ],
      "gain5": [
        "Presence Gain",
        "Gain",
        0
      ],
      "solo5": [
        "Presence Solo",
        "S",
        0
      ],
      "mute5": [
        "Presence Mute",
        "M",
        0
      ],
      "gain6": [
        "High Gain",
        "Gain",
        0
      ],
      "solo6": [
        "High Solo",
        "S",
        0
      ],
      "mute6": [
        "High Mute",
        "M",
        0
      ],
      "gain7": [
        "Ultra High Gain",
        "Gain",
        0
      ],
      "solo7": [
        "Ultra High Solo",
        "S",
        0
      ],
      "mute7": [
        "Ultra High Mute",
        "M",
        0
      ],
      "trim": [
        "Output Trim",
        "Trim",
        0
      ],
      "original": [
        "Listen to Original",
        "Original",
        0
      ],
      "parameterbanks": {
        "0": {
          "index": 0,
          "name": "Mix",
          "parameters": [
            "Ultra Low Gain",
            "Sub Gain",
            "Bass Gain",
            "Mids Gain",
            "High-Mids Gain",
            "Presence Gain",
            "High Gain",
            "Ultra High Gain"
          ]
        },
        "1": {
          "index": 1,
          "name": "Crossovers",
          "parameters": [
            "Crossover 1",
            "Crossover 2",
            "Crossover 3",
            "Crossover 4",
            "Crossover 5",
            "Crossover 6",
            "Crossover 7",
            "-"
          ]
        },
        "2": {
          "index": 2,
          "name": "Solo",
          "parameters": [
            "Ultra Low Solo",
            "Sub Solo",
            "Bass Solo",
            "Mids Solo",
            "High-Mids Solo",
            "Presence Solo",
            "High Solo",
            "Ultra High Solo"
          ]
        },
        "3": {
          "index": 3,
          "name": "Mute",
          "parameters": [
            "Ultra Low Mute",
            "Sub Mute",
            "Bass Mute",
            "Mids Mute",
            "High-Mids Mute",
            "Presence Mute",
            "High Mute",
            "Ultra High Mute"
          ]
        },
        "4": {
          "index": 4,
          "name": "Output",
          "parameters": [
            "Output Trim",
            "Listen to Original",
            "-",
            "-",
            "-",
            "-",
            "-",
            "-"
          ]
        }
      },
      "inherited_shortname": 1
    },
    "dependency_cache": [
      {
        "name": "bands_control.js",
        "type": "TEXT",
        "implicit": 1
      },
      {
        "name": "bands_print.js",
        "type": "TEXT",
        "implicit": 1
      },
      {
        "name": "bands_view.js",
        "type": "TEXT",
        "implicit": 1
      },
      {
        "name": "bands_fft.maxpat",
        "type": "JSON",
        "implicit": 1
      }
    ],
    "project": {
      "version": 1,
      "amxdtype": 1633771873,
      "autoorganize": 0,
      "hideprojectwindow": 1,
      "showdependencies": 1,
      "autolocalize": 0,
      "contents": {
        "patchers": {},
        "code": {}
      },
      "layout": {},
      "searchpath": {},
      "readonly": 0,
      "devpathtype": 0,
      "devpath": "."
    }
  }
}
