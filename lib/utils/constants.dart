class AppConstants {
  static const String appName = 'Media Player';
  
  static const List<String> audioExtensions = [
    'mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma', 'opus'
  ];
  
  static const List<String> videoExtensions = [
    'mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv', '3gp', 'webm'
  ];
  
  static const List<String> scanPaths = [
    'Download',
    'Downloads',
    'Music',
    'Movies',
    'DCIM',
    'Audio',
    'Video',
    'Media',
  ];
  
  static const String hiveBoxMedia = 'media_box';
  static const String hiveBoxPlaylists = 'playlists_box';
  static const String hiveBoxSettings = 'settings_box';
  
  static const String settingsKey = 'app_settings';
  
  static const int notificationId = 1001;
}
