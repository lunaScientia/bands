// Node for Max: bounded disk I/O only. No DSP, network, npm or Live API here.
'use strict';
const fs = require('fs');
const path = require('path');
const NAMES = ['Ultra Low', 'Sub', 'Bass', 'Mids', 'High-Mids', 'Presence', 'High', 'Ultra High'];
const CHANNELS = 17; // eight stereo bands, then the sample-synchronous host beat phase
const BLOCK = 8192;
const MAX_BYTES = 3 * 1024 ** 3;

function nativePath(s) {
    s = String(s || '');
    // Max's macOS path convention: "Macintosh HD:/path/to/file".
    if (process.platform === 'darwin' && /^[^/:]+:\//.test(s)) {
        const colon = s.indexOf(':');
        const relative = s.slice(colon + 1);
        const volume = '/Volumes/' + s.slice(0, colon) + relative;
        return fs.existsSync(volume) ? volume : relative;
    }
    return s;
}
function safeName(s) {
    return String(s).replace(/[\x00-\x1f<>:"/\\|?*]/g, '_').replace(/[. ]+$/g, '').slice(0, 70) || 'Reference';
}
function ranges(edges, rate) {
    const cuts = edges.map(f => Math.min(f, rate * .49));
    return NAMES.map((name, i) => name + ' ' + (i ? cuts[i - 1] : 0) + '-' + (i < 7 ? cuts[i] : rate / 2) + ' Hz');
}
function prepare(config) {
    if (!Number.isFinite(config.rate) || config.rate < 22050 || config.rate > 384000 ||
        !Number.isFinite(config.start) || config.start < 0 || !Number.isFinite(config.length) || config.length <= 0 ||
        !Number.isFinite(config.preStart) || config.preStart < 0 || config.preStart > config.start || config.preStart % 1 ||
        !Array.isArray(config.edges) || config.edges.length !== 7 ||
        config.edges.some((f, i) => !Number.isFinite(f) || f <= 0 || (i && f <= config.edges[i - 1]))) {
        throw Error('Invalid print range, sample rate or crossovers.');
    }
    let base = nativePath(config.folder);
    if (!base && config.setPath) base = path.join(path.dirname(nativePath(config.setPath)), 'Samples', 'Processed', 'BANDS');
    if (!path.isAbsolute(base)) throw Error('Choose an output folder first.');
    fs.mkdirSync(base, {recursive: true});
    const folder = fs.mkdtempSync(path.join(base, 'BANDS-' + safeName(config.reference) + '-'));
    const labels = ranges(config.edges, config.rate);
    const files = labels.map((label, i) => path.join(folder, String(i + 1).padStart(2, '0') + ' ' + safeName(label) + '.wav'));
    const job = {...config, folder, labels, files, raw: path.join(folder, '.capture.wav')};
    fs.writeFileSync(path.join(folder, 'print.json'), JSON.stringify({version: '1.2.0', ...config, labels}, null, 2));
    return job;
}
function readExactly(fd, length, position) {
    const b = Buffer.alloc(length);
    let n = 0;
    while (n < length) {
        const got = fs.readSync(fd, b, n, length - n, position + n);
        if (!got) throw Error('Incomplete capture file.');
        n += got;
    }
    return b;
}
function waveInfo(fd) {
    const size = fs.fstatSync(fd).size;
    const head = readExactly(fd, 12, 0);
    if (head.toString('ascii', 0, 4) !== 'RIFF' || head.toString('ascii', 8) !== 'WAVE') throw Error('Capture is not a WAV file.');
    let fmt, data;
    for (let p = 12; p + 8 <= size;) {
        const h = readExactly(fd, 8, p), tag = h.toString('ascii', 0, 4), n = h.readUInt32LE(4);
        if (p + 8 + n > size) throw Error('Capture is still being written or disk is full.');
        if (tag === 'fmt ') {
            if (n < 16 || n > 4096) throw Error('Invalid WAV format.');
            const b = readExactly(fd, n, p + 8);
            let format = b.readUInt16LE(0);
            if (format === 65534 && n >= 40) format = b.readUInt16LE(24);
            fmt = {format, channels: b.readUInt16LE(2), rate: b.readUInt32LE(4), align: b.readUInt16LE(12), bits: b.readUInt16LE(14)};
        }
        if (tag === 'data') {data = {offset: p + 8, bytes: n}; break;}
        p += 8 + n + (n % 2);
    }
    if (!fmt || !data || fmt.format !== 3 || fmt.bits !== 32 || fmt.align !== fmt.channels * 4 || !data.bytes || data.bytes % fmt.align) {
        throw Error('Expected a complete 32-bit float WAV capture.');
    }
    return {...fmt, ...data, frames: data.bytes / fmt.align};
}
function waveHeader(channels, rate, frames) {
    // IEEE float WAV with the mandatory fact chunk; avoids normalization/clipping.
    const h = Buffer.alloc(56), bytes = frames * channels * 4;
    h.write('RIFF'); h.writeUInt32LE(48 + bytes, 4); h.write('WAVEfmt ', 8);
    h.writeUInt32LE(16, 16); h.writeUInt16LE(3, 20); h.writeUInt16LE(channels, 22);
    h.writeUInt32LE(rate, 24); h.writeUInt32LE(rate * channels * 4, 28);
    h.writeUInt16LE(channels * 4, 32); h.writeUInt16LE(32, 34);
    h.write('fact', 36); h.writeUInt32LE(4, 40); h.writeUInt32LE(frames, 44);
    h.write('data', 48); h.writeUInt32LE(bytes, 52);
    return h;
}
function writeAll(fd, b, length = b.length, position = null) {
    let n = 0;
    while (n < length) n += fs.writeSync(fd, b, n, length - n, position === null ? null : position + n);
}
const yieldIO = () => new Promise(resolve => setImmediate(resolve));

// Find both boundaries from a recorded plugphasor~ channel, not JS timers.
// Integer pre-roll position anchors the unwrapped quarter-note phase.
async function findRange(fd, info, job, cancelled) {
    let previous = 0, beat = job.preStart, moving = false, first = -1, last = -1;
    const b = Buffer.alloc(BLOCK * info.align), end = job.start + job.length;
    for (let base = 0; base < info.frames; base += BLOCK) {
        if (cancelled()) throw Error('Print cancelled.');
        const count = Math.min(BLOCK, info.frames - base);
        const got = fs.readSync(fd, b, 0, count * info.align, info.offset + base * info.align);
        if (got !== count * info.align) throw Error('Incomplete capture.');
        for (let i = 0; i < count; i++) {
            const phase = b.readFloatLE(i * info.align + 64), frame = base + i;
            if (!Number.isFinite(phase) || phase < 0 || phase > 1) throw Error('Invalid host clock.');
            if (!moving) {
                if (phase === 0) continue;
                // Recording must begin while transport is stopped at an integer beat.
                if (phase > .01 || frame < 2) throw Error('Host clock did not start from the requested pre-roll position.');
                moving = true;
                // At song start, retain the sample at phase zero immediately before
                // the first positive phase. No leading stopped-transport silence.
                if (job.start === job.preStart) first = frame - 1;
            } else {
                let step = phase - previous;
                if (step < -.5) {beat++; step++;}
                if (step <= 0 || step > .005) throw Error('Transport stopped or jumped during the print.');
            }
            const position = beat + phase;
            // Half-sample tolerance selects the nearest sample to a beat boundary.
            // Bias exact half-sample ties forward; float32 phase quantization must
            // not make start and end choose opposite sides of the same tie.
            const epsilon = moving && previous !== 0 ? Math.max(0, Math.min(.0001, ((phase - previous + 1) % 1) * .5) - 1e-7) : 0;
            if (first < 0 && position + epsilon >= job.start) first = frame;
            if (position + epsilon >= end) {last = frame; break;}
            previous = phase;
        }
        if (last >= 0) break;
        await yieldIO();
    }
    if (first < 0 || last <= first) throw Error('Capture ended before the complete Loop range was recorded.');
    return {first, last, frames: last - first};
}
async function split(job, cancelled = () => false, progress = () => {}) {
    const input = fs.openSync(job.raw, 'r'), handles = [], parts = [];
    try {
        const info = waveInfo(input);
        if (info.channels !== CHANNELS || info.rate !== job.rate) throw Error('Capture channel count or sample rate changed.');
        const range = await findRange(input, info, job, cancelled);
        const inputBuffer = Buffer.alloc(BLOCK * info.align);
        const output = NAMES.map(() => Buffer.alloc(BLOCK * 8));
        for (const file of job.files) {
            const part = file + '.part';
            handles.push(fs.openSync(part, 'wx')); parts.push(part);
            writeAll(handles[handles.length - 1], waveHeader(2, info.rate, range.frames));
        }
        let lastProgress = 0;
        for (let done = 0; done < range.frames; done += BLOCK) {
            if (cancelled()) throw Error('Print cancelled.');
            const count = Math.min(BLOCK, range.frames - done);
            if (fs.readSync(input, inputBuffer, 0, count * info.align, info.offset + (range.first + done) * info.align) !== count * info.align) throw Error('Incomplete capture.');
            for (let band = 0; band < 8; band++) {
                for (let frame = 0; frame < count; frame++) {
                    const start = frame * info.align + band * 8;
                    inputBuffer.copy(output[band], frame * 8, start, start + 8);
                }
                writeAll(handles[band], output[band], count * 8);
            }
            if (Date.now() - lastProgress > 150) {progress(Math.floor(100 * (done + count) / range.frames)); lastProgress = Date.now();}
            await yieldIO();
        }
        for (const fd of handles) {fs.fsyncSync(fd); fs.closeSync(fd);}
        handles.length = 0;
        if (cancelled()) throw Error('Print cancelled.');
        for (let i = 0; i < parts.length; i++) fs.renameSync(parts[i], job.files[i]);
        const result = {files: job.files, labels: job.labels, folder: job.folder, rate: info.rate, frames: range.frames, first: range.first, last: range.last};
        fs.writeFileSync(path.join(job.folder, 'result.json'), JSON.stringify(result, null, 2));
        fs.unlinkSync(job.raw);
        return result;
    } finally {
        fs.closeSync(input);
        for (const fd of handles) fs.closeSync(fd);
        for (const part of parts) {try {fs.unlinkSync(part);} catch (_) {}}
    }
}
function discard(job) {
    // Only remove our temporary capture; completed WAVs are never deleted.
    if (job) {try {fs.unlinkSync(job.raw);} catch (_) {}}
}
module.exports = {prepare, split, waveInfo, waveHeader, findRange, safeName, nativePath, MAX_BYTES};

if (process.env.MAX_ENV) {
    const max = require('max-api');
    let job = null, busy = false, cancelled = false;
    max.addHandler('prepare', json => {
        if (busy || job) return max.outlet('failed', 'Previous print is still finishing.');
        try {cancelled = false; job = prepare(JSON.parse(json)); max.outlet('prepared', job.raw, job.folder);}
        catch (e) {max.outlet('failed', e.message);}
    });
    max.addHandler('finish', async () => {
        if (!job || busy) return;
        busy = true;
        try {
            const result = await split(job, () => cancelled, value => max.outlet('progress', value));
            max.outlet('finished', JSON.stringify(result));
        } catch (e) {max.outlet('failed', e.message);}
        finally {discard(job); job = null; busy = false;}
    });
    max.addHandler('cancel', () => {
        cancelled = true;
        if (!busy) {discard(job); job = null; max.outlet('cancelled');}
    });
    max.addHandler('ping', () => max.outlet('ready'));
    max.outlet('ready');
}
