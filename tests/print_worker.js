'use strict';
const assert = require('assert/strict'), fs = require('fs'), os = require('os'), path = require('path');
const {prepare, split, waveHeader, waveInfo, safeName} = require('../source/bands_print_worker');
const root = fs.mkdtempSync(path.join(os.tmpdir(), 'bands-print-test-'));
const edges = [30,80,250,2000,4000,6000,12000];
function job(rate, start = 3.25, length = 2.5, preStart = 2) {
    return prepare({folder:root,reference:'Референс / reference',edges,rate,start,length,preStart});
}
function fixture(j, {seconds=4, leading=513, tempo=120, interrupt=false, extensible=false} = {}) {
    const frames=leading+Math.ceil(seconds*j.rate), step=tempo/60/j.rate;
    const fd=fs.openSync(j.raw,'w');
    const h=waveHeader(17,j.rate,frames);
    if(extensible) {
        const f=Buffer.alloc(24); f.writeUInt16LE(22);f.writeUInt16LE(32,2);f.writeUInt32LE(3,8);
        f.writeUInt16LE(16,14);f.writeUInt16LE(0x80,16);f.writeUInt32LE(0x719baa00,20);
        h.writeUInt32LE(h.readUInt32LE(4)+24,4);h.writeUInt32LE(40,16);h.writeUInt16LE(65534,20);
        fs.writeSync(fd,h.subarray(0,36));fs.writeSync(fd,f);fs.writeSync(fd,h.subarray(36));
    } else fs.writeSync(fd,h);
    const block=Buffer.alloc(1024*68);
    for(let base=0;base<frames;base+=1024) {
        const count=Math.min(1024,frames-base);
        for(let i=0;i<count;i++) {
            const frame=base+i, n=frame-leading;
            for(let ch=0;ch<16;ch++) block.writeFloatLE((frame%257-128)*(ch+1)/128,i*68+ch*4);
            let phase=n<0?0:(n*step)%1;
            if(interrupt && n>j.rate/2)phase=0;
            block.writeFloatLE(phase,i*68+64);
        }
        fs.writeSync(fd,block,0,count*68);
    }
    fs.closeSync(fd);return {frames,leading,step};
}
async function main() {
    for(const rate of [44100,48000,96000,192000]) {
        for(const start of [2,3.25]) {
            const j=job(rate,start), f=fixture(j,{extensible:rate===48000});
            const result=await split(j);
            assert.equal(result.first,f.leading+Math.round((start-j.preStart)/f.step));
            assert.equal(result.frames,Math.round(j.length/f.step));
            assert(!fs.existsSync(j.raw),'temporary capture removed after successful split');
            for(let band=0;band<8;band++) {
                const fd=fs.openSync(result.files[band],'r'), info=waveInfo(fd);
                assert.equal(info.channels,2);assert.equal(info.rate,rate);assert.equal(info.frames,result.frames);
                const sample=Buffer.alloc(8);
                for(const at of [0,1,8191,result.frames-1]) {
                    fs.readSync(fd,sample,0,8,info.offset+at*8);
                    for(let ch=0;ch<2;ch++) assert.equal(sample.readFloatLE(ch*4),Math.fround(((result.first+at)%257-128)*(band*2+ch+1)/128));
                }
                fs.closeSync(fd);
            }
        }
    }
    const broken=job(48000);fixture(broken,{interrupt:true});
    await assert.rejects(split(broken),/stopped or jumped/);
    assert(broken.files.every(p=>!fs.existsSync(p)));
    const short=job(48000);fixture(short,{seconds:.1});
    await assert.rejects(split(short),/complete Loop/);
    const cancelled=job(48000);fixture(cancelled);
    let stop=false;
    await assert.rejects(split(cancelled,()=>stop,()=>{stop=true;}),/cancelled/);
    assert(fs.readdirSync(cancelled.folder).every(n=>!n.endsWith('.part')));
    assert(cancelled.files.every(p=>!fs.existsSync(p)));
    assert.equal(safeName('../ref: test?'),'.._ref_ test_');
    assert.notEqual(job(48000).folder,job(48000).folder,'repeated prints never overwrite');
    assert.throws(()=>prepare({folder:root,rate:48000,start:0,length:1,preStart:0,edges:[1,2]}),/Invalid/);
    const report={status:'PASS',checks:['four sample rates','fractional and zero pre-roll boundaries','all 16 channels bit-identical','float samples above 0 dBFS preserved','WAVE_FORMAT_EXTENSIBLE','cancellation cleanup','incomplete capture rejected','stopped clock rejected','unique output folders'],limitations:'Synthetic host phase; native plugphasor synchronization must also be checked in Live.'};
    fs.writeFileSync('tests/print-worker-results.json',JSON.stringify(report,null,2)+'\n');console.log(report);
}
main().finally(()=>fs.rmSync(root,{recursive:true,force:true})).catch(e=>{console.error(e);process.exitCode=1;});
