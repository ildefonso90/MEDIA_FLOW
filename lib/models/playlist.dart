import 'package:hive/hive.dart';

part 'playlist.g.dart';

@HiveType(typeId: 2)
class Playlist extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> mediaIds;

  @HiveField(3)
  DateTime createdDate;

  @HiveField(4)
  DateTime modifiedDate;

  @HiveField(5)
  String? artworkPath;

  Playlist({
    required this.id,
    required this.name,
    required this.mediaIds,
    required this.createdDate,
    required this.modifiedDate,
    this.artworkPath,
  });

  int get itemCount => mediaIds.length;

  void addMedia(String mediaId) {
    if (!mediaIds.contains(mediaId)) {
      mediaIds.add(mediaId);
      modifiedDate = DateTime.now();
      save();
    }
  }

  void removeMedia(String mediaId) {
    mediaIds.remove(mediaId);
    modifiedDate = DateTime.now();
    save();
  }

  void reorderMedia(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = mediaIds.removeAt(oldIndex);
    mediaIds.insert(newIndex, item);
    modifiedDate = DateTime.now();
    save();
  }
}
