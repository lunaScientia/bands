#!/usr/bin/env python3
"""Reproducible Max 8/9 patcher and audio-effect AMXD builder (stdlib only)."""
import json, math, pathlib, struct, shutil
ROOT=pathlib.Path(__file__).resolve().parent
SRC=ROOT/'source'; DIST=ROOT/'dist'
VERSION='1.2.0'
COLORS=[[.69,.53,1,1],[.30,.64,1,1],[.22,.85,.76,1],[.94,.72,.36,1],
        [.98,.57,.32,1],[.95,.43,.49,1],[.90,.48,.79,1],[.66,.78,.97,1]]
EDGES=[30,80,250,2000,4000,6000,12000]
LIMITS=[(15,49),(50,139),(140,599),(600,2999),(3000,4999),(5000,9999),(10000,18000)]
NAMES=['Ultra Low','Sub','Bass','Mids','High-Mids','Presence','High','Ultra High']
BAND_COUNT=len(NAMES)
SPECTRA=BAND_COUNT+2
WIDTH=1340

class Patch:
    def __init__(self, width=WIDTH, height=169, presentation=0):
        self.p={'fileversion':1,'appversion':{'major':9,'minor':1,'revision':0,'architecture':'x64','modernui':1},
                'classnamespace':'box','rect':[80.,100.,float(width),float(height)],
                'openrect':[0.,0.,float(width),float(height)],'openinpresentation':presentation,
                'default_fontsize':11.,'default_fontname':'Arial','bgcolor':[.065,.085,.105,1.],
                'bglocked':1,'boxes':[],'lines':[],'autosave':0}
        self.ids=set()
    def box(self,id,cls='newobj',text=None,rect=None,ins=1,outs=1,pres=None,**kw):
        assert id not in self.ids,id
        self.ids.add(id)
        b={'id':id,'maxclass':cls,'numinlets':ins,'numoutlets':outs,
           'patching_rect':rect or [30.,220.+len(self.ids)*28,170.,22.]}
        if text is not None:b['text']=text
        if pres is not None:b.update(presentation=1,presentation_rect=pres)
        b.update(kw);self.p['boxes'].append({'box':b});return id
    def wire(self,src,dst,out=0,inp=0):
        self.p['lines'].append({'patchline':{'source':[src,out],'destination':[dst,inp]}})
    def obj(self,id,text,ins=1,outs=1,**kw):return self.box(id,text=text,ins=ins,outs=outs,**kw)
    def save(self,path):path.write_text(json.dumps({'patcher':self.p},indent=2)+'\n')

def coeff(f,sr=48000):
    f=min(f,sr*.49)
    w=2*math.pi*f/sr;c=math.cos(w);a=math.sin(w)/math.sqrt(2);a0=1+a;a1=-2*c/a0;a2=(1-a)/a0
    return {'lp':[(1-c)/2/a0,(1-c)/a0,(1-c)/2/a0,a1,a2],
            'hp':[(1+c)/2/a0,-(1+c)/a0,(1+c)/2/a0,a1,a2], 'ap':[a2,a1,1,a1,a2]}

def build():
    DIST.mkdir(exist_ok=True)
    p=Patch(presentation=1)
    p.p.update(devicewidth=WIDTH,latency=0,enablehscroll=0,enablevscroll=0,
               description='Eight-band stereo listening and low-end spectrum workbench.',
               digest='BANDS — eight-band spectrum and listening',tags='audio analysis spectrum crossover bass')
    p.obj('in','plugin~',2,2,rect=[30,200,70,22]);p.obj('out','plugout~',2,2)
    p.obj('control','js bands_control.js #0',1,0)
    p.obj('printcontrol','js bands_print.js #0',1,2)
    p.obj('printbus','r #0-print-command');p.wire('printbus','printcontrol')
    # node.codebox embeds its executable source directly. A node.script pointing
    # at a TEXT entry in a collective cannot reliably materialize that file.
    p.box('printworker','node.codebox',ins=1,outs=2,varname='printworker',
          code=(SRC/'bands_print_worker.js').read_text(),
          saved_object_attributes={'autostart':0,'defer':1,'watch':0,'restart':0})
    p.wire('printcontrol','printworker');p.wire('printworker','printcontrol')
    p.obj('printdialog','opendialog fold',1,2);p.wire('printcontrol','printdialog',1)
    p.obj('printfoldermsg','prepend folder');p.wire('printdialog','printfoldermsg');p.wire('printfoldermsg','printcontrol')
    p.box('printdialogcancel','message',text='foldercancel');p.wire('printdialog','printdialogcancel',1);p.wire('printdialogcancel','printcontrol')
    p.obj('viewbus','r #0-view');p.obj('cmd','r #0-command');p.wire('cmd','control')
    p.box('view','jsui',rect=[0,0,530,143],pres=[0,0,530,143],filename='bands_view.js',jsarguments=['#0',0],
          parameter_enable=0,border=0)
    p.wire('viewbus','view');p.wire('view','control')
    p.obj('clock','qmetro 33');p.obj('clockon','loadmess 1');p.wire('clockon','clock');p.wire('clock','view')
    p.obj('dev','live.thisdevice',1,3);p.obj('defer','deferlow');p.obj('init','t b b',1,2)
    p.wire('dev','defer');p.wire('defer','init')
    p.obj('initmsg','prepend init');p.wire('init','initmsg');p.wire('initmsg','control')
    # Standalone patch initialization; live.thisdevice re-bangs restored Live state later.
    p.obj('load','loadbang');p.obj('loaddefer','deferlow');p.wire('load','loaddefer');p.wire('loaddefer','init')
    p.obj('dsp','dspstate~',1,6);p.obj('sr','prepend samplerate');p.wire('dsp','sr',1);p.wire('sr','control')
    p.obj('printdsp','prepend dspstate');p.wire('dsp','printdsp');p.wire('printdsp','printcontrol')
    p.wire('init','dsp',1)
    params={}; ordered=[]
    def parameter(id,cls,long,short,lo,hi,initial,units,rect,color=None,enum=None,**kw):
        a={'parameter_longname':long,'parameter_shortname':short,'parameter_type':2 if enum else 0,
           'parameter_mmin':float(lo),'parameter_mmax':float(hi),'parameter_initial':[float(initial)],
           'parameter_initial_enable':1,'parameter_unitstyle':units}
        if enum:a['parameter_enum']=enum
        if color:kw.update(activefgdialcolor=color,activeneedlecolor=color)
        p.box(id,cls,rect=rect,pres=rect,outs=2,parameter_enable=1,varname=id,
              saved_attribute_attributes={'valueof':a},fontsize=10.,**kw)
        params[id]=[long,short,0];ordered.append(long)
    def route(id,selector):
        p.obj(id+'msg','prepend '+selector);p.wire(id,id+'msg');p.wire(id+'msg','control')
    def comment(id,t,r,color=[.62,.68,.72,1],size=10):
        p.box(id,'comment',text=t,rect=r,pres=r,outs=0,textcolor=color,fontsize=size,
              varname=id,ignoreclick=1)
    comment('splits','SPLITS / Hz',[12,146,65,18],size=9)
    for i,f in enumerate(EDGES):
        parameter('edge'+str(i),'live.numbox','Crossover '+str(i+1),'Split '+str(i+1),*LIMITS[i],f,3,[80+i*63,146,58,18])
        p.obj('fpack'+str(i),'pack 0. 60');p.obj('fline'+str(i),'line '+str(f)+'. 10',2,2)
        p.wire('edge'+str(i),'fpack'+str(i));p.wire('fpack'+str(i),'fline'+str(i))
        p.obj('fmsg'+str(i),'prepend crossover '+str(i));p.wire('fline'+str(i),'fmsg'+str(i));p.wire('fmsg'+str(i),'control')
    for i,name in enumerate(NAMES):
        x=542+i*83
        p.box('stripe'+str(i),'panel',rect=[x,7,75,3],pres=[x,7,75,3],outs=0,bgcolor=COLORS[i],border=0)
        comment('label'+str(i),name.upper(),[x,16,80,17],COLORS[i],10)
        comment('range'+str(i),'',[x,34,80,17],size=9)
        parameter('gain'+str(i),'live.dial',name+' Gain','Gain',-60,12,0,4,[x+8,58,60,60],COLORS[i],showname=0)
        route('gain'+str(i),'gain '+str(i))
        for kind,dx,label in [('solo',0,'S'),('mute',40,'M')]:
            parameter(kind+str(i),'live.text',name+' '+kind.title(),label,0,1,0,0,[x+dx,125,35,20],
                      enum=['Off','On'],text=label,texton=label,activebgoncolor=COLORS[i],activebgcolor=[.16,.19,.22,1],
                      bgcolor=[.16,.19,.22,1],textcolor=[.7,.76,.8,1],textoncolor=[.07,.09,.11,1])
            route(kind+str(i),kind+' '+str(i))
    output_x=542+BAND_COUNT*83+12
    comment('trimtitle','OUTPUT',[output_x+3,15,95,18],size=10)
    parameter('trim','live.dial','Output Trim','Trim',-24,12,0,4,[output_x+16,52,60,61],showname=0)
    route('trim','trim')
    parameter('original','live.text','Listen to Original','Original',0,1,0,0,[output_x,122,99,21],enum=['Bands','Original'],
              text='Original',texton='Original',activebgoncolor=[.45,.62,.64,1],activebgcolor=[.16,.19,.22,1],textoncolor=[.06,.08,.1,1])
    route('original','original')
    p.box('reset','textbutton',text='Reset mix',rect=[output_x,148,99,17],pres=[output_x,148,99,17],outs=3,parameter_enable=0,fontsize=9)
    p.box('resetmsg','message',text='command reset');p.wire('reset','resetmsg');p.wire('resetmsg','control')
    comment('printstatus','Print Loop -> 8 tracks / pre-gain',[547,149,450,16],size=9)
    for id,label,x,w,selector in [('printbutton','Print Bands',1005,110,'print'),('printfolder','Folder...',1120,79,'choosefolder')]:
        p.box(id,'textbutton',text=label,rect=[x,148,w,17],pres=[x,148,w,17],outs=3,parameter_enable=0,fontsize=9,varname=id)
        p.box(id+'click','message',text=selector);p.wire(id,id+'click');p.wire(id+'click','printcontrol')
    # LR4 splits. Every earlier branch gets the all-pass of each later split.
    for i in range(len(EDGES)):
        for kind in ['lp','hp','ap']:p.obj('r'+kind+str(i),'r #0-'+kind+str(i))
    def bq(id,src,kind,i):
        args=' '.join(format(v,'.17g') for v in coeff(EDGES[i])[kind])
        p.obj(id,'biquad~ '+args,6,1)
        p.wire(src[0],id,src[1]);p.wire('r'+kind+str(i),id)
        return(id,0)
    bands=[[],[]]
    for ch in range(2):
        high=('in',ch)
        for i in range(len(EDGES)):
            low=bq(f'{ch}lp{i}a',high,'lp',i);low=bq(f'{ch}lp{i}b',low,'lp',i)
            next_high=bq(f'{ch}hp{i}a',high,'hp',i);next_high=bq(f'{ch}hp{i}b',next_high,'hp',i)
            for j in range(i+1,len(EDGES)):low=bq(f'{ch}comp{i}_{j}',low,'ap',j)
            bands[ch].append(low);high=next_high
        bands[ch].append(high)
    # One interleaved stream guarantees identical sample boundaries for all bands.
    # The last channel records Live's sample-synchronous beat phase for trimming.
    p.obj('printrec','sfrecord~ 17 262144 @beginramp 0 @endramp 0',17,1,varname='printrec')
    for i in range(BAND_COUNT):
        for ch in range(2):p.wire(bands[ch][i][0],'printrec',bands[ch][i][1],i*2+ch)
    p.obj('printphase','plugphasor~',0,1);p.wire('printphase','printrec',0,16)
    p.obj('printtime','snapshot~ 100',2,1);p.wire('printrec','printtime')
    p.obj('printtimemsg','prepend recorded');p.wire('printtime','printtimemsg');p.wire('printtimemsg','printcontrol')
    for i in range(BAND_COUNT):
        p.obj('gainr'+str(i),'r #0-gain'+str(i));p.obj('gainline'+str(i),'line~ 1.',2,2)
        p.wire('gainr'+str(i),'gainline'+str(i))
    p.obj('trimr','r #0-trim');p.obj('trimline','line~ 1.',2,2);p.wire('trimr','trimline')
    p.obj('dryr','r #0-dry');p.obj('dryline','line~ 0.',2,2);p.wire('dryr','dryline')
    p.obj('wetline','!-~ 1.',2,1);p.wire('dryline','wetline')
    weighted=[[],[]];output=[]
    for ch in range(2):
        p.obj('sum'+str(ch),'+~',2,1)
        for i,source in enumerate(bands[ch]):
            id=f'weighted{ch}_{i}';p.obj(id,'*~',2,1)
            p.wire(source[0],id,source[1]);p.wire('gainline'+str(i),id,0,1);p.wire(id,'sum'+str(ch))
            weighted[ch].append(id)
        p.obj('wet'+str(ch),'*~',2,1);p.wire('sum'+str(ch),'wet'+str(ch));p.wire('wetline','wet'+str(ch),0,1)
        p.obj('dry'+str(ch),'*~',2,1);p.wire('in','dry'+str(ch),ch);p.wire('dryline','dry'+str(ch),0,1)
        p.obj('output'+str(ch),'*~',2,1);p.wire('wet'+str(ch),'output'+str(ch));p.wire('dry'+str(ch),'output'+str(ch))
        p.wire('trimline','output'+str(ch),0,1);p.wire('output'+str(ch),'out',0,ch);output.append('output'+str(ch))
    # Stereo power spectra: input, actual output, then all post-gain bands.
    for i in range(SPECTRA):p.obj('buffer'+str(i),'buffer~ #0-spec'+str(i)+' @samps 8192',1,2)
    p.obj('fft','pfft~ bands_fft 16384 4 args #0',2*SPECTRA,0)
    p.wire('in','fft',0,0);p.wire('in','fft',1,1)
    for ch in range(2):p.wire(output[ch],'fft',0,2+ch)
    for i in range(BAND_COUNT):
        for ch in range(2):p.wire(weighted[ch][i],'fft',0,4+2*i+ch)
    # Separate window with the same instance-local analysis buffers and messages.
    detail=Patch(1060,560,1)
    detail.box('scope','jsui',rect=[0,0,1060,560],pres=[0,0,1060,560],filename='bands_view.js',
               jsarguments=['#0',1],parameter_enable=0,border=0)
    detail.obj('recv','r #0-view');detail.wire('recv','scope')
    detail.obj('clk','qmetro 33');detail.obj('on','loadmess 1');detail.wire('on','clk');detail.wire('clk','scope')
    detail.obj('cmd','s #0-command',1,0);detail.wire('scope','cmd')
    detail.obj('window','thispatcher',1,2);detail.obj('front','r #0-open')
    # topmost must follow front: Max ignores it until the window has been visible.
    detail.box('show','message',text='window flags float, window exec, front, topmost 1')
    detail.wire('front','show');detail.wire('show','window')
    detail.obj('windowload','loadbang')
    detail.box('windowinit','message',text='window flags float, window exec')
    detail.wire('windowload','windowinit');detail.wire('windowinit','window')
    p.obj('detail','p BANDS — Spectrum',1,0,varname='detail',patcher=detail.p)
    # Human navigable source; DSP boxes laid out in columns below the presentation.
    index=0
    for wrap in p.p['boxes']:
        b=wrap['box']
        if not b.get('presentation'):
            b['patching_rect']=[30+(index%6)*280,220+(index//6)*65,250,22];index+=1
    p.p['parameters']={**params,'parameterbanks':{str(i):{'index':i,'name':name,'parameters':bank}
        for i,(name,bank) in enumerate([
            ('Mix',[n+' Gain' for n in NAMES]),
            ('Crossovers',['Crossover '+str(i+1) for i in range(len(EDGES))]+['-']),
            ('Solo',[n+' Solo' for n in NAMES]),
            ('Mute',[n+' Mute' for n in NAMES]),
            ('Output',['Output Trim','Listen to Original']+['-']*6)])},'inherited_shortname':1}
    p.p['dependency_cache']=[{'name':'bands_control.js','type':'TEXT','implicit':1},
                              {'name':'bands_print.js','type':'TEXT','implicit':1},
                              {'name':'bands_view.js','type':'TEXT','implicit':1},
                              {'name':'bands_fft.maxpat','type':'JSON','implicit':1}]
    p.p['project']={'version':1,'amxdtype':1633771873,'autoorganize':0,'hideprojectwindow':1,
                    'showdependencies':1,'autolocalize':0,'contents':{'patchers':{},'code':{}},
                    'layout':{},'searchpath':{},'readonly':0,'devpathtype':0,'devpath':'.'}
    fft=Patch(1200,700)
    for i in range(SPECTRA):
        for ch in range(2):
            id=f'fft{i}_{ch}';fft.obj(id,f'fftin~ {2*i+ch+1} hanning',1,3)
            for part in range(2):
                sq=f'sq{i}_{ch}_{part}';fft.obj(sq,'*~',2,1)
                fft.wire(id,sq,part,0);fft.wire(id,sq,part,1)
        fft.obj('power'+str(i),'*~ 0.5',2,1)
        for ch in range(2):
            for part in range(2):fft.wire(f'sq{i}_{ch}_{part}','power'+str(i))
        fft.obj('poke'+str(i),f'poke~ #1-spec{i}',3,0)
        fft.wire('power'+str(i),'poke'+str(i));fft.wire(f'fft{i}_0','poke'+str(i),2,1)
    fft.save(SRC/'bands_fft.maxpat')
    # Max for Live's --- prefix is per device; #0 alone is only per abstraction.
    p.p=json.loads(json.dumps(p.p).replace('#0','---bands'))
    p.save(SRC/'BANDS.maxpat')
    # Standard, uncompressed Audio Effect container as used by Ableton's template.
    data=(json.dumps({'patcher':p.p},indent=2)+'\n').encode()+b'\0'
    amxd=b'ampf'+struct.pack('<I',4)+b'aaaa'+b'meta'+struct.pack('<II',4,0)+b'ptch'+struct.pack('<I',len(data))+data
    (DIST/'BANDS.amxd').write_bytes(amxd)
    for file in ['bands_control.js','bands_view.js','bands_fft.maxpat','bands_print.js','bands_print_worker.js']:shutil.copy2(SRC/file,DIST/file)
    print('Built',DIST/'BANDS.amxd',len(amxd),'bytes;',len(p.p['boxes']),'objects')
    from freeze_device import freeze
    freeze(DIST/'BANDS.amxd', DIST/'Standalone/BANDS.amxd')

if __name__=='__main__':build()
