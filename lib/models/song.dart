import 'package:hive/hive.dart';

part 'song.g.dart';

/// Song model — stores metadata about an imported audio file.
/// The actual audio file stays on the device; we only save the [filePath].
@HiveType(typeId: 0)
class Song extends HiveObject {
  /// Unique identifier (UUID v4).
  @HiveField(0)
  final String id;

  /// Display name extracted from the filename.
  @HiveField(1)
  final String title;

  /// Absolute path to the audio file on the device.
  @HiveField(2)
  final String filePath;

  /// Artist name (defaults to 'Unknown Artist').
  @HiveField(3)
  final String artist;

  /// Duration of the track in milliseconds (0 if unknown).
  @HiveField(4)
  final int duration;

  /// Whether the user has marked this song as a favourite.
  @HiveField(5)
  bool isFavorite;

  /// Timestamp of when this song was last played (null = never played).
  @HiveField(6)
  DateTime? lastPlayed;

  /// Timestamp of when the song was imported into the library.
  @HiveField(7)
  final DateTime dateAdded;

  Song({
    required this.id,
    required this.title,
    required this.filePath,
    this.artist = 'Unknown Artist',
    this.duration = 0,
    this.isFavorite = false,
    this.lastPlayed,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();
}
