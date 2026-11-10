"""Check the distributed frozen AMXD without requiring Max or extra packages."""
import hashlib
import json
import pathlib
import struct

ROOT = pathlib.Path(__file__).resolve().parents[1]
path = ROOT / 'dist/Standalone/BANDS.amxd'
data = path.read_bytes()
assert data[:12] == b'ampf\x04\x00\x00\x00aaaa'
assert data[24:28] == b'ptch'
collective = data[32:]
assert struct.unpack_from('<I', data, 28)[0] == len(collective)
assert collective[:4] == b'mx@c'
footer_offset = struct.unpack_from('>Q', collective, 8)[0]
assert collective[footer_offset:footer_offset+4] == b'dlst'
assert footer_offset + struct.unpack_from('>I', collective, footer_offset+4)[0] == len(collective)
position = footer_offset + 8
entries = {}
while position < len(collective):
    assert collective[position:position+4] == b'dire'
    length = struct.unpack_from('>I', collective, position+4)[0]
    assert length >= 8 and position + length <= len(collective)
    end = position + length
    position += 8
    fields = {}
    while position < end:
        tag = collective[position:position+4].decode('ascii')
        length = struct.unpack_from('>I', collective, position+4)[0]
        assert length >= 8 and position + length <= end
        fields[tag] = collective[position+8:position+length]
        position += length
    name = fields['fnam'].rstrip(b'\0').decode('ascii')
    assert name not in entries
    size = int.from_bytes(fields['sz32'], 'big')
    offset = int.from_bytes(fields['of32'], 'big')
    assert 16 <= offset < footer_offset and offset + size <= footer_offset
    entries[name] = collective[offset:offset+size]

assert set(entries) == {'BANDS.amxd', 'bands_control.js', 'bands_view.js', 'bands_fft.maxpat', 'bands_print.js'}
main = json.loads(entries['BANDS.amxd'].rstrip(b'\0'))['patcher']
worker = next(w['box'] for w in main['boxes'] if w['box']['id'] == 'printworker')
assert worker['maxclass'] == 'node.codebox'
assert worker['code'] == (ROOT/'source/bands_print_worker.js').read_text()
for name, payload in entries.items():
    if name == 'BANDS.amxd':
        expected = (ROOT / 'dist/BANDS.amxd').read_bytes()[32:]
    else:
        expected = (ROOT / 'source' / name).read_bytes()
    assert payload.rstrip(b'\0') == expected.rstrip(b'\0'), name
    if name.endswith(('.amxd', '.maxpat')):
        assert 'patcher' in json.loads(payload.rstrip(b'\0'))
report = {'status': 'PASS', 'sha256': hashlib.sha256(data).hexdigest(),
          'bytes': len(data), 'embedded_files': list(entries),
          'limitations': 'Container/source checks, not a native Live stability test.'}
(ROOT / 'tests/frozen-package-results.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report, indent=2))
