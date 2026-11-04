// Shared renderer for the dock and pop-out. Analysis never sums L and R.
autowatch=0; inlets=1; outlets=1;
mgraphics.init(); mgraphics.relative_coords=0; mgraphics.autofill=0;
var uid=jsarguments[1], large=Number(jsarguments[2])||0;
var colors=[[0.69,0.53,1],[0.30,0.64,1],[0.22,0.85,0.76],[0.94,0.72,0.36],[0.95,0.43,0.49]];
var sr=48000, N=16384, bins=N/2, cuts=[30,80,250,2500], zoomed=1, held=0, dry=0;
var buffers=[], raw=[], smooth=[], ref=null, active=[1,1,1,1,1], meters=[-120,-120,-120,-120,-120];
var plot, buttons=[], mouse=[-1,-1], status="Play audio to analyze", peak=-120;
for(var i=0;i<7;i++) {buffers.push(new Buffer(uid+"-spec"+i));raw.push([]);smooth.push([]);}
// Only the visible view acquires data; the dock pauses while the pop-out is open.
// Buffer.peek allocates: copy no faster than one FFT hop, never from paint().
var targets=[[],[],[],[],[],[],[]], refCurve=[], mapping=[], mapKey="";
var lastRead=0, lastTick=0, dataDirty=true, refDirty=true;
function visible() {
    if(large) return this.patcher.wind.visible;
    var detail=this.patcher.getnamed("detail");
    return !(detail && detail.subpatcher().wind.visible);
}
function samplerate(v) {
    if(!isFinite(v) || v<22050) return;
    if(v!==sr) {ref=null;smooth=[[],[],[],[],[],[],[]];mapKey="";lastRead=0;}
    sr=v;
}
function edges() {cuts=arrayfromargs(arguments);}
function bandstate(i,g,a) {active[i]=a;}
function original(v) {dry=v;}
function zoom(v) {zoomed=v;mapKey="";}
function hold(v) {held=v;}
function capture() {
    var data=buffers[0].peek(1,0,bins);
    if(data && data.length===bins) {ref=data;refDirty=true;status="Reference captured from INPUT";}
}
function clearref() {ref=null;refCurve=[];}
function layout() {
    var w=box.rect[2]-box.rect[0],h=box.rect[3]-box.rect[1];
    plot={x:34,y:large?55:35,w:Math.max(1,w-46),h:Math.max(1,large?h-155:h-70),max:Math.min(zoomed?500:20000,sr/2)};
    // Bound point count even if the user stretches the window across displays.
    var count=Math.min(1536,Math.max(1,Math.floor(plot.w)));
    var key=count+":"+plot.max+":"+sr;
    if(key===mapKey)return;
    mapKey=key;mapping=[];dataDirty=true;refDirty=true;
    smooth=[[],[],[],[],[],[],[]];
    for(var x=0;x<=count;x++) {
        var f=10*Math.pow(plot.max/10,x/count),next=10*Math.pow(plot.max/10,(x+1)/count);
        var bin=Math.min(bins-1,f*N/sr),start=Math.max(1,Math.floor(bin));
        mapping.push([start,Math.min(bins-1,Math.floor(next*N/sr)),Math.max(0,bin-start),(next-f)*N/sr<1]);
    }
}
function reduce(data,out) {
    out.length=mapping.length;
    for(var x=0;x<mapping.length;x++) {
        var m=mapping[x],p=0;
        if(m[3]) p=data[m[0]]*(1-m[2])+(data[Math.min(bins-1,m[0]+1)]||0)*m[2];
        else for(var k=m[0];k<=m[1];k++) p=Math.max(p,data[k]);
        out[x]=Math.max(-120,10*Math.log(Math.max(1e-16,p*16/(N*N)))/Math.LN10);
    }
}
function bang() {
    if(!visible()) {lastTick=0;return;}
    var now=Date.now(),dt=lastTick?Math.max(1,Math.min(150,now-lastTick)):33;
    lastTick=now;layout();
    if(!held && (!lastRead || now-lastRead>=1000*N/(4*sr))) {
        lastRead=now;
        for(var c=0;c<7;c++) {
            var data=buffers[c].peek(1,0,bins);
            if(!data || data.length!==bins)continue;
            raw[c]=data;
            if(c>=2) {
                var sum=0;for(var k=1;k<bins;k++)sum+=data[k];
                meters[c-2]=10*Math.log(Math.max(1e-12,sum*16/(3*N*N)))/Math.LN10;
            }
        }
        dataDirty=true;status=raw[0].length?"Stereo power / 16k Hann":"Waiting for audio engine";
    }
    var alpha=1-Math.exp(-dt/65);
    for(var i=0;i<7;i++) {
        if(raw[i].length!==bins)continue;
        if(dataDirty)reduce(raw[i],targets[i]);
        if(!held || smooth[i].length!==targets[i].length) {
            smooth[i].length=targets[i].length;
            for(var j=0;j<targets[i].length;j++) {
                var old=smooth[i][j];smooth[i][j]=old===undefined?targets[i][j]:old+alpha*(targets[i][j]-old);
            }
        }
    }
    dataDirty=false;
    if(ref && refDirty){reduce(ref,refCurve);refDirty=false;}
    mgraphics.redraw();
}
function color(c,a) {mgraphics.set_source_rgba(c[0],c[1],c[2],a===undefined?1:a);}
function rect(x,y,w,h,c,a) {color(c,a);mgraphics.rectangle(x,y,w,h);mgraphics.fill();}
function text(t,x,y,size,c) {color(c||[0.64,0.69,0.73]);mgraphics.select_font_face("Arial");mgraphics.set_font_size(size);mgraphics.move_to(x,y);mgraphics.show_text(t);}
function line(x,y,x2,y2,c,a,width) {color(c,a);mgraphics.set_line_width(width||1);mgraphics.move_to(x,y);mgraphics.line_to(x2,y2);mgraphics.stroke();}
function freqx(f) {return plot.x+Math.log(f/10)/Math.log(plot.max/10)*plot.w;}
function dbY(db) {return plot.y+Math.max(0,Math.min(1,(6-db)/102))*plot.h;}
function fmt(f) {return f>=1000 ? (f/1000).toFixed(f%1000?1:0)+"k" : Math.round(f)+"";}
function button(label,x,y,w,cmd,val,on) {
    rect(x,y,w,19,on?[0.24,0.37,0.42]:[0.15,0.18,0.21]);
    text(label,x+7,y+13,10,on?[0.74,0.96,0.95]:[0.71,0.76,0.79]);
    buttons.push([x,y,w,19,cmd,val]);
}
// Painting only draws cached points: no FFT copies, resampling, or smoothing.
function spectrum(arr,c,idx,width) {
    if(!arr || arr.length<2)return;
    color(c,idx===0?0.42:0.92);mgraphics.set_line_width(width);
    for(var n=0;n<arr.length;n++) {
        var x=plot.x+n*plot.w/(arr.length-1);
        if(n===0)mgraphics.move_to(x,dbY(arr[n]));else mgraphics.line_to(x,dbY(arr[n]));
    }
    mgraphics.stroke();
}
function paint() {
    var w=box.rect[2]-box.rect[0],h=box.rect[3]-box.rect[1];buttons=[];
    rect(0,0,w,h,[0.065,0.085,0.105]);
    text("B A N D S",12,18,13,[0.91,0.96,0.96]);
    var bx=large?w-365:174;
    button(zoomed?"10–500 Hz":"10–20k Hz",bx,4,78,"zoom",zoomed?0:1,zoomed);
    button(held?"Resume":"Hold",bx+83,4,53,"hold",held?0:1,held);
    button("Capture",bx+141,4,60,"capture",0,!!ref);
    button("Clear",bx+206,4,45,"clearref",0,0);
    if(!large)button("Expand",bx+256,4,62,"expand",0,0);
    else text("LOW-END WORKBENCH",150,18,11,[0.4,0.51,0.57]);
    if(!plot)layout();
    var boundaries=[10,cuts[0],cuts[1],cuts[2],cuts[3],plot.max];
    for(var b=0;b<5;b++) {
        var l=Math.max(10,boundaries[b]),r=Math.min(plot.max,boundaries[b+1]);
        if(r<=l)continue;
        rect(freqx(l),plot.y,freqx(r)-freqx(l),plot.h,colors[b],0.065);
        if(large)text(["ULTRA LOW","SUB","BASS","MIDS","HIGHS"][b],freqx(l)+7,plot.y+15,10,colors[b]);
    }
    for(var d=0;d>=-96;d-=24) {var yy=dbY(d);line(plot.x,yy,plot.x+plot.w,yy,[0.45,0.52,0.56],0.15);text(""+d,4,yy+3,9);}
    var ticks=zoomed?[10,20,30,50,80,100,200,300,500]:[10,20,50,100,200,500,1000,2000,5000,10000,20000];
    for(var t=0;t<ticks.length;t++) {
        var xx=freqx(ticks[t]);line(xx,plot.y,xx,plot.y+plot.h,[0.45,0.52,0.56],0.13);
        text(fmt(ticks[t]),xx-6,plot.y+plot.h+13,9);
    }
    for(var e=0;e<4;e++) if(cuts[e]<plot.max)line(freqx(cuts[e]),plot.y,freqx(cuts[e]),plot.y+plot.h,colors[e],0.4);
    spectrum(smooth[0],[0.75,0.8,0.84],0,1);
    for(var s=0;s<5;s++) spectrum(smooth[s+2],colors[s],s+2,large?1.5:1);
    spectrum(smooth[1],[0.95,0.98,0.99],1,large?2:1.3);
    if(ref)spectrum(refCurve,[0.99,0.48,0.79],-1,1.5);
    var ly=plot.y+plot.h+28;
    text("INPUT",12,ly,9,[0.57,0.62,0.66]);text(dry?"OUTPUT · ORIGINAL":"OUTPUT",61,ly,9,[0.96,0.98,1]);
    if(ref)text("REFERENCE",dry?178:124,ly,9,[0.99,0.48,0.79]);
    if(large) {
        for(var m=0;m<5;m++) {
            var mx=20+m*(w-40)/5;
            rect(mx,h-58,(w-65)/5,42,[0.12,0.15,0.18]);
            text(["ULTRA LOW","SUB","BASS","MIDS","HIGHS"][m],mx+10,h-42,10,colors[m]);
            text((active[m]?meters[m].toFixed(1)+" dBFS RMS":"MUTED"),mx+10,h-25,12,[0.85,0.91,0.93]);
        }
        text(held?"DISPLAY HELD · audio keeps running":status+"  /  "+(sr/N).toFixed(2)+" Hz per bin",large?340:20,ly,10);
    }
    if(mouse[0]>=plot.x && mouse[0]<=plot.x+plot.w && mouse[1]>=plot.y && mouse[1]<=plot.y+plot.h) {
        var f=10*Math.pow(plot.max/10,(mouse[0]-plot.x)/plot.w);
        line(mouse[0],plot.y,mouse[0],plot.y+plot.h,[0.9,0.94,0.96],0.4);
        text(f.toFixed(1)+" Hz",Math.min(w-90,mouse[0]+7),plot.y+plot.h-7,10,[0.9,0.94,0.96]);
    }
}
function onclick(x,y) {
    for(var i=0;i<buttons.length;i++) {var b=buttons[i];if(x>=b[0]&&x<=b[0]+b[2]&&y>=b[1]&&y<=b[1]+b[3]) {outlet(0,"command",b[4],b[5]);return;}}
}
function onidle(x,y) {mouse=[x,y];}
function onidleout() {mouse=[-1,-1];}
function ondblclick(x,y) {if(y>30)outlet(0,"command","expand");}
