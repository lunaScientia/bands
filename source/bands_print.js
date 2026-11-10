// Live API runs only on Max's low-priority queue. Audio never passes through JS.
autowatch = 0; inlets = 1; outlets = 2; // worker messages, folder chooser
var uid = jsarguments[1], state = 'idle', workerReady = false, folderPath = '';
var edgesNow = [30,80,250,2000,4000,6000,12000], rate = 48000, dspOn = 0;
var song = null, owner = null, config = null, saved = null, result = null;
var started = 0, lastPosition = 0, lastTick = 0, recordMs = 0, lastRecordMs = 0, stallTicks = 0;
var importIndex = 0, imported = [], pendingTrack = null, pendingClip = null, importWait = 0;
var ownsTransport = false, currentFolder = '', lastError = '', startJob = false;
var lastStatus = 'Print Loop -> 8 tracks / pre-gain';
function getvalueof() {return [state,lastStatus];}
var colors = [0xb087ff,0x4da3ff,0x38d9c2,0xf0b85c,0xfa9152,0xf26e7d,0xe67ac9,0xa8c7f7];
var stepTask = new Task(step, this), watchdog = new Task(watch, this);
watchdog.interval = 100;
function obj(name) {return this.patcher.getnamed(name);}
function worker() {outlet(0, arrayfromargs(arguments));}
function stopWorker() {workerReady=false;obj('printworker').message('script','stop');}
function number(api, prop) {return Number(api.get(prop));}
function string(api, prop) {return api.getstring(prop);}
function api(path) {return new LiveAPI(null, path);}
function message(text) {
    text = String(text);
    lastStatus=text;
    obj('printstatus').message('set', text);
    obj('printstatus').message('hint', text);
    obj('printbutton').message('text', state === 'idle' ? 'Print Bands' : 'Cancel Print');
    messnamed(uid + '-view', ['printstatus', state !== 'idle' ? 1 : 0, text]);
}
function schedule(next, delay) {state = next; stepTask.cancel(); stepTask.schedule(delay || 100);}
function ready() {workerReady = true; if(state === 'worker') begin();}
function samplerate(v) {
    if (isFinite(v) && v >= 22050) {
        if (activeCapture() && rate !== v) fail('Sample rate changed. Print cancelled.');
        rate = v;
    }
}
function dspstate(v) {dspOn = v ? 1 : 0; if(!dspOn && activeCapture()) fail('Audio engine stopped. Print cancelled.');}
function recorded(v) {recordMs = Number(v);}
function edges() {
    var a = arrayfromargs(arguments);
    if(a.length !== 7) return;
    if((activeCapture() || state==='prepare' || state==='worker') && config) {
        for(var i=0;i<7;i++) if(Math.abs(a[i]-config.edges[i]) > .001) {fail('Crossovers changed. Set them, then print again.'); break;}
    }
    edgesNow = a;
}
function activeCapture() {return state === 'settle' || state === 'lead' || state === 'recording';}
function findOwner() {
    var a = api('this_device');
    for(var depth=0;depth<12 && a.id;depth++) {
        if(a.type === 'Track') return a;
        a.goto('canonical_parent');
    }
    throw Error('Place BANDS on a track in Ableton Live.');
}
function choosefolder() {if(state === 'idle') {startJob=false;outlet(1,'bang');}}
function folder() {
    folderPath = arrayfromargs(arguments).join(' ');
    if(state === 'folder') {state='idle'; if(startJob) print();}
    else message('Output folder selected / Print Loop -> 8 tracks');
}
function foldercancel() {if(state === 'folder') {state='idle';startJob=false;message('Folder selection cancelled.');}}
function print() {
    if(state !== 'idle') {cancel();return;}
    imported=[];result=null;
    try {
        song = api('live_set'); owner = findOwner();
        if(!song.id || !owner.id) throw Error('Print Bands requires Ableton Live.');
        if(!dspOn) throw Error('Turn on Live\'s audio engine first.');
        if(number(song,'record_mode') || number(song,'session_record')) throw Error('Stop Arrangement / Session recording first.');
        if(number(song,'back_to_arranger')) throw Error('Use Back to Arrangement before printing.');
        if(number(song,'is_ableton_link_enabled')) throw Error('Turn Link off before printing the Loop range.');
        if(number(owner,'is_frozen')) throw Error('Unfreeze the source track first.');
        if(String(owner.info).indexOf('create_audio_clip') < 0) throw Error('This Live version cannot import audio through the Live API.');
        var start = number(song,'loop_start'), length = number(song,'loop_length'), tempo = number(song,'tempo');
        if(!isFinite(start) || start<0 || !isFinite(length) || length<=0 || !isFinite(tempo) || tempo<=0) throw Error('Set a valid Arrangement Loop range first.');
        var preStart = Math.max(0,Math.floor(start - Math.max(2,tempo/60)));
        // Keep native RIFF recordings below 4 GiB, including pre-roll and padding.
        if((start+length-preStart)*60/tempo*rate*68 > 2.8*1024*1024*1024) throw Error('Loop is too long for one print. Select a shorter section.');
        var setPath = string(song,'file_path');
        if(!folderPath && !setPath) {state='folder';startJob=true;message('Choose where to save the eight WAV files.');outlet(1,'bang');return;}
        config = {start:start,length:length,preStart:preStart,rate:rate,edges:edgesNow.slice(0),reference:string(owner,'name'),folder:folderPath,setPath:setPath};
        saved = null; result = null; imported = []; pendingTrack = null; pendingClip = null; currentFolder=''; lastError='';
        if(!workerReady) {
            state='worker'; message('Starting Print Bands...');
            obj('printworker').message('script','start');
            stepTask.schedule(15000);
        } else begin();
    } catch(e) {fail(e.message);}
}
function begin() {
    stepTask.cancel(); state='prepare'; message('Preparing files...');
    worker('prepare',JSON.stringify(config)); stepTask.schedule(15000);
}
function prepared(raw, directory) {
    if(state !== 'prepare') {worker('cancel');return;}
    try {
        stepTask.cancel(); currentFolder = directory;
        // Snapshot only after disk preparation succeeds. No track edits until import.
        saved = {position:number(song,'current_song_time'),loop:number(song,'loop'),playing:number(song,'is_playing')};
        ownsTransport = true;
        song.call('stop_playing'); song.set('loop',0); song.set('current_song_time',config.preStart);
        obj('printrec').message('samptype','float32');
        obj('printrec').message('open',raw,'wave');
        message('Preparing transport / all 8 bands, pre-gain'); schedule('settle',250);
    } catch(e) {fail(e.message);}
}
function step() {
    try {
        if(state === 'worker') throw Error('Print worker did not start. Reopen the device and try again.');
        if(state === 'prepare') throw Error('Could not prepare output files.');
        if(state === 'settle') {
            if(number(song,'is_playing')) throw Error('Transport could not stop.');
            song.set('current_song_time',config.preStart);
            recordMs = 0; lastRecordMs=0; stallTicks=0;
            obj('printrec').message(1); schedule('lead',250);return;
        }
        if(state === 'lead') {
            if(recordMs <= 0) throw Error('Disk recording did not start. Check the output folder and audio engine.');
            song.call('start_playing'); state='recording'; started=Date.now(); lastPosition=config.preStart; lastTick=started;
            watchdog.repeat(); message('Printing all 8 bands...');return;
        }
        if(state === 'flush') {schedule('split',120000);message('Writing eight WAV files...');worker('finish');return;}
        if(state === 'split') throw Error('File processing timed out. Cancel and try a shorter Loop.');
        if(state === 'import') {importNext();return;}
        if(state === 'clip') {configureClip();return;}
        if(state === 'warp') {finishClip();return;}
        if(state === 'cancel') {stopWorker();state='idle';message(lastError || 'Print cancelled.');return;}
    } catch(e) {fail(e.message);}
}
function watch() {
    if(state !== 'recording') return;
    try {
        var now=Date.now(), position=number(song,'current_song_time'), tempo=number(song,'tempo');
        var elapsed=(now-lastTick)/1000, expected=elapsed*tempo/60;
        if(!dspOn || !number(song,'is_playing')) throw Error('Playback stopped. Print cancelled.');
        if(position < lastPosition-.02 || position-lastPosition > expected+Math.max(.5,tempo/60*.25)) throw Error('Transport jumped. Print cancelled.');
        if(number(song,'loop')) throw Error('Loop playback was enabled during printing. Try again.');
        if(recordMs <= lastRecordMs) stallTicks++; else stallTicks=0;
        if(stallTicks > 20) throw Error('Disk recording stopped. Check free disk space.');
        if(recordMs*rate*68/1000 > 3*1024*1024*1024) throw Error('Capture limit reached. Select a shorter Loop.');
        lastRecordMs=recordMs; lastPosition=position;lastTick=now;
        var percent=Math.max(0,Math.min(100,Math.floor((position-config.start)/config.length*100)));
        message(position<config.start?'Pre-roll / warming crossover filters...':'Printing all 8 bands / '+percent+'%');
        // Extra quarter beat gives the marker scanner an unambiguous end boundary.
        if(position >= config.start+config.length+.25) {
            watchdog.cancel(); obj('printrec').message(0); song.call('stop_playing');
            restore(false); schedule('flush',500);
        }
        if(now-started > 30*60*1000) throw Error('Print timed out. Select a shorter Loop.');
    } catch(e) {fail(e.message);}
}
function progress(v) {if(state==='split'){stepTask.cancel();stepTask.schedule(120000);message('Writing WAV files / '+v+'%');}}
function finished(json) {
    if(state !== 'split') return;
    try {
        result=JSON.parse(json);
        if(result.files.length!==8 || result.labels.length!==8 || result.frames<=0) throw Error('Incomplete band files.');
        importIndex=0; message('Creating tracks / 0 of 8'); schedule('import',20);
    } catch(e) {fail(e.message);}
}
function importNext() {
    if(importIndex===8) {
        stopWorker();state='idle';restore(true);
        message('Done / 8 tracks created (muted) / WAVs saved');return;
    }
    // Append so existing track indices, groups and routing stay intact.
    var count=song.getcount('tracks');
    song.call('create_audio_track',-1);
    pendingTrack=api('live_set tracks '+count);
    if(!pendingTrack.id || song.getcount('tracks')!==count+1) throw Error('Live could not create the next audio track.');
    imported.push(Number(pendingTrack.id));
    pendingTrack.set('mute',1); // Keep printed audio from doubling the project mix.
    // A user's default Audio Track can contain EQs/effects. Printed files should
    // not be processed a second time; only this newly created track is touched.
    for(var d=pendingTrack.getcount('devices')-1;d>=0;d--) pendingTrack.call('delete_device',d);
    pendingTrack.set('name',config.reference+' — '+result.labels[importIndex]);
    pendingTrack.set('color',colors[importIndex]);
    pendingTrack.call('create_audio_clip',result.files[importIndex],config.start);
    importWait=0; schedule('clip',100);
}
function configureClip() {
    if(!pendingTrack || !pendingTrack.id) throw Error('A printed track was removed during import.');
    var ids=pendingTrack.get('arrangement_clips'), clipId=0;
    for(var i=0;i<ids.length-1;i++) if(ids[i]==='id') {clipId=Number(ids[i+1]);break;}
    if(!clipId) {
        if(++importWait>50) throw Error('Live could not load a printed WAV. Files are saved in the output folder.');
        schedule('clip',100);return;
    }
    pendingClip=api('id '+clipId);
    pendingClip.set('name',result.labels[importIndex]);
    pendingClip.set('color',colors[importIndex]);
    pendingClip.set('looping',0);
    pendingClip.set('warping',0); // Deferred by Live; wait before setting markers.
    importWait=0;schedule('warp',100);
}
function finishClip() {
    if(number(pendingClip,'warping')) {
        if(++importWait>50) throw Error('Live could not disable Warp for a printed clip.');
        schedule('warp',100);return;
    }
    // For unlooped, unwarped clips these are clip start/end in seconds.
    pendingClip.set('loop_start',0);
    pendingClip.set('loop_end',result.frames/result.rate);
    if(Math.abs(number(pendingClip,'start_time')-config.start)>.0001) throw Error('Live placed the clip at an unexpected position.');
    importIndex++;pendingClip=null;pendingTrack=null;
    message('Creating tracks / '+importIndex+' of 8');schedule('import',20);
}
function restore(resume) {
    if(!saved || !ownsTransport) return;
    song.set('loop',saved.loop);song.set('current_song_time',saved.position);
    if(resume) {
        ownsTransport=false;
        if(saved.playing) song.call('start_playing');
    }
}
function cancel() {if(state==='idle')return;fail('Print cancelled.');}
function failed() {fail(arrayfromargs(arguments).join(' '));}
function cancelled() {if(state==='cancel') {stepTask.cancel();stopWorker();state='idle';message(lastError || 'Print cancelled.');}}
function fail(reason) {
    var hadJob=state!=='idle' && state!=='folder';
    stepTask.cancel();watchdog.cancel();lastError=String(reason || 'Print failed.');
    try {obj('printrec').message(0);}catch(_){}
    try {if(ownsTransport) {song.call('stop_playing');restore(true);}}catch(_) {ownsTransport=false;}
    if(imported.length && result) lastError+=' WAVs saved; '+imported.length+' track(s) created.';
    state=hadJob?'cancel':'idle';message(lastError);
    if(hadJob) {worker('cancel');stepTask.schedule(2000);}
}
function notifydeleted() {
    stepTask.cancel();watchdog.cancel();
    try {obj('printrec').message(0);if(ownsTransport){song.call('stop_playing');restore(true);}}catch(_){}
    if(workerReady) worker('cancel');
}
