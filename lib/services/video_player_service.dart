import 'dart:io';
import 'package:video_player/video_player.dart';
import '../models/media_file.dart';

class VideoPlayerService {
  static final VideoPlayerService _instance = VideoPlayerService._internal();
  factory VideoPlayerService() => _instance;
  VideoPlayerService._internal();

  VideoPlayerController? _controller;
  MediaFile? _currentMedia;
  bool _isVideoMode = true;

  VideoPlayerController? get controller => _controller;
  MediaFile? get currentMedia => _currentMedia;
  bool get isVideoMode => _isVideoMode;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isPlaying => _controller?.value.isPlaying ?? false;

  Future<void> loadVideo(MediaFile media) async {
    await dispose();
    
    _currentMedia = media;
    _controller = VideoPlayerController.file(File(media.path));
    
    try {
      await _controller!.initialize();
      await _controller!.play();
    } catch (e) {
      print('Error loading video: $e');
    }
  }

  Future<void> play() async {
    await _controller?.play();
  }

  Future<void> pause() async {
    await _controller?.pause();
  }

  Future<void> seekTo(Duration position) async {
    await _controller?.seekTo(position);
  }

  Future<void> setVolume(double volume) async {
    await _controller?.setVolume(volume.clamp(0.0, 1.0));
  }

  void toggleVideoMode() {
    _isVideoMode = !_isVideoMode;
  }

  void setVideoMode(bool enabled) {
    _isVideoMode = enabled;
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    _currentMedia = null;
  }
}
