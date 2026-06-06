
# StarMaker Live Pattern Assistant - V2 Source

Flutter starter app for StarMaker/Star Treasure pattern workflow.

V2 adds live-assistant architecture:
- Native Android MethodChannel hooks
- Overlay permission flow
- Start/stop live assistant hooks
- Capture hook for future MediaProjection service
- Signal update hook
- Image matching placeholder service

Already included from V1:
- Round-wise data save
- Pattern engine
- Wrong prediction streak and AI-recheck flag
- Pattern library
- CSV export/share

Not yet complete:
- Real MediaProjection screenshot capture
- Floating overlay window
- OCR/image matching implementation

Build:
```bash
flutter pub get
flutter build apk --release
```
