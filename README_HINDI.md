
# Star Pattern Assistant - Version 2 Source

Bhai ye V2 development source hai. Isme V1 ke saare features ke saath live assistant ka base add kiya gaya hai.

## V2 me kya add hua
- Live Overlay screen
- Android overlay permission check/request
- Native MethodChannel base
- Capture Once hook
- Start/Stop Live Assistant hook
- Overlay update hook
- Image matching service placeholder
- Future OCR/screen-capture module ke liye structure ready

## Abhi kya baaki hai
- Real MediaProjection screen capture service
- Result strip crop
- Planet icon template matching
- Round/miss count OCR
- Actual floating overlay window

Ye sab Android native code ka next part hai. V2 source ka goal base architecture ready karna hai.

## Run
```bash
flutter pub get
flutter run
```

## APK build
```bash
flutter build apk --release
```

APK output:
`build/app/outputs/flutter-apk/app-release.apk`

## Safe rule
App auto betting/clicking nahi karega. Sirf data read, save, pattern hint aur Excel/CSV export karega.
