---
description: Deploy production-ready APK to phone
---

# Deploy Production APK to Phone

This workflow builds a production-ready APK and installs it on your connected Android device.

## Prerequisites
- Android device connected via USB with USB debugging enabled
- Device authorized for debugging (check with `adb devices`)

## Steps

### 1. Stop any running Flutter instances
First, terminate any running debug or release sessions to free up resources.

```bash
# Press 'q' in the terminal running flutter, or use:
pkill -f "flutter run"
```

### 2. Clean the build directory
Remove any previous build artifacts to ensure a fresh build.

// turbo
```bash
flutter clean
```

### 3. Get dependencies
Fetch all required packages.

// turbo
```bash
flutter pub get
```

### 4. Build the release APK
Build an optimized, production-ready APK. This will take a few minutes.

```bash
flutter build apk --release
```

**Note**: The APK will be built at `build/app/outputs/flutter-apk/app-release.apk`

### 5. Verify the device is connected
Check that your phone is properly connected and authorized.

// turbo
```bash
adb devices
```

You should see your device listed with "device" status (not "unauthorized").

### 6. Install the APK on your phone
Install the built APK to your connected device.

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

The `-r` flag reinstalls the app if it already exists, preserving app data.

### 7. Launch the app (optional)
You can launch the app directly from the command line:

```bash
adb shell am start -n com.example.octolist/.MainActivity
```

Or simply tap the "Octolist" icon on your phone.

## Troubleshooting

### Device not found
- Ensure USB debugging is enabled on your phone
- Try a different USB cable or port
- Run `adb kill-server && adb start-server` to restart ADB

### Installation failed
- Uninstall the existing app first: `adb uninstall com.example.octolist`
- Then retry step 6

### Build errors
- Run `flutter doctor` to check for issues
- Ensure you have the latest Flutter SDK: `flutter upgrade`

## Alternative: Build App Bundle (for Play Store)

If you plan to upload to Google Play Store instead, use:

```bash
flutter build appbundle --release
```

The bundle will be at `build/app/outputs/bundle/release/app-release.aab`
