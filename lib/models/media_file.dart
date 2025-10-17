import 'package:hive/hive.dart';

part 'media_file.g.dart';

@HiveType(typeId: 0)
class MediaFile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String path;

  @HiveField(2)
  String title;

  @HiveField(3)
  String? artist;

  @HiveField(4)
  String? album;

  @HiveField(5)
  int? year;

  @HiveField(6)
  int? duration;

  @HiveField(7)
  String? artworkPath;

  @HiveField(8)
  MediaType type;

  @HiveField(9)
  bool isFavorite;

  @HiveField(10)
  DateTime addedDate;

  @HiveField(11)
  int? trackNumber;

  @HiveField(12)
  String? genre;

  @HiveField(13)
  int? fileSize;

  MediaFile({
    required this.id,
    required this.path,
    required this.title,
    this.artist,
    this.album,
    this.year,
    this.duration,
    this.artworkPath,
    required this.type,
    this.isFavorite = false,
    required this.addedDate,
    this.trackNumber,
    this.genre,
    this.fileSize,
  });

  String get displayTitle => title.isNotEmpty ? title : _getFileNameWithoutExtension();
  String get displayArtist => artist ?? 'Artista Desconhecido';
  String get displayAlbum => album ?? 'Álbum Desconhecido';

  String _getFileNameWithoutExtension() {
    final fileName = path.split('/').last;
    final lastDot = fileName.lastIndexOf('.');
    return lastDot != -1 ? fileName.substring(0, lastDot) : fileName;
  }

  String get durationFormatted {
    if (duration == null) return '--:--';
    final dur = Duration(milliseconds: duration!);
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);
    final seconds = dur.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String get fileSizeFormatted {
    if (fileSize == null) return '--';
    final kb = fileSize! / 1024;
    final mb = kb / 1024;
    if (mb >= 1) {
      return '${mb.toStringAsFixed(1)} MB';
    }
    return '${kb.toStringAsFixed(1)} KB';
  }
}

@HiveType(typeId: 1)
enum MediaType {
  @HiveField(0)
  audio,
  
  @HiveField(1)
  video,
}
