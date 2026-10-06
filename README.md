# Air Mute

Control your microphone mute state with an AirPods stem press from the macOS menu bar.

![Air Mute icon](AirMute/Resources/AppIcon.png)

## Availability

The **1.0.1** source is available below. A downloadable app is pending Developer ID signing and Apple notarization; no notarized binary is currently published. See [NOTARIZATION.md](NOTARIZATION.md).

## Usage

Quit any other microphone-mute utility before launching a replacement. Allow microphone access when prompted, connect your AirPods, and select them as your default microphone. The app keeps an input connection active to receive mute gestures. Run one microphone-mute utility at a time.

The original twin-stem menu icon has a **green microphone badge when unmuted** and a **red slashed badge when muted**. Open its menu to view status, toggle mute, reconnect, or quit. Quit attempts to restore the input to unmuted. Cmd+M belongs to this app's menu; it is not a system-wide hotkey.

Air Mute changes the default input device's CoreAudio mute property. A call application's own mute button, including Codex's, may continue to show unmuted even while the device is muted. Use the Air Mute badge for device status.

## Build from source

Requires macOS, Apple's Command Line Tools (Swift and the macOS SDK), and Python 3. No additional package dependencies are used.

```sh
git clone https://github.com/fhajjej-ship-it/air-mute.git
cd air-mute
sh build.sh
```

The result is `build/Air Mute.app`, built for the host architecture and ad-hoc signed locally. The script does not install or launch it. It refuses to overwrite an existing output app; supply a fresh output directory for another build.

Bundle identifier: `com.fhajjejshipit.airmute`. App name: **Air Mute**. Source build version: **1.0.1**, build **6** (pending notarized release).

## Privacy

While Air Mute runs, its input-only audio connection receives buffers and discards them locally without inspecting samples, saving, transcribing, transmitting, or playing them through speakers. The microphone activity indicator remains active. No recording is saved, and there is no network code in the application.

Microphone permission is required for gesture reception. Bluetooth access supplies connection status. Diagnostic output can include device names and Bluetooth addresses; keep runtime logs private. No login item or background daemon is installed. Quit stops the input connection and unregisters gesture handlers. Force-kill or a crash may bypass cleanup.

## Verification and limits

On October 6, 2026, the gesture/audio implementation was confirmed with physical AirPods Pro 3 stem presses during Codex voice on Apple Silicon, macOS 27.0.1 (AirPods model A3063, firmware 9B42a; Swift 6.4 compiler). CoreAudio readback matched each requested mute/unmute state, and the user confirmed it worked.

The Air Mute branding build was separately compiled and its bundle name, identifier, original icon, embedded notices and ad-hoc signature checked. It was not launched alongside the working utility during the voice session. Its gesture/audio logic is the same verified implementation; only branding and diagnostic labels changed.

The build targets macOS 14 API availability; older macOS releases, Intel builds, AirPods Max and other devices were not tested. Device swaps during an active gesture input connection and crash recovery were not verified. This is an initial release with narrow verified device coverage.

## License

MIT. Source and license provenance are documented in [UPSTREAM.md](UPSTREAM.md); the upstream declared MIT license is preserved verbatim in `upstream/README.md`. The original artwork and changes are included under MIT. Air Mute is based on PodsMute and does not claim exclusive authorship of inherited code.

This project is separate from similarly named applications; no affiliation or name-clearance claim is made.
