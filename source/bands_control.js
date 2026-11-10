// BANDS / native MSP audio; this script only handles control messages.
autowatch = 1;
inlets = 1;
outlets = 0;
var uid = jsarguments[1];
var sr = 48000;
var edges = [30, 80, 250, 2000, 4000, 6000, 12000];
var names = ["ULTRA LOW", "SUB", "BASS", "MIDS", "HIGH-MIDS", "PRESENCE", "HIGH", "ULTRA HIGH"];
var bandCount = names.length;
var gains = [], solos = [], mutes = [];
for(var b=0;b<bandCount;b++) {gains.push(0);solos.push(0);mutes.push(0);}
function send(name, values) { messnamed(uid + "-" + name, values); }
function view() { send("view", arrayfromargs(arguments)); }
function coeff(f, rate) {
    f = Math.min(f, rate * 0.49);
    var w = 2 * Math.PI * f / rate, c = Math.cos(w), s = Math.sin(w);
    var a = s / Math.sqrt(2), a0 = 1 + a, a1 = -2 * c / a0, a2 = (1 - a) / a0;
    return {lp: [(1-c)/2/a0, (1-c)/a0, (1-c)/2/a0, a1, a2],
            hp: [(1+c)/2/a0, -(1+c)/a0, (1+c)/2/a0, a1, a2],
            ap: [a2, a1, 1, a1, a2]};
}
function crossover(i, f) {
    i = i|0; if (i < 0 || i >= edges.length || !isFinite(f)) return;
    edges[i] = f;
    send('print-command', ['edges'].concat(edges));
    var c = coeff(f, sr);
    send("lp"+i, c.lp); send("hp"+i, c.hp); send("ap"+i, c.ap);
    send("view", ["edges"].concat(edges));
    for (var k=0;k<bandCount;k++) {
        var label = this.patcher.getnamed("range"+k);
        if (label) label.message("set", k===0 ? "< "+hz(edges[0]) : k===bandCount-1 ? "> "+hz(edges[edges.length-1]) : hz(edges[k-1])+" - "+hz(edges[k]));
    }
}
function hz(f) { return f >= 1000 ? (f/1000).toFixed(1)+"k" : Math.round(f)+" Hz"; }
function samplerate(f) {
    if (f < 22050 || !isFinite(f)) return;
    sr = f;
    send('print-command', ['samplerate', sr]);
    for (var i=0;i<edges.length;i++) crossover(i,edges[i]);
    view("samplerate", sr);
}
function mix() {
    var any = 0;
    for (var i=0;i<bandCount;i++) any += solos[i];
    for (var j=0;j<bandCount;j++) {
        var active = !mutes[j] && (!any || solos[j]);
        send("gain"+j, [active ? Math.pow(10,gains[j]/20) : 0, 25]);
        view("bandstate", j, gains[j], active ? 1 : 0);
    }
}
function gain(i,v) { i=i|0; if(i<0 || i>=bandCount || !isFinite(v))return; gains[i]=Math.max(-60,Math.min(12,v)); mix(); }
// Only one listening mode may be active per band. "set" also updates the
// stored Live parameter, without feeding another event back into this script.
function solo(i,v) {
    i=i|0; if(i<0 || i>=bandCount) return;
    solos[i]=v?1:0;
    if(solos[i]) {
        mutes[i]=0;
        this.patcher.getnamed("mute"+i).message("set",0);
    }
    mix();
}
function mute(i,v) {
    i=i|0; if(i<0 || i>=bandCount) return;
    mutes[i]=v?1:0;
    if(mutes[i]) {
        solos[i]=0;
        this.patcher.getnamed("solo"+i).message("set",0);
    }
    mix();
}
function trim(v) { send("trim", [Math.pow(10,v/20),25]); }
function original(v) { send("dry",[v?1:0,25]); view("original",v); }
function command() {
    var a=arrayfromargs(arguments);
    if (a[0]==="expand") {send("open","front");return;}
    if (a[0]==="reset") {reset();return;}
    if (a[0]==="print") {send('print-command','print');return;}
    if (a[0]==="printmode") {send('print-command','mode');return;}
    send("view",a);
}
function reset() {
    for(var i=0;i<bandCount;i++) {
        this.patcher.getnamed("gain"+i).message(0);
        this.patcher.getnamed("solo"+i).message(0);
        this.patcher.getnamed("mute"+i).message(0);
    }
    this.patcher.getnamed("trim").message(0);
    this.patcher.getnamed("original").message(0);
}
function init() {
    for(var i=0;i<edges.length;i++) crossover(i,edges[i]);
    // Read saved values after live.thisdevice. A bang would toggle live.text.
    var controls=["trim","original"];
    for(var k=0;k<bandCount;k++) controls.push("gain"+k,"solo"+k,"mute"+k);
    for(var j=0;j<edges.length;j++) controls.push("edge"+j);
    for(var n=0;n<controls.length;n++) this.patcher.getnamed(controls[n]).message("outputvalue");
    view("samplerate",sr);
}
