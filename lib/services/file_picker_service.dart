import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/song.dart';

/// Utility for picking audio files from device storage.
class FilePickerService {
  static const _uuid = Uuid();

  /// Opens the system file picker, lets the user select one or more
  /// audio files, and returns a list of [Song] objects with metadata.
  static Future<List<Song>> pickAudioFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg'],
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return [];

    return result.files
        .where((file) => file.path != null)
        .map((file) => Song(
              id: _uuid.v4(),
              title: _extractTitle(file.name),
              filePath: file.path!,
              artist: 'Unknown Artist',
              dateAdded: DateTime.now(),
            ))
        .toList();
  }

  /// Strips the file extension to get a human-readable title.
  static String _extractTitle(String filename) {
    final lastDot = filename.lastIndexOf('.');
    return (lastDot > 0) ? filename.substring(0, lastDot) : filename;
  }
}
