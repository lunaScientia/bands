// Exercise the actual Max JS coordinator with a deferred, stateful Live API.
const fs=require('fs'), vm=require('vm'), assert=require('assert/strict');
const source=fs.readFileSync('source/bands_print.js','utf8');
function harness(overrides={}, mode='live') {
    const writes=[], messages=[], queue=[], worker=[], tasks=[], tracks=[], clips=[];
    let now=0, ctx;
    const song={id:1,type:'Song',record_mode:0,session_record:0,back_to_arranger:0,is_ableton_link_enabled:0,
        loop_start:8.25,loop_length:2.5,tempo:120,file_path:'/tmp/Reference Project/Test Set.als',current_song_time:15,loop:1,is_playing:1,...overrides};
    const owner={id:2,type:'Track',name:'Reference',is_frozen:0,info:'function create_audio_clip'};
    const sourceClip={id:4,type:'Clip',name:'Reference File',file_path:'/tmp/Reference source.wav',is_audio_clip:1,is_arrangement_clip:1,start_time:3.25};
    tracks.push(owner);
    function resolve(path) {
        if(path==='live_set')return song;
        if(path==='this_device')return {id:3,type:'MaxDevice'};
        if(path==='live_set view detail_clip' || path==='id 4')return sourceClip;
        if(path.startsWith('live_set tracks '))return tracks[Number(path.split(' ').pop())];
        if(path.startsWith('id '))return tracks.concat(clips).find(x=>x.id===Number(path.slice(3)));
        throw Error('Unknown Live path: '+path);
    }
    class LiveAPI {
        constructor(callback,path){this.object=resolve(path);}
        get id(){return this.object?.id||0;}
        get type(){return this.object.type;}
        get info(){return this.object.info||'';}
        goto(parent){assert.equal(parent,'canonical_parent');this.object=owner;}
        get(prop){
            if(prop==='arrangement_clips')return this.object.clips?.flatMap(c=>['id',c.id])||[];
            assert(prop in this.object,'Unknown property '+prop);return [this.object[prop]];
        }
        getstring(){throw Error('Use string atoms, not quoted Max serialization');}
        getcount(prop){if(prop==='devices')return this.object.devices.length;assert.equal(prop,'tracks');return tracks.length;}
        set(prop,value){
            writes.push([this.id,prop,value]);
            if(prop==='warping')queue.push(()=>{this.object[prop]=value;});
            else this.object[prop]=value;
        }
        call(method,...args){
            writes.push([this.id,method,...args]);
            if(method==='stop_playing')song.is_playing=0;
            else if(method==='start_playing')queue.push(()=>{song.is_playing=1;});
            else if(method==='create_audio_track')tracks.push({id:100+tracks.length,type:'Track',clips:[],devices:['Default EQ','Default Utility']});
            else if(method==='delete_device')this.object.devices.splice(args[0],1);
            else if(method==='create_audio_clip') {
                const track=this.object;
                queue.push(()=>{const clip={id:200+clips.length,type:'Clip',file_path:args[0],start_time:args[1],warping:1};track.clips.push(clip);clips.push(clip);});
            } else throw Error('Unexpected call '+method);
        }
    }
    class Task {
        constructor(fn,self){this.fn=fn;this.self=self;tasks.push(this);this.pending=false;}
        schedule(ms){this.pending=true;this.delay=ms;}
        cancel(){this.pending=false;}
        repeat(){this.pending=true;}
    }
    const objects={};for(const name of ['printstatus','printbutton','printmode','printworker','printrec'])objects[name]={message:(...args)=>messages.push([name,...args])};
    ctx={jsarguments:['bands_print.js','test'],LiveAPI,Task,Date:{now:()=>now},arrayfromargs:a=>Array.from(a),
        outlet:(port,args)=>{worker.push([port,...(Array.isArray(args)?args:[args])]);},messnamed:()=>{},patcher:{getnamed:n=>{assert(objects[n],n);return objects[n];}}};
    vm.createContext(ctx);vm.runInContext(source,ctx);ctx.dspstate(1);ctx.samplerate(48000);
    ctx.sourceMode=mode;
    return {ctx,tracks,clips,song,writes,messages,worker,elapse:ms=>{now+=ms;},flush:()=>{while(queue.length)queue.shift()();},step:()=>{tasks[0].pending=false;ctx.step();},advance:(pos,ms=100)=>{now+=ms;song.current_song_time=pos;ctx.recorded(now);ctx.watch();}};
}
function start(h) {
    h.ctx.print();assert.equal(h.ctx.state,'worker');assert.equal(h.tracks.length,1);
    h.ctx.ready();assert.equal(h.ctx.state,'prepare');assert.equal(h.writes.length,0);
    h.ctx.prepared('/tmp/raw.wav','/tmp/BANDS-test');assert.equal(h.ctx.state,'settle');
    assert.equal(h.song.loop,0);h.step();assert.equal(h.ctx.state,'lead');h.ctx.recorded(200);h.step();
    assert.equal(h.ctx.state,'starting');h.step();assert.equal(h.ctx.state,'starting','wait for deferred transport start');h.flush();h.step();
    assert.equal(h.ctx.state,'recording');assert.equal(h.song.is_playing,1);
}
function record(h) {
    let p=h.ctx.config.preStart;
    while(h.ctx.state==='recording'){p+=.2;h.advance(p);}
    assert.equal(h.ctx.state,'flush');assert.equal(h.song.current_song_time,15);assert.equal(h.song.loop,1);
    assert.equal(h.tracks.length,1);h.step();assert.equal(h.ctx.state,'split');
}
const h=harness();start(h);record(h);
assert.equal(h.ctx.config.setPath,'/tmp/Reference Project/Test Set.als');
assert.equal(h.ctx.config.reference,'Reference');
const files=Array.from({length:8},(_,i)=>'/tmp/band'+i+'.wav'), labels=Array.from({length:8},(_,i)=>'Band '+i+' Hz');
h.ctx.finished(JSON.stringify({files,labels,frames:60000,rate:48000}));
for(let i=0;i<8;i++) {
    h.step();assert.equal(h.ctx.state,'clip');h.step();assert.equal(h.ctx.state,'clip','wait for deferred clip creation');h.flush();h.step();assert.equal(h.ctx.state,'warp');
    h.step();assert.equal(h.ctx.state,'warp','wait for deferred Warp change');h.flush();h.step();assert.equal(h.ctx.state,'import');
}
h.step();h.flush();assert.equal(h.ctx.state,'idle');assert.equal(h.song.is_playing,1);assert.equal(h.song.current_song_time,15);assert.equal(h.song.loop,1);
assert.equal(h.tracks.length,9);assert.equal(h.clips.length,8);
for(let i=0;i<8;i++) {
    assert.equal(h.tracks[i+1].name,'Reference — '+labels[i]);assert.equal(h.tracks[i+1].mute,1);
    assert.equal(h.tracks[i+1].devices.length,0);
    assert.equal(h.clips[i].file_path,files[i]);assert.equal(h.clips[i].warping,0);
    assert.equal(h.clips[i].loop_start,0);assert.equal(h.clips[i].loop_end,1.25);assert.equal(h.clips[i].start_time,8.25);
}
for(const fault of ['cancel','edges','samplerate','dsp','seek','stop','disk']) {
    const t=harness();start(t);
    if(fault==='cancel')t.ctx.cancel();
    if(fault==='edges')t.ctx.edges(29,80,250,2000,4000,6000,12000);
    if(fault==='samplerate')t.ctx.samplerate(44100);
    if(fault==='dsp')t.ctx.dspstate(0);
    if(fault==='seek')t.advance(100);
    if(fault==='stop'){t.song.is_playing=0;t.ctx.watch();}
    if(fault==='disk')t.ctx.failed('Disk full');
    t.flush();assert.equal(t.ctx.state,'cancel',fault);assert.equal(t.tracks.length,1);assert.equal(t.song.current_song_time,15);assert.equal(t.song.loop,1);assert.equal(t.song.is_playing,1);
    t.ctx.cancelled();assert.equal(t.ctx.state,'idle');
}
for(const [property,value] of [['record_mode',1],['session_record',1],['back_to_arranger',1],['is_ableton_link_enabled',1],['loop_length',0]]) {
    const t=harness({[property]:value});t.ctx.print();assert.equal(t.ctx.state,'idle');assert.equal(t.writes.length,0);assert.equal(t.tracks.length,1);
}
const unsaved=harness({file_path:''});unsaved.ctx.print();assert.equal(unsaved.ctx.state,'folder');assert.equal(unsaved.writes.length,0);unsaved.ctx.foldercancel();assert.equal(unsaved.ctx.state,'idle');
const stalled=harness({is_playing:0});
stalled.ctx.print();stalled.ctx.ready();stalled.ctx.prepared('/tmp/raw.wav','/tmp/BANDS-test');stalled.step();stalled.ctx.recorded(200);stalled.step();
assert.equal(stalled.ctx.state,'starting');stalled.elapse(3100);stalled.step();assert.equal(stalled.ctx.state,'cancel');assert.match(stalled.ctx.lastStatus,/Playback did not start/);
// File splitting neither starts nor stops Live, even with DSP off and Link on.
const fast=harness({is_ableton_link_enabled:1,back_to_arranger:1},'file');fast.ctx.dspstate(0);
fast.ctx.print();assert.equal(fast.ctx.state,'worker');fast.ctx.ready();assert.equal(fast.ctx.state,'split');
assert.equal(fast.writes.length,0);assert.equal(fast.ctx.config.source,'/tmp/Reference source.wav');assert.equal(fast.ctx.config.start,3.25);
assert(fast.worker.some(a=>a[1]==='offline'));
fast.ctx.edges(40,90,300,2100,4200,6200,12500);assert.equal(fast.ctx.config.edges[0],30,'file render keeps its crossover snapshot');
fast.ctx.finished(JSON.stringify({files,labels,frames:88200,rate:44100}));
for(let i=0;i<8;i++){fast.step();fast.flush();fast.step();fast.flush();fast.step();}fast.step();
assert.equal(fast.ctx.state,'idle');assert.equal(fast.clips.length,8);assert.equal(fast.song.is_playing,1);assert.equal(fast.song.current_song_time,15);
assert(!fast.writes.some(a=>a[0]===1 && a[1]!=='create_audio_track'),'no transport writes during file split');
for(const c of fast.clips){assert.equal(c.start_time,3.25);assert.equal(c.loop_end,2);assert.equal(c.warping,0);}
const cancelledFile=harness({},'file');cancelledFile.ctx.print();cancelledFile.ctx.ready();cancelledFile.ctx.cancel();cancelledFile.ctx.cancelled();
assert.equal(cancelledFile.writes.length,0);assert.equal(cancelledFile.ctx.state,'idle');
const report={status:'PASS',checks:['one-pass capture before any track creation','asynchronous clip loading and Warp change','all eight named and colored tracks','muted outputs','same arrangement position and duration','transport and loop restored','cancel, seek, DSP, crossover, sample-rate and disk failures','active recording guarded','unsaved-set folder cancellation'],limitations:'Stateful mock Live API; native host behavior needs integration verification.'};
fs.writeFileSync('tests/print-controller-results.json',JSON.stringify(report,null,2)+'\n');console.log(report);
