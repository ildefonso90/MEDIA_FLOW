import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import '../models/media_file.dart';
import '../models/app_settings.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  List<MediaFile> _playlist = [];
  int _currentIndex = 0;
  bool _shuffleEnabled = false;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<MediaFile> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  MediaFile? get currentMedia => _playlist.isEmpty ? null : _playlist[_currentIndex];

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<double> get volumeStream => _audioPlayer.volumeStream;

  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  double get volume => _audioPlayer.volume;

  Future<void> initialize() async {
    _audioPlayer.playbackEventStream.listen((event) {},
      onError: (Object e, StackTrace stackTrace) {
        print('A stream error occurred: $e');
      },
    );
  }

  Future<void> setPlaylist(List<MediaFile> playlist, int initialIndex) async {
    _playlist = playlist.where((m) => m.type == MediaType.audio).toList();
    _currentIndex = initialIndex;
    
    if (_playlist.isEmpty) return;

    await _loadAndPlay(_playlist[_currentIndex]);
  }

  Future<void> _loadAndPlay(MediaFile media) async {
    try {
      final mediaItem = MediaItem(
        id: media.id,
        title: media.displayTitle,
        artist: media.displayArtist,
        album: media.displayAlbum,
        duration: media.duration != null ? Duration(milliseconds: media.duration!) : null,
        artUri: media.artworkPath != null ? Uri.file(media.artworkPath!) : null,
      );

      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.file(media.path),
          tag: mediaItem,
        ),
      );
      
      await _audioPlayer.play();
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;

    if (_shuffleEnabled) {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }

    await _loadAndPlay(_playlist[_currentIndex]);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;

    if (_audioPlayer.position.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
    } else {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      await _loadAndPlay(_playlist[_currentIndex]);
    }
  }

  void setShuffle(bool enabled) {
    _shuffleEnabled = enabled;
  }

  void setRepeatMode(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
      case RepeatMode.one:
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.all:
        _audioPlayer.setLoopMode(LoopMode.all);
        break;
    }
  }

  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    
    _currentIndex = index;
    await _loadAndPlay(_playlist[_currentIndex]);
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
