import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:metadata_god/metadata_god.dart';
import '../models/media_file.dart';
import '../utils/constants.dart';

class MediaScannerService {
  static bool _isScanning = false;
  static Function(double)? _onProgress;
  static Function(int)? _onFound;

  static Future<List<MediaFile>> scanDevice({
    Function(double)? onProgress,
    Function(int)? onFound,
  }) async {
    if (_isScanning) {
      throw Exception('Scan already in progress');
    }

    _isScanning = true;
    _onProgress = onProgress;
    _onFound = onFound;

    try {
      await MetadataGod.initialize();
      
      final List<MediaFile> foundMedia = [];
      final box = Hive.box<MediaFile>(AppConstants.hiveBoxMedia);
      
      final directories = await _getMediaDirectories();
      final allFiles = <File>[];

      for (final dir in directories) {
        if (await dir.exists()) {
          final files = await _getFilesRecursively(dir);
          allFiles.addAll(files);
        }
      }

      final totalFiles = allFiles.length;
      var processedFiles = 0;

      for (final file in allFiles) {
        try {
          final extension = file.path.split('.').last.toLowerCase();
          MediaType? type;

          if (AppConstants.audioExtensions.contains(extension)) {
            type = MediaType.audio;
          } else if (AppConstants.videoExtensions.contains(extension)) {
            type = MediaType.video;
          }

          if (type != null) {
            final existingMedia = box.values.firstWhere(
              (m) => m.path == file.path,
              orElse: () => MediaFile(
                id: '',
                path: '',
                title: '',
                type: MediaType.audio,
                addedDate: DateTime.now(),
              ),
            );

            if (existingMedia.path.isEmpty) {
              final mediaFile = await _extractMediaInfo(file, type);
              foundMedia.add(mediaFile);
              await box.put(mediaFile.id, mediaFile);
            } else {
              foundMedia.add(existingMedia);
            }
          }
        } catch (e) {
          print('Error processing file ${file.path}: $e');
        }

        processedFiles++;
        _onProgress?.call(processedFiles / totalFiles);
        _onFound?.call(foundMedia.length);
      }

      return foundMedia;
    } finally {
      _isScanning = false;
      _onProgress = null;
      _onFound = null;
    }
  }

  static Future<List<Directory>> _getMediaDirectories() async {
    final directories = <Directory>[];
    
    try {
      if (Platform.isAndroid) {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final storagePath = externalDir.path.split('Android')[0];
          
          for (final pathName in AppConstants.scanPaths) {
            final dir = Directory('$storagePath$pathName');
            if (await dir.exists()) {
              directories.add(dir);
            }
          }
          
          directories.add(Directory('$storagePath'));
        }
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        directories.add(appDir);
      }
    } catch (e) {
      print('Error getting media directories: $e');
    }

    return directories;
  }

  static Future<List<File>> _getFilesRecursively(Directory dir) async {
    final files = <File>[];
    
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final extension = entity.path.split('.').last.toLowerCase();
          if (AppConstants.audioExtensions.contains(extension) ||
              AppConstants.videoExtensions.contains(extension)) {
            files.add(entity);
          }
        }
      }
    } catch (e) {
      print('Error listing files in ${dir.path}: $e');
    }

    return files;
  }

  static Future<MediaFile> _extractMediaInfo(File file, MediaType type) async {
    final fileStats = await file.stat();
    final id = file.path.hashCode.toString();
    
    String title = file.path.split('/').last;
    String? artist;
    String? album;
    int? year;
    int? duration;
    String? artworkPath;
    int? trackNumber;
    String? genre;

    try {
      if (type == MediaType.audio) {
        final metadata = await MetadataGod.readMetadata(file: file.path);
        title = metadata.title ?? title;
        artist = metadata.artist;
        album = metadata.album;
        year = metadata.year;
        duration = metadata.durationMs;
        trackNumber = metadata.trackNumber;
        genre = metadata.genre;
        
        if (metadata.picture != null && metadata.picture!.data.isNotEmpty) {
          final tempDir = await getTemporaryDirectory();
          final artworkFile = File('${tempDir.path}/artwork_$id.jpg');
          await artworkFile.writeAsBytes(metadata.picture!.data);
          artworkPath = artworkFile.path;
        }
      }
    } catch (e) {
      print('Error extracting metadata from ${file.path}: $e');
    }

    return MediaFile(
      id: id,
      path: file.path,
      title: title,
      artist: artist,
      album: album,
      year: year,
      duration: duration,
      artworkPath: artworkPath,
      type: type,
      addedDate: fileStats.modified,
      trackNumber: trackNumber,
      genre: genre,
      fileSize: fileStats.size,
    );
  }

  static Future<void> rescanLibrary() async {
    final box = Hive.box<MediaFile>(AppConstants.hiveBoxMedia);
    final currentFiles = box.values.toList();
    
    for (final media in currentFiles) {
      final file = File(media.path);
      if (!await file.exists()) {
        await box.delete(media.id);
      }
    }
  }
}
