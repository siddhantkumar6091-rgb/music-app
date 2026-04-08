import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import 'database_service.dart';

/// Repeat-mode options exposed to the UI.
enum RepeatMode { off, one, all }

/// Wraps [AudioPlayer] from just_audio and exposes a simple API
/// for play, pause, skip, seek, shuffle, and repeat.
///
/// Extends [ChangeNotifier] so widgets can react to state changes.
class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final DatabaseService _databaseService;

  // ── Playlist state ────────────────────────────────────────────────────
  List<Song> _playlist = [];
  List<Song> _originalPlaylist = []; // kept to restore order after shuffle
  int _currentIndex = -1;
  bool _isShuffleOn = false;
  RepeatMode _repeatMode = RepeatMode.off;

  AudioPlayerService(this._databaseService) {
    _initListeners();
  }

  // ── Initialisation ────────────────────────────────────────────────────

  void _initListeners() {
    // React when a track finishes.
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onSongComplete();
      }
      notifyListeners();
    });

    // Forward position & duration changes to the UI.
    _player.positionStream.listen((_) => notifyListeners());
    _player.durationStream.listen((_) => notifyListeners());
  }

  // ── Getters ───────────────────────────────────────────────────────────

  AudioPlayer get player => _player;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;

  /// The song that is currently loaded (or null).
  Song? get currentSong =>
      (_currentIndex >= 0 && _currentIndex < _playlist.length)
          ? _playlist[_currentIndex]
          : null;

  bool get isPlaying => _player.playing;
  bool get isShuffleOn => _isShuffleOn;
  RepeatMode get repeatMode => _repeatMode;

  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  // ── Playback ──────────────────────────────────────────────────────────

  /// Start playing [playlist] beginning at [index].
  Future<void> playSong(List<Song> playlist, int index) async {
    _playlist = List.from(playlist);
    _originalPlaylist = List.from(playlist);
    _currentIndex = index;
    await _loadAndPlay();
  }

  /// Internal: load the file at [_currentIndex] and start playback.
  Future<void> _loadAndPlay() async {
    if (_currentIndex < 0 || _currentIndex >= _playlist.length) return;

    final song = _playlist[_currentIndex];

    // If the file was deleted from storage, try the next song.
    if (!File(song.filePath).existsSync()) {
      if (_playlist.length > 1) {
        await skipNext();
      }
      return;
    }

    try {
      await _player.setFilePath(song.filePath);
      await _player.play();

      // Record as recently played.
      await _databaseService.updateLastPlayed(song.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing song: $e');
    }
  }

  /// Toggle between play and pause.
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  /// Skip to the next track (respects repeat mode).
  Future<void> skipNext() async {
    if (_playlist.isEmpty) return;

    if (_repeatMode == RepeatMode.one) {
      await _player.seek(Duration.zero);
      await _player.play();
    } else if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await _loadAndPlay();
    } else if (_repeatMode == RepeatMode.all) {
      _currentIndex = 0;
      await _loadAndPlay();
    }
    notifyListeners();
  }

  /// Skip to the previous track, or restart if >3 s into the song.
  Future<void> skipPrevious() async {
    if (_playlist.isEmpty) return;

    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
      await _loadAndPlay();
    } else if (_repeatMode == RepeatMode.all) {
      _currentIndex = _playlist.length - 1;
      await _loadAndPlay();
    }
    notifyListeners();
  }

  /// Seek to a specific [position] in the current song.
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // ── Shuffle & Repeat ──────────────────────────────────────────────────

  /// Toggle shuffle on/off while keeping the current song playing.
  void toggleShuffle() {
    _isShuffleOn = !_isShuffleOn;
    if (_isShuffleOn) {
      final current = _playlist[_currentIndex];
      _playlist.shuffle();
      _playlist.remove(current);
      _playlist.insert(0, current);
      _currentIndex = 0;
    } else {
      final current = _playlist[_currentIndex];
      _playlist = List.from(_originalPlaylist);
      _currentIndex = _playlist.indexOf(current);
    }
    notifyListeners();
  }

  /// Cycle repeat mode: off → all → one → off.
  void cycleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  // ── Auto-advance logic ────────────────────────────────────────────────

  void _onSongComplete() {
    switch (_repeatMode) {
      case RepeatMode.one:
        _player.seek(Duration.zero);
        _player.play();
        break;
      case RepeatMode.all:
        _currentIndex =
            (_currentIndex < _playlist.length - 1) ? _currentIndex + 1 : 0;
        _loadAndPlay();
        break;
      case RepeatMode.off:
        if (_currentIndex < _playlist.length - 1) {
          _currentIndex++;
          _loadAndPlay();
        }
        break;
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────────────

  /// Stop playback.
  Future<void> stop() async {
    await _player.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
