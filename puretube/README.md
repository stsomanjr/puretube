# PureTube

Ad-free YouTube client built with Flutter. Direct stream extraction
(`youtube_explode_dart`), mpv-powered playback (`media_kit`), background
audio (`audio_service`), Picture-in-Picture, SponsorBlock auto-skip,
downloads with resume, sleep timer, watch history, bookmarks, playlists —
all local-first with Hive. No API keys, no accounts.

## Features

- 100% ad-free playback (direct stream URLs — ad segments are never requested)
- Background audio with notification / lockscreen / headset controls
- Picture-in-Picture (auto on home press + manual button)
- Custom gestures: double-tap ±10s, swipe right = volume, swipe left = brightness,
  horizontal swipe = scrub, long-press = 2x speed
- SponsorBlock auto-skip (sponsors, intros, outros, reminders)
- Sleep timer (5–60 min), playback speed 0.5x–2.0x
- Downloads (multiple qualities + audio-only) with pause/resume, offline player
- Watch history (with resume position), bookmarks, playlists, share

## Setup

1. Install Flutter 3.x stable: https://docs.flutter.dev/get-started/install
2. `flutter pub get`
3. `flutter run` on an Android device or emulator

## Build the APK

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk

flutter build apk --release --split-per-abi   # smaller, per-ABI APKs
```

## Native checklist

- `android/app/build.gradle`: `minSdk 24`, `compileSdk 34`
- `AndroidManifest.xml`: PiP flags on MainActivity
  (`supportsPictureInPicture`, `resizeableActivity`), `AudioService`
  with `foregroundServiceType="mediaPlayback"`, `MediaButtonReceiver`
- `MainActivity.kt`: the `pure_tube/pip` method channel
- `ios/Runner/Info.plist`: `UIBackgroundModes → audio`
  (iOS system PiP is not implemented — Android-first)

## Troubleshooting

| Symptom | Fix |
|---|---|
| "Could not extract streams" | YouTube rotated its bot checks → `flutter pub upgrade youtube_explode_dart`, rebuild. The extractor is isolated in `lib/core/services/youtube_extractor_service.dart`. |
| No PiP button | Android < 8.0, or the OEM disabled PiP (some MIUI builds need Settings → Apps → PureTube → Picture-in-picture → Allow). |
| No notification controls | Grant the notification permission (prompted on first launch, Android 13+). Audio plays regardless. |
| Download stuck at 0% | Stream URLs expire (~6h); retry re-extracts and resumes the partial file. |
| Hive errors after model change | Uninstall the dev build to clear old boxes (dev-only; the JSON-map schema is forward tolerant). |

## Project layout

```
lib/
  core/        # theme, DI, error, database, services, utils
  features/
    home/      # search + video grid + mini player
    player/    # player UI + controller + audio handler
    library/   # history, bookmarks, playlists, downloads
android/       # manifest, PiP channel, gradle config
ios/           # Info.plist (background audio)
```
