# Changelog

## v1.2.0 — in development

- Added Print Bands to the dock and expanded window: capture all eight stereo bands in one playback pass over the Arrangement Loop brace, then create named, colored tracks with aligned audio clips.
- Print taps are before listening gains, Solo/Mute, Original mode and Output Trim. Files preserve relative levels in 32-bit float; imported clips have Warp off. New print tracks are muted and do not inherit processing from the default Audio Track.
- Added a shared multichannel disk capture with a host beat-phase channel for sample-boundary trimming, filter pre-roll, unique output directories and bounded streaming conversion. No whole-reference RAM buffer is allocated.
- Added cancellation and checks for transport jumps, stopped audio, changed crossovers/sample rates, disk stalls, and oversized captures. Playback position and the Loop switch are restored after the operation.
- Kept one frozen `.amxd` distribution. The disk worker is embedded directly with `node.codebox`; this version requires Max 9.1 or newer.
- Added streaming audio and Live coordination regression checks. Native Max disk recording/channel fidelity passed; hosted Live integration verification is in progress.

## v1.1.0 — 2026-11-10

- Expanded to eight continuous bands with defaults below 30 Hz, 30–80 Hz, 80–250 Hz, 250 Hz–2 kHz, 2–4 kHz, 4–6 kHz, 6–12 kHz, and above 12 kHz.
- Added High-Mids, Presence, High, and Ultra High controls, spectra, meters, and hardware-control banks. Presence covers the 4–6 kHz gap between the requested ranges.
- Added a high-frequency view from 2 kHz to Nyquist, alongside the existing low-end and full-range views.
- Generalized the LR4 crossover and phase compensation to seven splits, retaining the 25 ms gain ramps, Solo/Mute exclusivity, and saved-state initialization.
- Expanded the device panel to fit all eight bands; bounded spectrum caches and hidden-view gating remain in place.
- Packaged as one frozen `BANDS.amxd`. v1.0.0 remains unchanged; load v1.1.0 as a separate instance because five-band presets/automation are not migration-compatible.
- Offline response, routing, control, renderer, and packaging checks cover the added bands. Native Live playback, CPU usage, and window behavior remain unverified.

## v1.0.0 — 2026-11-04

- First tagged release of the current standalone device.
- Includes five-band spectrum analysis, gain/solo/mute controls, adjustable crossovers, the expanded spectrum window, and reference capture.
- Includes the analyzer workload improvements and solo/mute fixes listed below.
- Publishes the existing frozen `BANDS.amxd` unchanged as a GitHub Release asset; all dependencies are embedded.
- Earlier unconfirmed click/crash reports remain documented under known unresolved issues.

## 2026-11-04 — Solo/mute exclusivity

- Enabling Solo clears Mute in the same band; enabling Mute clears Solo. UI parameters and audio control state update together. Turning either off does not enable the other.
- Multiple bands can still be soloed together.
- Initialization reads stored parameter values using `outputvalue`; it no longer sends `bang`, which toggles `live.text` buttons.
- Older presets with both controls enabled in one band normalize to a single listening mode.
- Added controller regression checks and rebuilt the single-file device. Audio filters, gain ramp times, and spectrum renderer are unchanged.

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
