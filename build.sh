#!/bin/sh
set -eu

if [ "$#" -gt 1 ]; then
    echo 'Usage: sh build.sh [OUTPUT_DIRECTORY]' >&2
    exit 1
fi
if [ "$(uname -s)" != Darwin ]; then
    echo 'This local build requires macOS and the Apple SDK.' >&2
    exit 1
fi
source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
output_dir=${1:-build}
mkdir -p "$output_dir"
output_dir=$(cd "$output_dir" && pwd)
app="$output_dir/Air Mute.app"
if [ -e "$app" ]; then
    echo "Refusing to overwrite: $app" >&2
    exit 1
fi
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
arch=$(uname -m)
swiftc -swift-version 5 -target "$arch-apple-macosx14.0" \
    -import-objc-header "$source_dir/AirMute/Bridge/AirMute-Bridging-Header.h" \
    -framework Cocoa -framework CoreAudio -framework IOBluetooth -framework AVFAudio \
    "$source_dir/AirMute/App/AirMuteApp.swift" \
    "$source_dir/AirMute/App/AppDelegate.swift" \
    "$source_dir/AirMute/Services/AudioAccessoryMonitor.swift" \
    "$source_dir/AirMute/Services/AudioMuteController.swift" \
    "$source_dir/AirMute/Services/BluetoothManager.swift" \
    "$source_dir/AirMute/UI/StatusBarController.swift" \
    -o "$app/Contents/MacOS/AirMute"
python3 - "$source_dir" "$app" <<'PY'
import pathlib, plistlib, shutil, sys
source, app = map(pathlib.Path, sys.argv[1:])
data = plistlib.loads((source/'AirMute/App/Info.plist').read_bytes())
data.update(CFBundleDevelopmentRegion='en', CFBundleExecutable='AirMute',
            CFBundleIdentifier='com.fhajjejshipit.airmute', CFBundleName='Air Mute',
            CFBundleDisplayName='Air Mute', CFBundlePackageType='APPL',
            LSMinimumSystemVersion='14.0')
(app/'Contents/Info.plist').write_bytes(plistlib.dumps(data))
shutil.copyfile(source/'AirMute/Resources/AppIcon.icns', app/'Contents/Resources/AppIcon.icns')
for name in ['LICENSE', 'UPSTREAM.md']:
    shutil.copyfile(source/name, app/'Contents/Resources'/name)
shutil.copyfile(source/'upstream/README.md', app/'Contents/Resources/UPSTREAM-README.md')
PY
# Remove only Finder metadata from this newly created local bundle if present.
if xattr "$app" | grep -qx com.apple.FinderInfo; then
    xattr -d com.apple.FinderInfo "$app"
fi
codesign --force --sign - --identifier com.fhajjejshipit.airmute --options runtime \
    --entitlements "$source_dir/AirMute/AirMute.entitlements" "$app"
codesign --verify --strict "$app"
echo "Built locally: $app"
echo 'Ad-hoc signed; not notarized. Not installed or launched.'
