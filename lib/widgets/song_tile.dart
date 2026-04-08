import 'dart:io';
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../theme.dart';

/// A reusable list tile for displaying a song in any list.
/// Shows a "File not found" state when the backing file is missing.
class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onRemove;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.onFavoriteToggle,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final fileExists = File(song.filePath).existsSync();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        // ── Leading icon ──
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: fileExists
                ? AppTheme.primaryGreen.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            fileExists ? Icons.music_note_rounded : Icons.error_outline_rounded,
            color: fileExists ? AppTheme.primaryGreen : Colors.red,
          ),
        ),
        // ── Title ──
        title: Text(
          song.title,
          style: TextStyle(
            color: fileExists ? Colors.white : Colors.red[300],
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        // ── Subtitle ──
        subtitle: Text(
          fileExists ? song.artist : 'File not found',
          style: TextStyle(
            color: fileExists ? AppTheme.subtleText : Colors.red[200],
            fontSize: 13,
          ),
        ),
        // ── Trailing action ──
        trailing: fileExists
            ? IconButton(
                icon: Icon(
                  song.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: song.isFavorite
                      ? AppTheme.primaryGreen
                      : AppTheme.subtleText,
                ),
                onPressed: onFavoriteToggle,
              )
            : IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                onPressed: onRemove,
              ),
        onTap: fileExists ? onTap : null,
      ),
    );
  }
}
