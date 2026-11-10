# BANDS

A Max for Live audio effect for inspecting and listening to eight frequency bands, with a focus on the low end.

**[Download BANDS.amxd](https://github.com/lunaScientia/bands/releases/download/v1.2.0/BANDS.amxd)**

## Install

Requires Ableton Live with Max for Live and **Max 9.1 or newer** (including Live's bundled Max). [v1.1.0](https://github.com/lunaScientia/bands/releases/tag/v1.1.0) remains available for older Max versions.

1. Download `BANDS.amxd` using the link above, or open [`dist/Standalone/BANDS.amxd`](dist/Standalone/BANDS.amxd) and choose **Download raw file**.
2. Drag the file onto an audio track in Live.
3. To keep it in the browser, save the device to your User Library.

The device is a single frozen `.amxd` file with its scripts and FFT patch embedded. No separate JavaScript files, Max patches, or ZIP extraction are needed. Replace an old loaded instance to use a newer build; loaded devices do not update automatically from disk.

## Features

- Eight stereo bands with gain, solo, and mute controls. Enabling S clears M in the same band, and enabling M clears S. Multiple bands can be soloed together.
- Seven adjustable crossover frequencies and an output trim.
- Input, output, and individual band spectrum curves.
- Low-end, full-range, and high-frequency spectrum views; expanded window, display Hold, and input reference Capture.
- Original listening mode to bypass the crossover mix.
- Print Bands: record the Arrangement Loop range into eight aligned stereo WAVs, then create and name the corresponding tracks automatically.

| Band | Default range |
| --- | --- |
| Ultra Low | below 30 Hz |
| Sub | 30–80 Hz |
| Bass | 80–250 Hz |
| Mids | 250 Hz–2 kHz |
| High-Mids | 2–4 kHz |
| Presence | 4–6 kHz |
| High | 6–12 kHz |
| Ultra High | above 12 kHz, up to the audio sample rate’s Nyquist limit |

Click the frequency-range button to cycle **10–500 Hz → 10 Hz–20 kHz → 2 kHz–Nyquist**. Presence fills the interval between High-Mids and High so the spectrum remains continuous. Use a sample rate of 44.1 kHz or higher for the full adjustable crossover ranges.

The LR4-style crossover uses 24 dB/octave filters with all-pass phase compensation. At unity band gains, the summed magnitude is flat; phase is altered. Original mode does not loudness-match a modified mix.

## Print Bands (v1.2)

1. Put BANDS on the reference's audio track, after any processing you want included.
2. Set the **Arrangement Loop brace** to the section to print. The Loop playback switch can be on or off.
3. Set the crossover frequencies, then click **Print Bands** in the device or expanded window.
4. Wait for one playback pass plus file writing. Eight audio tracks appear at the end of the track list, with matching names, frequencies, colors, and clip positions.

All eight bands are captured **before band gain, Solo, Mute, Original mode and Output Trim**. Devices before BANDS are included; devices after it and the track fader are not. Printed files use stereo 32-bit float, with no normalization or recording fades. Warp and looping are disabled on the imported clips. New tracks start **muted** so they do not double the existing mix; enable a track when you want to listen to it. Any effects from the user's default Audio Track are removed from these newly created print tracks.

For a saved Set, WAVs go beside the Set under `Samples/Processed/BANDS/`, in a new folder for each print. **Folder…** selects another location; an unsaved Set asks for a folder on the first print. A small metadata file records the print range and crossover settings. Use Live's Collect All and Save if you later move a Set whose printed samples are outside its project folder.

Printing temporarily stops playback, disables looping and plays from a short pre-roll before the selected section to warm the crossover filters. It restores the previous Loop switch and song position afterwards, and resumes playback if it was running before. Click **Cancel Print** to abort. Stopping or seeking during capture, changing crossovers or changing the sample rate cancels that capture. Finish Arrangement/Session recording, return to Arrangement playback, and disable Link before printing.

The audio is streamed to disk, not held in a song-sized RAM buffer. A temporary 17-channel WAV contains the eight stereo bands and a sample-synchronous host beat clock; the worker uses that clock to trim all bands to the same boundaries, writes the eight files in bounded chunks, then removes the temporary capture. During conversion, disk usage is roughly twice the final audio size. Very long ranges are limited to keep the temporary capture below the standard WAV size limit; print those in sections. At the very start of the song, no earlier audio is available to warm the filters.

## Status

**v1.2.0 adds Print Bands.** The published [v1.1.0 release](https://github.com/lunaScientia/bands/releases/tag/v1.1.0) and accepted five-band [v1.0.0 release](https://github.com/lunaScientia/bands/releases/tag/v1.0.0) remain available unchanged.

Native verification on 2026-11-10 used Live 12.4.6, bundled Max 9.1.5, and 48 kHz audio. A frozen device containing the production code plus a temporary test driver printed a synthetic stereo reference into eight correctly named, muted tracks. Every clip had Warp off, started at beat 2.25, ended at beat 3.75, and contained 56,320 frames. The printed 55 Hz, 140 Hz and 3.1 kHz tones matched the analytical crossover output at the expected sample position, with a maximum absolute error below 1.2e-8 on sampled comparison points. The final production `.amxd` also loaded independently and opened its expanded spectrum window. Test tracks were removed and the original transport/Loop state restored.

Native checks cover short prints and import, not long-session stability, tempo automation, every supported host version, or memory use inside Live. A separate Node worker test split a 392 MB capture with under 55 MB peak RSS; this measures the worker only.

Load the update as a new device instance. Eight-band versions have seven splits, so do not assume five-band presets or existing automation mappings will transfer. Keep v1.0.0 in older projects that need their original setup. The extra filters and analysis channels increase processing work; native Live CPU usage has not been benchmarked.

Earlier steady-playback clicks and an unexpected Live exit have not been reproduced or proven fixed. Offline verification does not establish native audio performance or long-session stability; the release does not claim those reports are resolved.

See [CHANGELOG.md](CHANGELOG.md) for the current analyzer improvements and their tradeoffs.

## Development

Requirements: Python 3.10+ and Node.js 22. No third-party Python or Node packages are required. Max/Live is needed for native UI and audio testing.

```sh
python3 build.py
python3 tests/verify.py
python3 tests/verify_package.py
node tests/controller.js
node tests/print_worker.js
node tests/print_controller.js
node --expose-gc tests/renderer.js
```

The build produces a development bundle under `dist/` and the distributable single file at `dist/Standalone/BANDS.amxd`. The renderer stress check may take several minutes.

| Path | Purpose |
| --- | --- |
| `build.py` | Generates the main Max patch, FFT patch, and device |
| `freeze_device.py` | Embeds dependencies into a frozen `.amxd` |
| `source/` | Max patches and JavaScript controller/renderer |
| `tests/verify.py` | Audio topology and response checks at five sample rates |
| `tests/verify_package.py` | Frozen container and embedded dependency checks |
| `tests/controller.js` | Solo/mute state, parameter synchronization, and original filter coefficients |
| `tests/renderer.js` | Renderer scheduling, state bounds, and simulated heap checks |
| `source/bands_print.js` | Live transport, print lifecycle, track creation, and clip import |
| `source/bands_print_worker.js` | Streaming WAV validation, beat-clock trimming, and stereo file output; embedded as `node.codebox` |
| `tests/print_worker.js` | Sample boundaries, stereo channel fidelity, WAV formats, and cancellation |
| `tests/print_controller.js` | Deferred Live operations, transport restoration, and failure handling |
| `tests/fixtures/v1-original/` | Original audio implementation for regression comparison |
| `dist/Standalone/BANDS.amxd` | Installable device |

Edit `build.py` for generated patch changes and the JavaScript files under `source/` for controller/display changes. Rebuild before committing the generated patches and distributable. Test output, local backups, and crash diagnostics are excluded from version control.

GitHub Actions builds and checks pushes and pull requests, then attaches the device and verification reports as workflow artifacts. These checks use mocked Max APIs where necessary; they do not launch Live.

## References

- [Max for Live device freezing](https://docs.cycling74.com/userguide/m4l/live_freezing/)
- [FFT size and overlap](https://docs.cycling74.com/reference/pfft~/)
- [Patcher window commands](https://docs.cycling74.com/reference/thispatcher/)
- [Window visibility API](https://docs.cycling74.com/apiref/js/wind/)
- [Disk recording](https://docs.cycling74.com/reference/sfrecord~/)
- [Sample-synchronous host beat phase](https://docs.cycling74.com/reference/plugphasor~/)
- [Track creation](https://docs.cycling74.com/apiref/lom/song/#create_audio_track) and [audio clip import](https://docs.cycling74.com/apiref/lom/track/#create_audio_clip)
