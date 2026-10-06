# Source and license notice

Air Mute incorporates and modifies PodsMute source from:

- Repository: https://github.com/cyanicr/podsmute
- Pinned commit: `1eae9373a976f6723979e1827f38054928b83a53`
- Exact upstream README: [`upstream/README.md`](upstream/README.md)

The upstream README explicitly declares:

> ## License
>
> MIT License

That declaration is the upstream licensing statement relied on for this distribution. A standalone LICENSE file and named copyright notice were not supplied in the pinned source; their absence is not treated as a revocation of the explicit MIT declaration. No upstream copyright holder or year has been invented. Copyright in inherited portions remains with their respective holders.

`LICENSE` includes the standard MIT permission and warranty terms and identifies the copyright for Air Mute's additions only. It does not assert exclusive ownership of inherited code. The original README, including its protocol-research acknowledgement, is retained unchanged here and embedded in the app bundle with this notice and LICENSE.

Changed areas: microphone permission and active input-only gesture connection; public AVAudioApplication mute notification opt-in and explicit mute handler; CoreAudio write/readback; asynchronous Bluetooth status initialization; shutdown cleanup; Air Mute identity, original app artwork and matching menu mark. The application source folder, entry-point type, bridge header and entitlements use AirMute names; historical upstream names remain in the provenance notices. No upstream icon, Xcode user state, local configuration, logs, or git history is distributed.

The app icon was generated with the built-in image_gen tool for Air Mute. Its design and packaging steps are in `ARTWORK.md`; `artwork.swift` derives the macOS iconset from the master PNG. The menu mark uses original AppKit shapes. No upstream icon, other app artwork, or assets/source from similarly named AirMute apps or MeetPods were copied.

The standard MIT text is available at https://opensource.org/license/mit. GitHub documents that a README may carry a license notice: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository.
