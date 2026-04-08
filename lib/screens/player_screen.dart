import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import '../services/database_service.dart';
import '../theme.dart';

/// Full-screen music player with seek bar, controls, and playback modes.
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  /// Format a Duration as m:ss.
  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioPlayerService, DatabaseService>(
      builder: (context, audio, db, _) {
        final song = audio.currentSong;
        if (song == null) {
          return Scaffold(
            backgroundColor: AppTheme.darkBg,
            body: const Center(
              child: Text('No song playing',
                  style: TextStyle(color: AppTheme.subtleText)),
            ),
          );
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.35),
                  AppTheme.darkBg.withOpacity(0.95),
                  AppTheme.darkBg,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ── Top bar ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 34),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'NOW PLAYING',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: AppTheme.subtleText,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            song.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: song.isFavorite
                                ? AppTheme.primaryGreen
                                : AppTheme.subtleText,
                          ),
                          onPressed: () => db.toggleFavorite(song.id),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Album art placeholder ──
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 40,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 100,
                      color: AppTheme.primaryGreen.withOpacity(0.7),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Song info ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          song.artist,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.subtleText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Seek bar ──
                  _buildSeekBar(audio),

                  const SizedBox(height: 12),

                  // ── Main controls ──
                  _buildControls(audio),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Seek bar widget ───────────────────────────────────────────────────

  Widget _buildSeekBar(AudioPlayerService audio) {
    return StreamBuilder<Duration>(
      stream: audio.positionStream,
      builder: (context, snapshot) {
        final pos = snapshot.data ?? Duration.zero;
        final dur = audio.duration;
        final maxVal = dur.inMilliseconds.toDouble().clamp(1.0, double.infinity);
        final curVal = pos.inMilliseconds.toDouble().clamp(0.0, maxVal);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: curVal,
                  max: maxVal,
                  onChanged: (v) =>
                      audio.seek(Duration(milliseconds: v.toInt())),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(pos),
                        style: const TextStyle(
                            color: AppTheme.subtleText, fontSize: 12)),
                    Text(_fmt(dur),
                        style: const TextStyle(
                            color: AppTheme.subtleText, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Playback controls ─────────────────────────────────────────────────

  Widget _buildControls(AudioPlayerService audio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          IconButton(
            icon: Icon(
              Icons.shuffle_rounded,
              color: audio.isShuffleOn
                  ? AppTheme.primaryGreen
                  : AppTheme.subtleText,
              size: 24,
            ),
            onPressed: audio.toggleShuffle,
          ),

          // Previous
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded,
                color: Colors.white, size: 38),
            onPressed: audio.skipPrevious,
          ),

          // Play / Pause
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                audio.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.black,
                size: 36,
              ),
              onPressed: audio.togglePlayPause,
            ),
          ),

          // Next
          IconButton(
            icon: const Icon(Icons.skip_next_rounded,
                color: Colors.white, size: 38),
            onPressed: audio.skipNext,
          ),

          // Repeat
          IconButton(
            icon: Icon(
              audio.repeatMode == RepeatMode.one
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
              color: audio.repeatMode != RepeatMode.off
                  ? AppTheme.primaryGreen
                  : AppTheme.subtleText,
              size: 24,
            ),
            onPressed: audio.cycleRepeatMode,
          ),
        ],
      ),
    );
  }
}
