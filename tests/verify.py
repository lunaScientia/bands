"""DSP design checks independent of Max; validates actual generated patch topology."""
import cmath,json,math,pathlib,struct,sys
ROOT=pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from build import coeff

def response(c,w):
    z=cmath.exp(-1j*w)
    return (c[0]+c[1]*z+c[2]*z*z)/(1+c[3]*z+c[4]*z*z)

def bands(freq,rate,edges):
    w=2*math.pi*freq/rate;c=[coeff(f,rate) for f in edges];out=[];high=1
    for i in range(4):
        low=high*response(c[i]['lp'],w)**2
        for j in range(i+1,4):low*=response(c[j]['ap'],w)
        out.append(low);high*=response(c[i]['hp'],w)**2
    return out+[high]

worst=0
for sr in [44100,48000,88200,96000,192000]:
    for edges in [[30,80,250,2500],[15,50,140,600],[49,139,599,8000],[49,50,140,600]]:
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
assert sum(b['maxclass']=='live.dial' for b in boxes.values())==6
assert sum(b['maxclass']=='live.text' for b in boxes.values())==11
assert sum(b.get('text','').startswith('biquad~') for b in boxes.values())==44
assert not any(b.get('text','').startswith('cross~') for b in boxes.values())
# Preserve the original audio network byte for byte; UI/analyzer may change.
import hashlib
hashes={name:hashlib.sha256((ROOT/'dist'/name).read_bytes()).hexdigest()
        for name in ['BANDS.amxd','bands_control.js','bands_view.js','bands_fft.maxpat']}
original=json.loads((ROOT/'tests/fixtures/v1-original/BANDS.amxd').read_bytes()[32:].rstrip(b'\0'))['patcher']
original_boxes={b['box']['id']:b['box'] for b in original['boxes']}
audio_ids={id for id,b in original_boxes.items() if '~' in b.get('text','') and id!='fft' and not id.startswith('buffer')}
for id in audio_ids:
    assert boxes[id]['text']==original_boxes[id]['text'], ('audio object changed',id)
def audio_lines(p):
    return sorted(json.dumps(l['patchline'],sort_keys=True) for l in p['lines'] if l['patchline']['destination'][0] in audio_ids)
assert audio_lines(patch)==audio_lines(original)
assert (ROOT/'source/bands_control.js').read_bytes()==(ROOT/'tests/fixtures/v1-original/bands_control.js').read_bytes()
assert (ROOT/'source/bands_fft.maxpat').read_bytes()==(ROOT/'tests/fixtures/v1-original/bands_fft.maxpat').read_bytes()
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
    c=coeff([30,80,250,2500][int(ctl[-1])],sr)[ctl[1:3]]
    v=sum(actual(s,f,sr,memo) for s,o,i in incoming[id])*response(c,2*math.pi*f/sr)
    memo[id]=v
    return v
for ch in range(2):
    for sr in [44100,48000,88200,96000,192000]:
        for f in [10,30,80,250,2500,10000,20000]:
            expect=bands(f,sr,[30,80,250,2500]);memo={}
            for i in range(5):
                src=next(s for s,o,k in incoming[f'weighted{ch}_{i}'] if boxes[s].get('text','').startswith('biquad~'))
                assert abs(actual(src,f,sr,memo)-expect[i])<1e-10

report={'status':'PASS','sample_rates':[44100,48000,88200,96000,192000],
        'sweep_points':60000,'worst_unity_magnitude_error_dB':worst,
        'checks':['original audio objects, wiring and controller preserved','flat unity magnitude','finite responses',
                  'actual generated crossover topology','AMXD container','patch connections'],
        'sha256':hashes,'limitations':'Offline checks; native Live stability and window behavior require runtime verification.'}
(ROOT/'tests/design-results.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
