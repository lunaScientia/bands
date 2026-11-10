"""Embed the device and dependencies in Max's frozen mx@c AMXD container.

The format is checked against Ableton/maxdevtools' freezing_utils parser and
the native frozen devices distributed with Max. No audio or UI code changes.
"""
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parent
DEPENDENCIES = [('bands_control.js', b'TEXT'), ('bands_view.js', b'TEXT'),
                ('bands_print.js', b'TEXT'),
                ('bands_fft.maxpat', b'JSON')]


def chunk(tag, payload, endian='>'):
    return tag + struct.pack(endian + 'I', len(payload) + (8 if endian == '>' else 0)) + payload


def freeze(source, destination):
    source, destination = Path(source), Path(destination)
    original = source.read_bytes()
    assert original[:12] == b'ampf\x04\x00\x00\x00aaaa'
    assert original[24:28] == b'ptch'
    main = original[32:]
    assert len(main) == struct.unpack_from('<I', original, 28)[0]
    assert main.lstrip().startswith(b'{'), 'Expected an unfrozen source device'
    files = [(destination.name, b'JSON', main, 0x11, source)]
    for name, kind in DEPENDENCIES:
        path = source.parent / name
        payload = path.read_bytes()
        if kind == b'JSON' and not payload.endswith(b'\0'):
            payload += b'\0'
        files.append((name, kind, payload, 0, path))

    data, directory = bytearray(), bytearray()
    for name, kind, payload, flag, path in files:
        filename = name.encode('ascii') + b'\0'
        filename += b'\0' * (-len(filename) % 4)
        fields = [chunk(b'type', kind), chunk(b'fnam', filename)]
        values = [(b'sz32', len(payload)), (b'of32', 16 + len(data)),
                  (b'vers', 0), (b'flag', flag),
                  (b'mdat', int(path.stat().st_mtime) + 2082844800)]
        fields.extend(chunk(tag, struct.pack('>I', value)) for tag, value in values)
        directory.extend(chunk(b'dire', b''.join(fields)))
        data.extend(payload)

    collective = b'mx@c' + struct.pack('>IQ', 16, 16 + len(data)) + data + chunk(b'dlst', directory)
    frozen = (chunk(b'ampf', b'aaaa', '<') + chunk(b'meta', struct.pack('<I', 7), '<')
              + chunk(b'ptch', collective, '<'))
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(frozen)
    print(f'Frozen {destination}: {len(frozen):,} bytes, {len(files)} embedded files')
    return destination


if __name__ == '__main__':
    freeze(ROOT / 'dist/BANDS.amxd', ROOT / 'dist/Standalone/BANDS.amxd')
