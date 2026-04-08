import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/song.dart';

/// Manages all local database operations using Hive.
/// Extends [ChangeNotifier] so the UI rebuilds when data changes.
class DatabaseService extends ChangeNotifier {
  static const String _boxName = 'songs';
  late Box<Song> _songBox;

  /// Open the Hive box — call once at app startup.
  Future<void> init() async {
    _songBox = await Hive.openBox<Song>(_boxName);
  }

  // ── READ ────────────────────────────────────────────────────────────────

  /// Returns every song in the library.
  List<Song> getAllSongs() => _songBox.values.toList();

  /// Returns only songs marked as favourite.
  List<Song> getFavorites() =>
      _songBox.values.where((s) => s.isFavorite).toList();

  /// Returns songs that have been played, sorted most-recent first.
  List<Song> getRecentlyPlayed({int limit = 20}) {
    final songs = _songBox.values
        .where((s) => s.lastPlayed != null)
        .toList()
      ..sort((a, b) => b.lastPlayed!.compareTo(a.lastPlayed!));
    return songs.take(limit).toList();
  }

  /// Look up a single song by its id.
  Song? getSong(String id) => _songBox.get(id);

  // ── WRITE ───────────────────────────────────────────────────────────────

  /// Import a single song into the library.
  Future<void> addSong(Song song) async {
    await _songBox.put(song.id, song);
    notifyListeners();
  }

  /// Import multiple songs at once.
  Future<void> addSongs(List<Song> songs) async {
    final map = {for (var song in songs) song.id: song};
    await _songBox.putAll(map);
    notifyListeners();
  }

  /// Remove a song from the library (e.g. when file is missing).
  Future<void> removeSong(String id) async {
    await _songBox.delete(id);
    notifyListeners();
  }

  /// Toggle the isFavorite flag and persist it.
  Future<void> toggleFavorite(String id) async {
    final song = _songBox.get(id);
    if (song != null) {
      song.isFavorite = !song.isFavorite;
      await song.save();
      notifyListeners();
    }
  }

  /// Record a play event for the given song.
  Future<void> updateLastPlayed(String id) async {
    final song = _songBox.get(id);
    if (song != null) {
      song.lastPlayed = DateTime.now();
      await song.save();
      notifyListeners();
    }
  }
}
