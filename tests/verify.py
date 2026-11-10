"""DSP design checks independent of Max; validates actual generated patch topology."""
import cmath,json,math,pathlib,struct,sys
ROOT=pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from build import coeff, EDGES, LIMITS, NAMES, BAND_COUNT, SPECTRA, WIDTH

def response(c,w):
    z=cmath.exp(-1j*w)
    return (c[0]+c[1]*z+c[2]*z*z)/(1+c[3]*z+c[4]*z*z)

def bands(freq,rate,edges):
    w=2*math.pi*freq/rate;c=[coeff(f,rate) for f in edges];out=[];high=1
    for i in range(len(edges)):
        low=high*response(c[i]['lp'],w)**2
        for j in range(i+1,len(edges)):low*=response(c[j]['ap'],w)
        out.append(low);high*=response(c[i]['hp'],w)**2
    return out+[high]

worst=0
for sr in [44100,48000,88200,96000,192000]:
    for edges in [EDGES,[lo for lo,hi in LIMITS],[hi for lo,hi in LIMITS],[49,50,140,600,3000,5000,10000]]:
        for k in range(3000):
            f=5*(sr*.499/5)**(k/2999)
            result=bands(f,sr,edges)
            assert all(math.isfinite(abs(x)) for x in result)
            err=abs(20*math.log10(abs(sum(result))))
            worst=max(worst,err)
            assert err<1e-5,(sr,edges,f,err)

data=(ROOT/'dist/BANDS.amxd').read_bytes()
assert data[:12]==b'ampf\x04\x00\x00\x00aaaa'
assert struct.unpack_from('<I',data,28)[0]==len(data)-32
patch=json.loads(data[32:].rstrip(b'\0'))['patcher']

def validate(p):
    boxes={b['box']['id']:b['box'] for b in p['boxes']}
    assert len(boxes)==len(p['boxes'])
    for x in p['lines']:
        line=x['patchline'];a,o=line['source'];b,i=line['destination']
        assert a in boxes and b in boxes
        assert 0<=o<boxes[a]['numoutlets'],(a,o)
        assert 0<=i<boxes[b]['numinlets'],(b,i)
    for b in boxes.values():
        if 'patcher' in b:validate(b['patcher'])
    return boxes

boxes=validate(patch)
validate(json.loads((ROOT/'source/bands_fft.maxpat').read_text())['patcher'])
assert sum(b['maxclass']=='live.dial' for b in boxes.values())==BAND_COUNT+1
assert sum(b['maxclass']=='live.text' for b in boxes.values())==2*BAND_COUNT+1
assert sum(b.get('text','').startswith('biquad~') for b in boxes.values())==2*(4*len(EDGES)+len(EDGES)*(len(EDGES)-1)//2)
assert not any(b.get('text','').startswith('cross~') for b in boxes.values())
# Generalized LR4 graph is checked below; output mix/ramp wiring stays unchanged.
import hashlib
hashes={name:hashlib.sha256((ROOT/'dist'/name).read_bytes()).hexdigest()
        for name in ['BANDS.amxd','bands_control.js','bands_view.js','bands_fft.maxpat']}
original=json.loads((ROOT/'tests/fixtures/v1-original/BANDS.amxd').read_bytes()[32:].rstrip(b'\0'))['patcher']
original_boxes={b['box']['id']:b['box'] for b in original['boxes']}
output_ids=['trimline','dryline','wetline']+[f'{kind}{ch}' for ch in range(2) for kind in ['sum','wet','dry','output']]
for id in output_ids:
    assert boxes[id]['text']==original_boxes[id]['text']
def output_lines(p):
    return sorted(json.dumps(l['patchline'],sort_keys=True) for l in p['lines']
                  if l['patchline']['destination'][0] in output_ids
                  and not l['patchline']['source'][0].startswith('weighted'))
assert output_lines(patch)==output_lines(original)
for ch in range(2):
    for i in range(BAND_COUNT):
        assert any(l['patchline']['source']==[f'weighted{ch}_{i}',0] and l['patchline']['destination']==[f'sum{ch}',0] for l in patch['lines'])
        assert any(l['patchline']['source']==[f'gainline{i}',0] and l['patchline']['destination']==[f'weighted{ch}_{i}',1] for l in patch['lines'])
# Verify the actual initial coefficients embedded in every native biquad.
for id,b in boxes.items():
    if not b.get('text','').startswith('biquad~'):continue
    ctl=next(l['patchline']['source'][0] for l in patch['lines'] if l['patchline']['destination'][0]==id and l['patchline']['source'][0].startswith('r'))
    assert list(map(float,b['text'].split()[1:]))==coeff(EDGES[int(ctl[-1])])[ctl[1:3]]
# All bands have their own meter buffers and stereo analysis inputs.
assert boxes['fft']['numinlets']==2*SPECTRA
for i in range(SPECTRA):assert boxes['buffer'+str(i)]['text']==f'buffer~ ---bands-spec{i} @samps 8192'
fft_boxes=validate(json.loads((ROOT/'source/bands_fft.maxpat').read_text())['patcher'])
assert sum(b.get('text','').startswith('fftin~ ') for b in fft_boxes.values())==2*SPECTRA
for i in range(SPECTRA):assert fft_boxes[f'poke{i}']['text']==f'poke~ #1-spec{i}'
for ch in range(2):
    for i in range(BAND_COUNT):
        assert any(l['patchline']['source']==[f'weighted{ch}_{i}',0] and l['patchline']['destination']==['fft',4+2*i+ch] for l in patch['lines'])
# Eight-wide hardware banks reference actual parameters; every control fits in the device.
longnames={b['saved_attribute_attributes']['valueof']['parameter_longname'] for b in boxes.values() if b.get('parameter_enable')}
for bank in patch['parameters']['parameterbanks'].values():
    assert len(bank['parameters'])==8
    assert all(name=='-' or name in longnames for name in bank['parameters'])
for b in boxes.values():
    if b.get('presentation'):
        x,y,w,h=b['presentation_rect'];assert x>=0 and y>=0 and x+w<=WIDTH and y+h<=169,(b['id'],b['presentation_rect'])
assert boxes['fft']['text']=='pfft~ bands_fft 16384 4 args ---bands'
detail=validate(boxes['detail']['patcher'])
assert detail['show']['text'].endswith('front, topmost 1')
# Evaluate the actual generated signal graph, excluding control receivers.
incoming={id:[] for id in boxes}
for l in patch['lines']:
    src,out=l['patchline']['source'];dst,inp=l['patchline']['destination']
    if boxes[src].get('text','').startswith('r '):continue
    incoming[dst].append((src,out,inp))
def actual(id,f,sr,memo):
    if id=='in':return 1
    if id in memo:return memo[id]
    assert boxes[id].get('text','').startswith('biquad~'),id
    ctl=next(l['patchline']['source'][0] for l in patch['lines']
             if l['patchline']['destination'][0]==id and l['patchline']['source'][0].startswith('r'))
    c=coeff(EDGES[int(ctl[-1])],sr)[ctl[1:3]]
    v=sum(actual(s,f,sr,memo) for s,o,i in incoming[id])*response(c,2*math.pi*f/sr)
    memo[id]=v
    return v
for ch in range(2):
    for sr in [44100,48000,88200,96000,192000]:
        for f in [10,30,80,250,2000,4000,6000,12000,16000,20000]:
            expect=bands(f,sr,EDGES);memo={}
            for i in range(BAND_COUNT):
                src=next(s for s,o,k in incoming[f'weighted{ch}_{i}'] if boxes[s].get('text','').startswith('biquad~'))
                assert abs(actual(src,f,sr,memo)-expect[i])<1e-10

# Each requested high-frequency band must dominate at an interior test tone.
for sr in [44100,48000,88200,96000,192000]:
    for band_index,f in [(4,2800),(5,4900),(6,8500),(7,17000)]:
        magnitudes=list(map(abs,bands(f,sr,EDGES)))
        assert max(range(BAND_COUNT),key=lambda i:magnitudes[i])==band_index,(sr,f,magnitudes)
    for edge in EDGES:
        c=coeff(edge,sr);w=2*math.pi*edge/sr
        assert abs(abs(response(c['lp'],w)**2)-.5)<1e-8
        assert abs(abs(response(c['hp'],w)**2)-.5)<1e-8
# Clamp below Nyquist even at unusual low sample rates / maximum split settings.
for sr in [22050,32000,44100]:
    for low,high in LIMITS:
        c=coeff(high,sr)['lp'];disc=complex(c[3]*c[3]-4*c[4])**.5
        assert all(abs(pole)<1 for pole in [(-c[3]+disc)/2,(-c[3]-disc)/2])

report={'status':'PASS','sample_rates':[44100,48000,88200,96000,192000],
        'sweep_points':60000,'worst_unity_magnitude_error_dB':worst,
        'checks':['eight-band graph and original output stage','flat unity magnitude','finite responses',
                  'actual generated crossover topology','AMXD container','patch connections'],
        'sha256':hashes,'limitations':'Offline checks; native Live stability and window behavior require runtime verification.'}
(ROOT/'tests/design-results.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
