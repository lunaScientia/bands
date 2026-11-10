// Exercise the actual legacy-Max JS with a deterministic clock and mocked native I/O.
// This tests JS state/work bounds, not Max's native allocator or window manager.
const fs=require('fs'), vm=require('vm'), assert=require('assert');
const code=fs.readFileSync('source/bands_view.js','utf8');
let now=1000, expanded=false, reads=0, drawing=0;
const data=Array(8192).fill(0);data[10]=0.1*16384*16384/16;
function view(large) {
 const ctx={jsarguments:['bands_view.js','test',large],Date:{now:()=>now},
  Buffer:function(){this.peek=()=>{reads++;return data.slice();};},
  mgraphics:new Proxy({},{get:(_,p)=>p==='redraw'?()=>{}:()=>{drawing++;},set:()=>true}),
  box:{rect:[0,0,large?1060:530,large?560:143]},
  patcher:{wind:{get visible(){return expanded;}},getnamed:()=>({subpatcher:()=>({wind:{get visible(){return expanded;}}})})},
  arrayfromargs:a=>Array.from(a),outlet:()=>{}};
 vm.createContext(ctx);vm.runInContext(code,ctx);return ctx;
}
const dock=view(0), detail=view(1);
dock.bang();detail.bang();assert.equal(reads,10,'only dock may read when closed');
let before=reads;for(let i=0;i<100;i++)dock.paint();assert.equal(reads,before,'paint never acquires');
const smooth=JSON.stringify(dock.smooth);dock.paint();assert.equal(JSON.stringify(dock.smooth),smooth,'paint must not change smoothing');
expanded=true;now+=100;before=reads;dock.bang();detail.bang();assert.equal(reads-before,10,'only detail may read when expanded');
// Bin 10 at 48k has a known -10 dB peak, interpolated logarithmically.
assert(detail.targets[0].every(Number.isFinite));
assert(Math.abs(Math.max(...detail.targets[0])+10)<1);
before=reads;for(let i=0;i<2;i++){now+=33;detail.bang();}assert.equal(reads,before,'no redundant reads before next FFT hop');
detail.hold(1);before=reads;now+=1000;detail.bang();assert.equal(reads,before);detail.hold(0);
// Paused counterpart captures current INPUT, never stale data from before expansion.
before=reads;dock.capture();detail.capture();assert.equal(reads-before,2);assert.deepEqual(dock.ref,detail.ref);
// High-frequency zoom covers the new split points and all eight meter states.
assert.equal(detail.bandCount,8);assert.equal(detail.buffers.length,10);
detail.zoom(2);now+=100;detail.bang();
assert.equal(detail.plot.min,2000);assert.equal(detail.plot.max,24000);
for(const f of [2000,4000,6000,12000,24000])assert(detail.freqx(f)>=detail.plot.x && detail.freqx(f)<=detail.plot.x+detail.plot.w);
for(let i=0;i<8;i++){detail.bandstate(i,0,1);assert(Number.isFinite(detail.meters[i]));}
// A real bin in the Ultra High band is represented near the right place on the curve.
data.fill(0);data[6000]=0.1*16384*16384/16;now+=100;detail.bang();
assert(Math.max(...detail.targets[0])>-11);
const peakIndex=detail.targets[0].indexOf(Math.max(...detail.targets[0]));
const peakFrequency=detail.plot.min*Math.pow(detail.plot.max/detail.plot.min,peakIndex/(detail.targets[0].length-1));
assert(Math.abs(peakFrequency-6000*48000/16384)<150);
function step(i) {
 now+=33;
 if(i%400===0){expanded=!expanded;detail.zoom((i/400)%3);dock.zoom((i/400)%3);}
 if(i%1700===0){detail.samplerate(i%3400?44100:192000);dock.samplerate(i%3400?44100:192000);}
 if(i%3000===0){detail.box.rect[2]=i%6000?9000:1060;}
 dock.bang();detail.bang();
 const v=expanded?detail:dock;
 if(i%20===0)v.paint();
 for(const c of [dock,detail]) {
  assert(c.mapping.length<=1537);
  assert(c.smooth.every(a=>a.length<=1537 && a.every(Number.isFinite)));
  assert(c.raw.every(a=>a.length===0||a.length===8192));
 }
}
for(let i=0;i<2000;i++)step(i);global.gc();const start=process.memoryUsage().heapUsed;
for(let i=2000;i<22000;i++)step(i);global.gc();const end=process.memoryUsage().heapUsed;
assert(end-start<5*1024*1024,'retained JS heap growth exceeds 5MB after simulated soak');
const report={status:'PASS',simulated_minutes:22000*33/60000,buffer_reads:reads,heap_before:start,heap_after:end,checks:['visibility gating','hop-limited acquisitions','paint does not read or smooth','reference freshness','hold','sample-rate and zoom changes','bounded resize caches','finite dB values'],limitations:'Node mocks; does not establish native Max memory stability or audio dropout performance.'};
fs.writeFileSync('tests/renderer-results.json',JSON.stringify(report,null,2)+'\n');console.log(report);
