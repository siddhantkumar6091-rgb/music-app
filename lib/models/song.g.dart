// GENERATED CODE — hand-written to avoid requiring build_runner.
// Matches the @HiveType / @HiveField annotations in song.dart.

part of 'song.dart';

/// Hive TypeAdapter for [Song].
class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 0;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Song(
      id: fields[0] as String,
      title: fields[1] as String,
      filePath: fields[2] as String,
      artist: fields[3] as String,
      duration: fields[4] as int,
      isFavorite: fields[5] as bool,
      lastPlayed: fields[6] as DateTime?,
      dateAdded: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(8) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.lastPlayed)
      ..writeByte(7)
      ..write(obj.dateAdded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
