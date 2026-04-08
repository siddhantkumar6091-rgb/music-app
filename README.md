# 🎵 Offline Music Player

A personal offline music player built with Flutter. Import MP3s from your device — no server, no streaming, fully offline.

## Features
- **Import** MP3/WAV/FLAC/AAC/OGG files from device storage
- **Library** with All Songs & Favorites tabs
- **Player** with play/pause, next/prev, seek bar
- **Shuffle & Repeat** (off / repeat all / repeat one)
- **Recently Played** tracking on the Home screen
- **Missing-file detection** — graceful handling of deleted files
- **Dark theme** — Spotify-inspired design

## Setup Instructions

### Prerequisites
1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or later)
2. Android SDK (via Android Studio)
3. An Android device or emulator

### Steps

```bash
# 1. Navigate into the project
cd ~/Desktop/music

# 2. Generate local.properties (points to your Flutter + Android SDK)
flutter config --android-sdk /path/to/your/android/sdk

# 3. Install dependencies
flutter pub get

# 4. Run on a connected device / emulator
flutter run

# 5. (Optional) Build a release APK
flutter build apk --release
```

> **Note:** On first run Flutter will auto-create any missing platform files
> (gradlew, ic_launcher icons, etc.).

### Android Permissions
The app requests these at runtime on Android 13+:
- `READ_MEDIA_AUDIO` — to access audio files
- `WAKE_LOCK` — to keep playback alive when screen is off

## Folder Structure

```
lib/
├── main.dart                  # App entry point & Provider setup
├── theme.dart                 # Spotify-inspired dark theme
├── models/
│   ├── song.dart              # Hive data model
│   └── song.g.dart            # Hive TypeAdapter
├── services/
│   ├── database_service.dart  # Hive CRUD operations
│   ├── audio_player_service.dart  # just_audio wrapper
│   └── file_picker_service.dart   # File import utility
├── screens/
│   ├── main_screen.dart       # Bottom nav + mini player
│   ├── home_screen.dart       # Recently Played
│   ├── library_screen.dart    # All Songs / Favorites tabs
│   └── player_screen.dart     # Full-screen player
└── widgets/
    ├── mini_player.dart       # Compact playback bar
    └── song_tile.dart         # Reusable song list item
```

## Packages Used
| Package | Purpose |
|---------|---------|
| `just_audio` | Audio playback engine |
| `file_picker` | Native file browser |
| `hive` + `hive_flutter` | Lightweight local database |
| `provider` | State management |
| `path_provider` | App data directory paths |
| `uuid` | Unique song IDs |
