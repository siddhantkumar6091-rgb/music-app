import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import '../services/database_service.dart';
import '../services/file_picker_service.dart';
import '../models/song.dart';
import '../widgets/song_tile.dart';
import '../theme.dart';

/// Library screen — two tabs: All Songs and Favorites.
/// Has a FAB to import new songs from device storage.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Import flow ─────────────────────────────────────────────────────────

  Future<void> _importSongs() async {
    if (_isImporting) return;
    setState(() => _isImporting = true);

    try {
      final songs = await FilePickerService.pickAudioFiles();
      if (songs.isNotEmpty && mounted) {
        final dbService = context.read<DatabaseService>();
        await dbService.addSongs(songs);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${songs.length} song(s) to library'),
              backgroundColor: AppTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer2<DatabaseService, AudioPlayerService>(
      builder: (context, dbService, audioService, _) {
        final allSongs = dbService.getAllSongs()
          ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        final favorites = dbService.getFavorites();

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Library',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // Import button
                    _isImporting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryGreen,
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 28),
                            onPressed: _importSongs,
                            tooltip: 'Import Songs',
                          ),
                  ],
                ),
              ),

              // ── Tab bar ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.subtleText,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'All Songs (${allSongs.length})'),
                    Tab(text: 'Favorites (${favorites.length})'),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── Tab content ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSongList(allSongs, audioService, dbService,
                        emptyMessage: 'No songs yet',
                        emptySubtext: 'Tap + to import music'),
                    _buildSongList(favorites, audioService, dbService,
                        emptyMessage: 'No favourites yet',
                        emptySubtext: 'Tap the heart icon on any song'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Renders either an empty state or a scrollable song list.
  Widget _buildSongList(
    List<Song> songs,
    AudioPlayerService audioService,
    DatabaseService dbService, {
    required String emptyMessage,
    required String emptySubtext,
  }) {
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_music_outlined,
                size: 64, color: AppTheme.subtleText.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style:
                    const TextStyle(color: AppTheme.subtleText, fontSize: 16)),
            const SizedBox(height: 6),
            Text(emptySubtext,
                style: TextStyle(
                    color: AppTheme.subtleText.withOpacity(0.6), fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return SongTile(
          song: song,
          onTap: () => audioService.playSong(songs, index),
          onFavoriteToggle: () => dbService.toggleFavorite(song.id),
          onRemove: () => dbService.removeSong(song.id),
        );
      },
    );
  }
}
