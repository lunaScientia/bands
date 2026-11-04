# BANDS

A Max for Live audio effect for inspecting and listening to five frequency bands, with a focus on the low end.

**[Download BANDS.amxd](https://github.com/lunaScientia/bands/releases/download/v1.0.0/BANDS.amxd)**

## Install

Requires Ableton Live with Max for Live available.

1. Download `BANDS.amxd` using the link above, or open [`dist/Standalone/BANDS.amxd`](dist/Standalone/BANDS.amxd) and choose **Download raw file**.
2. Drag the file onto an audio track in Live.
3. To keep it in the browser, save the device to your User Library.

The device is a single frozen `.amxd` file with its scripts and FFT patch embedded. No separate JavaScript files, Max patches, or ZIP extraction are needed. Replace an old loaded instance to use a newer build; loaded devices do not update automatically from disk.

## Features

- Five stereo bands with gain, solo, and mute controls. Enabling S clears M in the same band, and enabling M clears S. Multiple bands can be soloed together.
- Four adjustable crossover frequencies and an output trim.
- Input, output, and individual band spectrum curves.
- Low-end zoom, expanded spectrum window, display Hold, and input reference Capture.
- Original listening mode to bypass the crossover mix.

| Band | Default range |
| --- | --- |
| Ultra Low | below 30 Hz |
| Sub | 30–80 Hz |
| Bass | 80–250 Hz |
| Mids | 250 Hz–2.5 kHz |
| Highs | above 2.5 kHz |

The LR4-style crossover uses 24 dB/octave filters with all-pass phase compensation. At unity band gains, the summed magnitude is flat; phase is altered. Original mode does not loudness-match a modified mix.

## Status

**v1.0.0** is the first tagged release of BANDS. Download the frozen device from the [release page](https://github.com/lunaScientia/bands/releases/tag/v1.0.0).

Earlier steady-playback clicks and an unexpected Live exit have not been reproduced or proven fixed. Offline verification does not establish native audio performance or long-session stability; the release does not claim those reports are resolved.

See [CHANGELOG.md](CHANGELOG.md) for the current analyzer improvements and their tradeoffs.

## Development

Requirements: Python 3.10+ and Node.js 22. No third-party Python or Node packages are required. Max/Live is needed for native UI and audio testing.

```sh
python3 build.py
python3 tests/verify.py
python3 tests/verify_package.py
node tests/controller.js
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
| `tests/fixtures/v1-original/` | Original audio implementation for regression comparison |
| `dist/Standalone/BANDS.amxd` | Installable device |

Edit `build.py` for generated patch changes and the JavaScript files under `source/` for controller/display changes. Rebuild before committing the generated patches and distributable. Test output, local backups, and crash diagnostics are excluded from version control.

GitHub Actions builds and checks pushes and pull requests, then attaches the device and verification reports as workflow artifacts. These checks use mocked Max APIs where necessary; they do not launch Live.

## References

- [Max for Live device freezing](https://docs.cycling74.com/userguide/m4l/live_freezing/)
- [FFT size and overlap](https://docs.cycling74.com/reference/pfft~/)
- [Patcher window commands](https://docs.cycling74.com/reference/thispatcher/)
- [Window visibility API](https://docs.cycling74.com/apiref/js/wind/)
