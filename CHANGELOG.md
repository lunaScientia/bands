# Changelog

## 2026-09-18 — Analyzer and window update

- Expand now configures a floating window, opens it, then applies `topmost 1`. The command requires a previously visible window. Native Live verification remains pending.
- Display timer changed from 80 ms (12.5 fps) to 33 ms (about 30 fps target).
- FFT size reduced from 32,768 to 16,384 samples, overlap 4. At 48 kHz, the analysis window spans 341 ms, with a new frame every 85 ms and bin spacing of 2.93 Hz. This improves response time at the cost of some frequency resolution. Display refreshes are not independent FFT measurements.
- Only the active display reads spectrum buffers, at most once per FFT hop. The dock pauses its display while the expanded view is visible. Audio analysis continues.
- Spectrum painting reuses cached curves and bin mappings. Smoothing uses elapsed time, drawing arrays are bounded, and mouse movement uses the display timer.
- Capture reads current input, including when Hold is enabled. References clear on sample-rate changes.
- Original audio objects, wiring, coefficients, gain ramps, and controller preserved.

## 2026-09-13 — Single-file distribution

- Packaged all dependencies into one frozen `BANDS.amxd`.
- Restored the first version's audio network and interface.

## Known unresolved issues

- Steady-playback clicks have been reported; their cause is unconfirmed.
- An unexpected Live exit has been reported. Available diagnostics did not establish its cause or confirm an out-of-memory failure.
- Offline audio, renderer, and packaging checks are not native Live stability tests.
