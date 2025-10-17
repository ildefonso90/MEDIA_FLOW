import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/media_file.dart';
import '../models/playlist.dart';
import '../models/app_settings.dart';
import '../services/audio_player_service.dart';
import '../services/video_player_service.dart';
import '../services/media_scanner_service.dart';
import '../utils/constants.dart';

class MediaProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  final VideoPlayerService _videoService = VideoPlayerService();
  
  late Box<MediaFile> _mediaBox;
  late Box<Playlist> _playlistBox;
  late Box<AppSettings> _settingsBox;
  late AppSettings _settings;

  List<MediaFile> _allMedia = [];
  List<MediaFile> _filteredMedia = [];
  List<Playlist> _playlists = [];
  
  String _searchQuery = '';
  MediaType? _filterType;
  bool _isScanning = false;
  double _scanProgress = 0.0;
  int _foundCount = 0;

  MediaProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _mediaBox = Hive.box<MediaFile>(AppConstants.hiveBoxMedia);
    _playlistBox = Hive.box<Playlist>(AppConstants.hiveBoxPlaylists);
    _settingsBox = Hive.box<AppSettings>(AppConstants.hiveBoxSettings);
    
    _settings = _settingsBox.get(AppConstants.settingsKey) ?? AppSettings();
    
    await _audioService.initialize();
    
    _loadMedia();
    _loadPlaylists();
    
    _audioService.audioPlayer.playerStateStream.listen((_) {
      notifyListeners();
    });
  }

  void _loadMedia() {
    _allMedia = _mediaBox.values.toList();
    _applyFilters();
  }

  void _loadPlaylists() {
    _playlists = _playlistBox.values.toList();
  }

  List<MediaFile> get allMedia => _allMedia;
  List<MediaFile> get filteredMedia => _filteredMedia;
  List<MediaFile> get favoriteMedia => _allMedia.where((m) => m.isFavorite).toList();
  List<MediaFile> get audioFiles => _allMedia.where((m) => m.type == MediaType.audio).toList();
  List<MediaFile> get videoFiles => _allMedia.where((m) => m.type == MediaType.video).toList();
  List<Playlist> get playlists => _playlists;
  
  AudioPlayerService get audioService => _audioService;
  VideoPlayerService get videoService => _videoService;
  AppSettings get settings => _settings;
  
  bool get isScanning => _isScanning;
  double get scanProgress => _scanProgress;
  int get foundCount => _foundCount;
  String get searchQuery => _searchQuery;
  MediaType? get filterType => _filterType;
  
  MediaFile? get currentMedia {
    if (_videoService.currentMedia != null) {
      return _videoService.currentMedia;
    }
    return _audioService.currentMedia;
  }

  bool get isPlaying {
    if (_videoService.currentMedia != null) {
      return _videoService.isPlaying;
    }
    return _audioService.isPlaying;
  }

  Future<void> scanMedia() async {
    if (_isScanning) return;
    
    _isScanning = true;
    _scanProgress = 0.0;
    _foundCount = 0;
    notifyListeners();

    try {
      await MediaScannerService.scanDevice(
        onProgress: (progress) {
          _scanProgress = progress;
          notifyListeners();
        },
        onFound: (count) {
          _foundCount = count;
          notifyListeners();
        },
      );
      
      _loadMedia();
    } catch (e) {
      print('Error scanning media: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> playMedia(MediaFile media, {List<MediaFile>? playlist}) async {
    final playlistToUse = playlist ?? _filteredMedia;
    final index = playlistToUse.indexWhere((m) => m.id == media.id);
    
    if (media.type == MediaType.audio) {
      await _videoService.dispose();
      await _audioService.setPlaylist(playlistToUse, index >= 0 ? index : 0);
    } else {
      await _audioService.stop();
      await _videoService.loadVideo(media);
    }
    
    notifyListeners();
  }

  Future<void> play() async {
    if (_videoService.currentMedia != null) {
      await _videoService.play();
    } else {
      await _audioService.play();
    }
    notifyListeners();
  }

  Future<void> pause() async {
    if (_videoService.currentMedia != null) {
      await _videoService.pause();
    } else {
      await _audioService.pause();
    }
    notifyListeners();
  }

  Future<void> next() async {
    await _audioService.next();
    notifyListeners();
  }

  Future<void> previous() async {
    await _audioService.previous();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    if (_videoService.currentMedia != null) {
      await _videoService.seekTo(position);
    } else {
      await _audioService.seek(position);
    }
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    if (_videoService.currentMedia != null) {
      await _videoService.setVolume(volume);
    } else {
      await _audioService.setVolume(volume);
    }
    _settings.volume = volume;
    _settings.save();
    notifyListeners();
  }

  void toggleShuffle() {
    _settings.shuffleEnabled = !_settings.shuffleEnabled;
    _audioService.setShuffle(_settings.shuffleEnabled);
    _settings.save();
    notifyListeners();
  }

  void cycleRepeatMode() {
    switch (_settings.repeatMode) {
      case RepeatMode.off:
        _settings.repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _settings.repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _settings.repeatMode = RepeatMode.off;
        break;
    }
    _audioService.setRepeatMode(_settings.repeatMode);
    _settings.save();
    notifyListeners();
  }

  void toggleFavorite(MediaFile media) {
    media.isFavorite = !media.isFavorite;
    media.save();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setFilterType(MediaType? type) {
    _filterType = type;
    _applyFilters();
    notifyListeners();
  }

  void setSortBy(SortBy sortBy) {
    _settings.sortBy = sortBy;
    _settings.save();
    _applyFilters();
    notifyListeners();
  }

  void toggleSortOrder() {
    _settings.sortAscending = !_settings.sortAscending;
    _settings.save();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMedia = _allMedia.where((media) {
      if (_filterType != null && media.type != _filterType) {
        return false;
      }
      
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return media.displayTitle.toLowerCase().contains(query) ||
               media.displayArtist.toLowerCase().contains(query) ||
               media.displayAlbum.toLowerCase().contains(query);
      }
      
      return true;
    }).toList();

    _filteredMedia.sort((a, b) {
      int comparison = 0;
      
      switch (_settings.sortBy) {
        case SortBy.title:
          comparison = a.displayTitle.compareTo(b.displayTitle);
          break;
        case SortBy.artist:
          comparison = a.displayArtist.compareTo(b.displayArtist);
          break;
        case SortBy.album:
          comparison = a.displayAlbum.compareTo(b.displayAlbum);
          break;
        case SortBy.dateAdded:
          comparison = a.addedDate.compareTo(b.addedDate);
          break;
        case SortBy.duration:
          final aDur = a.duration ?? 0;
          final bDur = b.duration ?? 0;
          comparison = aDur.compareTo(bDur);
          break;
      }
      
      return _settings.sortAscending ? comparison : -comparison;
    });
  }

  Future<void> createPlaylist(String name) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      mediaIds: [],
      createdDate: DateTime.now(),
      modifiedDate: DateTime.now(),
    );
    
    await _playlistBox.put(playlist.id, playlist);
    _loadPlaylists();
    notifyListeners();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _playlistBox.delete(playlistId);
    _loadPlaylists();
    notifyListeners();
  }

  Future<void> addToPlaylist(String playlistId, MediaFile media) async {
    final playlist = _playlistBox.get(playlistId);
    if (playlist != null) {
      playlist.addMedia(media.id);
      notifyListeners();
    }
  }

  Future<void> removeFromPlaylist(String playlistId, String mediaId) async {
    final playlist = _playlistBox.get(playlistId);
    if (playlist != null) {
      playlist.removeMedia(mediaId);
      notifyListeners();
    }
  }

  List<MediaFile> getPlaylistMedia(Playlist playlist) {
    return playlist.mediaIds
        .map((id) => _mediaBox.get(id))
        .whereType<MediaFile>()
        .toList();
  }
}
