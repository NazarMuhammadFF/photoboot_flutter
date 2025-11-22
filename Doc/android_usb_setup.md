# Running Flutter on Android via USB

## Prerequisites

1. **Enable Developer Options on Android Device**:

   - Go to `Settings` → `About Phone`
   - Tap on `Build Number` 7 times until you see "You are now a developer!"

2. **Enable USB Debugging**:

   - Go to `Settings` → `Developer Options`
   - Enable `USB Debugging`

3. **Install USB Drivers** (Windows only):
   - Download and install the appropriate USB drivers for your Android device
   - For most devices, the drivers install automatically when you connect the device
   - Google devices: [Google USB Driver](https://developer.android.com/studio/run/win-usb)

## Steps to Run Flutter App on Android

### 1. Connect Your Device

```bash
# Connect your Android device via USB cable to your computer
```

### 2. Verify Device Connection

```bash
# Check if Flutter detects your device
flutter devices

# You should see output like:
# Android SDK built for x86 (mobile) • emulator-5554 • android-x86 • Android 11 (API 30)
# SM G950F (mobile) • 988a1b464642534638 • android-arm64 • Android 9 (API 28)
```

### 3. Accept USB Debugging Prompt

- On your Android device, you'll see a popup asking "Allow USB debugging?"
- Check "Always allow from this computer" (optional)
- Tap "OK"

### 4. Run the App

```bash
# Run on the connected Android device
flutter run

# If multiple devices are connected, specify the device ID:
flutter run -d <device-id>

# Example:
flutter run -d 988a1b464642534638
```

### 5. Build APK (Optional)

```bash
# Build a debug APK
flutter build apk --debug

# Build a release APK
flutter build apk --release

# The APK will be located at:
# build/app/outputs/flutter-apk/app-release.apk
```

## Troubleshooting

### Device Not Detected

1. **Check USB Cable**: Use a data cable, not a charging-only cable
2. **Try Different USB Port**: Some USB ports may not work properly
3. **Restart ADB**:
   ```bash
   flutter doctor
   adb kill-server
   adb start-server
   flutter devices
   ```

### "No devices detected"

1. **Verify USB Debugging is enabled** on your Android device
2. **Check USB mode**: Set to "File Transfer" or "MTP" mode (not "Charge only")
3. **Revoke USB debugging authorizations**:
   - Go to `Developer Options` → `Revoke USB debugging authorizations`
   - Reconnect device and accept the prompt again

### Permission Denied

```bash
# On Linux/Mac, you may need to set udev rules
sudo usermod -aG plugdev $USER
```

## Hot Reload During Development

Once the app is running on your device:

- Press `r` in the terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

## Tips

- Keep your device unlocked during installation
- Close other programs that might use ADB (Android Studio, etc.)
- For faster development, use `--debug` mode (default with `flutter run`)
