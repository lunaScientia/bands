'use strict';
const fs=require('fs'),os=require('os'),path=require('path'),assert=require('assert/strict'),vm=require('vm');
const w=require('../source/bands_print_worker');
const root=fs.mkdtempSync(path.join(os.tmpdir(),'bands-offline-test-'));
const edges=[30,80,250,2000,4000,6000,12000];
const native={jsarguments:['bands_control.js','test']};
vm.runInNewContext(fs.readFileSync('source/bands_control.js','utf8'),native);
function fixture(kind,bits,format,channels,rate,frames) {
    const little=kind==='WAV' || kind==='sowt',bytes=bits/8,data=Buffer.alloc(frames*channels*bytes);
    const samples=Array.from({length:channels},()=>new Float64Array(frames));
    for(let n=0;n<frames;n++)for(let ch=0;ch<channels;ch++) {
        let x=(Math.sin(n*.0073)*.4+Math.cos(n*.131)*.2)*(ch?-.7:1);
        if(n===8191 || n===8192 || n===16384)x=.9;
        const p=(n*channels+ch)*bytes;
        if(format===3) {
            if(bits===32){x=Math.fround(x);data[little?'writeFloatLE':'writeFloatBE'](x,p);}
            else data[little?'writeDoubleLE':'writeDoubleBE'](x,p);
        } else {
            const scale=2**(bits-1),v=Math.round(x*scale);x=v/scale;
            if(bits===8)kind==='WAV'?data.writeUInt8(v+128,p):data.writeInt8(v,p);
            else data[little?'writeIntLE':'writeIntBE'](v,p,bytes);
        }
        samples[ch][n]=x;
    }
    let header;
    if(kind==='WAV') {
        header=w.waveHeader(channels,rate,frames);
        header.writeUInt32LE(48+data.length,4);header.writeUInt16LE(format,20);header.writeUInt32LE(rate*channels*bytes,28);
        header.writeUInt16LE(channels*bytes,32);header.writeUInt16LE(bits,34);header.writeUInt32LE(data.length,52);
    } else {
        const aifc=kind!=='AIFF',comm=aifc?22:18;
        header=Buffer.alloc(12+8+comm+16);header.write('FORM');header.writeUInt32BE(header.length+data.length+(data.length%2)-8,4);
        header.write(aifc?'AIFC':'AIFF',8);header.write('COMM',12);header.writeUInt32BE(comm,16);header.writeUInt16BE(channels,20);
        header.writeUInt32BE(frames,22);header.writeUInt16BE(bits,26);
        const exp=Math.floor(Math.log2(rate)),mantissa=rate/2**exp*2**63;
        header.writeUInt16BE(exp+16383,28);header.writeUInt32BE(Math.floor(mantissa/2**32),30);header.writeUInt32BE(mantissa%2**32,34);
        if(aifc)header.write(kind,38);
        const p=20+comm;header.write('SSND',p);header.writeUInt32BE(data.length+8,p+4);
    }
    const file=path.join(root,kind+bits+'-'+channels+'-'+rate+'-'+frames+'.audio');
    fs.writeFileSync(file,Buffer.concat([header,data,...(kind!=='WAV' && data.length%2?[Buffer.alloc(1)]:[])]));
    return {file,samples};
}
// Independent direct-form-I reference, using the actual native controller's
// coefficients. Processing whole arrays also checks state across worker blocks.
function filter(input,c) {
    const out=new Float64Array(input.length);let x1=0,x2=0,y1=0,y2=0;
    for(let n=0;n<input.length;n++) {
        const x=input[n],y=c[0]*x+c[1]*x1+c[2]*x2-c[3]*y1-c[4]*y2;
        out[n]=y;x2=x1;x1=x;y2=y1;y1=y;
    }
    return out;
}
function reference(samples,rate) {
    const c=edges.map(e=>native.coeff(e,rate)),bands=[];let high=samples;
    for(let i=0;i<7;i++) {
        let low=filter(filter(high,c[i].lp),c[i].lp);
        for(let j=i+1;j<7;j++)low=filter(low,c[j].ap);
        bands.push(low);high=filter(filter(high,c[i].hp),c[i].hp);
    }
    return bands.concat([high]);
}
function job(source){return w.createOfflineJob({source,folder:root,reference:'Source / Референс',start:3.25,edges});}
async function check(kind,bits,format,channels,rate,frames) {
    const f=fixture(kind,bits,format,channels,rate,frames),sourceBefore=fs.readFileSync(f.file),j=job(f.file),r=await w.splitOffline(j);
    assert.equal(r.frames,frames);assert.equal(r.rate,rate);assert.equal(r.files.length,8);
    const refs=f.samples.map(s=>reference(s,rate));
    for(let band=0;band<8;band++) {
        const b=fs.readFileSync(r.files[band]);
        for(let n=0;n<frames;n++)for(let ch=0;ch<2;ch++) {
            const expected=refs[channels===1?0:ch][band][n],got=b.readFloatLE(56+n*8+ch*4);
            assert(Math.abs(got-expected)<2e-7,`${kind} ${bits} rate=${rate} band=${band} frame=${n}: ${got} != ${expected}`);
        }
    }
    assert.deepEqual(fs.readFileSync(f.file),sourceBefore,'source must never be modified');
    assert(!fs.existsSync(j.decoded));return f;
}
async function main() {
    for(const rate of [22050,44100,48000,96000])await check('WAV',32,3,2,rate,17009);
    for(const bits of [8,16,24,32]) {
        await check('WAV',bits,1,1,48000,129);
        await check('AIFF',bits,1,2,48000,129);
    }
    await check('WAV',64,3,2,44100,129);
    await check('fl32',32,3,2,48000,129);await check('fl64',64,3,1,44100,129);await check('sowt',16,1,2,48000,129);
    const f=fixture('WAV',32,3,2,48000,17009),j=job(f.file);let stop=false;
    await assert.rejects(w.splitOffline(j,()=>stop,()=>{stop=true;}),/cancelled/);
    assert(fs.readdirSync(j.folder).every(n=>!n.endsWith('.part')));assert(j.files.every(p=>!fs.existsSync(p)));
    assert(fs.existsSync(f.file));assert.notEqual(job(f.file).folder,job(f.file).folder);
    const invalid=fixture('WAV',32,3,2,48000,129);const bytes=fs.readFileSync(invalid.file);bytes.writeFloatLE(NaN,56);fs.writeFileSync(invalid.file,bytes);
    const bad=job(invalid.file);await assert.rejects(w.splitOffline(bad),/invalid audio samples/);assert(fs.readdirSync(bad.folder).every(n=>!n.endsWith('.part')));
    const report={status:'PASS',checks:['four sample rates including Nyquist clamping','native coefficients and independent direct-form-I reference','continuity across disk blocks','mono duplication and stereo separation','PCM WAV/AIFF 8/16/24/32 bit','WAV/AIFC float32/float64 and little-endian AIFC','source preservation','unique outputs','cancellation cleanup','invalid sample rejection'],limitations:'Core Audio compressed-file conversion and native Live import are tested separately on macOS.'};
    fs.writeFileSync('tests/offline-worker-results.json',JSON.stringify(report,null,2)+'\n');console.log(report);
}
main().finally(()=>fs.rmSync(root,{recursive:true,force:true})).catch(e=>{console.error(e);process.exitCode=1;});
