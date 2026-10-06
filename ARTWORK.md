# Air Mute icon

The app icon pairs white earbuds with silicone tips and short stems on a neutral pearl/frosted-glass tile. A small red slashed-microphone symbol sits between the stems. The menu-bar status mark uses a green microphone badge when unmuted and a red slashed badge when muted.

The original artwork was generated with the built-in `image_gen` tool. No Apple logo, copied product photograph or third-party app artwork is included. It is static raster artwork, not a native Icon Composer asset.

## Packaging

`AirMute/Resources/AppIcon-master.png` is the opaque raster master. `artwork.swift` applies the standard rounded-square mask and generates the iconset; `AppIcon.png` and `AppIcon.icns` are derived app assets.

From the repository root on macOS using the existing Apple tools:

```sh
swift artwork.swift AirMute/Resources/AppIcon-master.png build/AirMute.iconset
iconutil -c icns build/AirMute.iconset -o build/AppIcon.icns
cp build/AirMute.iconset/icon_512x512@2x.png build/AppIcon.png
```

The iconset includes 16, 32, 128, 256 and 512 point sizes, each at 1x and 2x. No extra dependency is used. MIT applies to project contributions to the extent rights are held; no exclusive copyright claim is made for generated imagery.
