import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  RepeatMode repeatMode;

  @HiveField(2)
  bool shuffleEnabled;

  @HiveField(3)
  double volume;

  @HiveField(4)
  SortBy sortBy;

  @HiveField(5)
  bool sortAscending;

  @HiveField(6)
  bool autoScanOnStartup;

  AppSettings({
    this.isDarkMode = false,
    this.repeatMode = RepeatMode.off,
    this.shuffleEnabled = false,
    this.volume = 0.7,
    this.sortBy = SortBy.title,
    this.sortAscending = true,
    this.autoScanOnStartup = true,
  });
}

@HiveType(typeId: 4)
enum RepeatMode {
  @HiveField(0)
  off,
  
  @HiveField(1)
  one,
  
  @HiveField(2)
  all,
}

@HiveType(typeId: 5)
enum SortBy {
  @HiveField(0)
  title,
  
  @HiveField(1)
  artist,
  
  @HiveField(2)
  album,
  
  @HiveField(3)
  dateAdded,
  
  @HiveField(4)
  duration,
}
