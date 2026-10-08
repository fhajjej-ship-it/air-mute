# Developer ID release path

The [1.0.2 release](https://github.com/fhajjej-ship-it/air-mute/releases/tag/v1.0.2) is Developer ID signed and Apple notarized. On October 8, 2026, Apple's submission status was **Accepted**, the ticket was stapled and validated, strict signature verification passed, and Gatekeeper accepted the app as **Notarized Developer ID**. This is distinct from microphone privacy consent, which macOS still requests.

## Required credentials

- A valid **Developer ID Application** signing identity in the local keychain, including its corresponding private key. A development certificate, self-signed certificate or ad-hoc signature is insufficient.
- Authorized Apple Developer team access and a configured `notarytool` keychain credential profile. Keep passwords, API keys and private keys outside this repository.
- Apple's Command Line Tools with `codesign`, `notarytool` and `stapler`.

Apple describes [Developer ID certificates](https://developer.apple.com/help/account/certificates/create-developer-id-certificates/) and [customizing notarization](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow). Access to an Apple Developer Program team is needed to obtain Developer ID signing credentials. If no eligible membership exists, enrollment is a separate owner decision; this project does not enroll or purchase it.

## Minimal sequence after credentials are available

Run from the repository root with a fresh output directory. The following is a prepared workflow, not proof that this project has already been notarized. Use the actual configured identity/profile rather than the placeholder values; neither is a password.

```sh
export AIR_MUTE_SIGNING_IDENTITY='Developer ID Application: actual configured identity'
export AIR_MUTE_NOTARY_PROFILE='actual configured keychain profile name'
sh build.sh build/release-1.0.2
codesign --force --sign "$AIR_MUTE_SIGNING_IDENTITY" --timestamp --options runtime   --entitlements AirMute/AirMute.entitlements 'build/release-1.0.2/Air Mute.app'
codesign --verify --strict 'build/release-1.0.2/Air Mute.app'
codesign -dv --verbose=2 'build/release-1.0.2/Air Mute.app'
ditto -c -k --keepParent 'build/release-1.0.2/Air Mute.app' build/Air-Mute-1.0.2-notary.zip
xcrun notarytool submit build/Air-Mute-1.0.2-notary.zip   --keychain-profile "$AIR_MUTE_NOTARY_PROFILE" --output-format json
```

Record the returned submission UUID. Check it with `notarytool info`, or wait in bounded intervals:

```sh
xcrun notarytool wait ACTUAL_SUBMISSION_UUID   --keychain-profile "$AIR_MUTE_NOTARY_PROFILE" --timeout 60s
```

Continue only on status **Accepted**. For a failure, retrieve the notary log and fix the stated defect before submitting again. After acceptance:

```sh
xcrun stapler staple 'build/release-1.0.2/Air Mute.app'
xcrun stapler validate 'build/release-1.0.2/Air Mute.app'
codesign --verify --strict 'build/release-1.0.2/Air Mute.app'
spctl --assess --type execute --verbose=2 'build/release-1.0.2/Air Mute.app'
ditto -c -k --keepParent 'build/release-1.0.2/Air Mute.app' build/Air-Mute-1.0.2-macOS-arm64.zip
shasum -a 256 build/Air-Mute-1.0.2-macOS-arm64.zip
```

Check that the signing authority is Developer ID Application and a TeamIdentifier is present; verify the ticket and Gatekeeper assessment before publishing. Publish a versioned release from the exact reviewed commit. Download that release, compare its checksum and verify the extracted app. Never label a pending or rejected submission as notarized.

The app already uses the hardened runtime and microphone/Bluetooth entitlements. No JIT entitlement, disabled library validation, sandbox change or extra dependency is proposed. No command here disables Gatekeeper, removes quarantine or grants microphone permission.
