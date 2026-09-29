# OrbitalPulse

Polished Flutter Android app that organizes latest technology happenings with focus on:

1. **Elon Musk projects** — SpaceX, Tesla, xAI, Neuralink, Boring Company, Starlink
2. **Robotics** around the world
3. **Space technology** news
4. **Rocket launches** — scheduled windows, payload info, live-stream links

Material 3 dark theme, modern tech aesthetic, bottom navigation across the four sections.

> Feed and launch data is **sample/demo** so the UI is fully demoable offline. Comments in `lib/data/` mark where to wire live APIs later.

## Download APK (Android)

Install the latest debug build without building from source:

**Permanent latest download link:**

https://github.com/sicpoe-wq/orbital-pulse/releases/latest/download/OrbitalPulse-debug.apk

- Package ID: `com.tim.orbital_pulse`
- Build type: debug (for demo / sideload)
- On Android: enable **Install unknown apps** for your browser/file manager, then open the APK

New releases keep the same asset name (`OrbitalPulse-debug.apk`), so that link stays valid when updates are published.

Browse all versions: https://github.com/sicpoe-wq/orbital-pulse/releases

## Requirements (build from source)

- Flutter SDK 3.35+ (Dart 3.9+)
- Android SDK (API 35 recommended) + JDK 17
- Connected device or emulator for `flutter run`

## Project layout

```
lib/
  main.dart
  theme/app_theme.dart
  models/          news_item.dart, launch_item.dart
  data/            sample_news.dart, sample_launches.dart
  widgets/         news_card.dart, launch_card.dart, section_header.dart
  screens/         home_shell.dart, news_feed_screen.dart, launches_screen.dart
```

## Setup

```bash
git clone https://github.com/sicpoe-wq/orbital-pulse.git
cd orbital-pulse
flutter pub get
```

## Run on a device / emulator

```bash
flutter run
```

## Build debug APK

```bash
flutter build apk --debug
```

Output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Release (needs signing config):

```bash
flutter build apk --release
```

## Analyze

```bash
flutter analyze
```

## Dependencies

| Package | Use |
|---------|-----|
| `http` | Ready for live API calls |
| `url_launcher` | Open article / YouTube stream URLs |
| `cached_network_image` | Image caching when remote thumbs are added |
| `intl` | Date / window formatting |
| `google_fonts` | Inter + Orbitron typography |

## Notes

- Pull-to-refresh is stubbed (reloads sample data + snackbar).
- Launch **Watch stream** buttons open placeholder official YouTube channels.
- Package ID: `com.tim.orbital_pulse`
