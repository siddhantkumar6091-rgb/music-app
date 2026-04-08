import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import '../services/database_service.dart';
import '../widgets/song_tile.dart';
import '../theme.dart';

/// Home screen — shows a greeting and the "Recently Played" list.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Returns a time-appropriate greeting.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DatabaseService, AudioPlayerService>(
      builder: (context, dbService, audioService, _) {
        final recentlyPlayed = dbService.getRecentlyPlayed();

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Greeting header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                  child: Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // ── Section title ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded,
                          color: AppTheme.primaryGreen, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Recently Played',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Empty state or list ──
              if (recentlyPlayed.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.headphones_rounded,
                            size: 72, color: AppTheme.subtleText.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        const Text(
                          'No recently played songs',
                          style: TextStyle(color: AppTheme.subtleText, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Import music from the Library tab\nand start listening!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.subtleText.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = recentlyPlayed[index];
                      return SongTile(
                        song: song,
                        onTap: () =>
                            audioService.playSong(recentlyPlayed, index),
                        onFavoriteToggle: () =>
                            dbService.toggleFavorite(song.id),
                        onRemove: () => dbService.removeSong(song.id),
                      );
                    },
                    childCount: recentlyPlayed.length,
                  ),
                ),

              // Bottom padding so contents aren't hidden behind mini-player.
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }
}
