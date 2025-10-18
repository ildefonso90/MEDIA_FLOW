import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/media_provider.dart';
import '../models/media_file.dart';
import '../models/app_settings.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    final mediaProvider = context.watch<MediaProvider>();
    final currentMedia = mediaProvider.currentMedia;

    if (currentMedia == null) {
      Navigator.of(context).pop();
      return const SizedBox();
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            mediaProvider.previous();
          } else if (details.primaryVelocity! < 0) {
            mediaProvider.next();
          }
        },
        onVerticalDragUpdate: (details) {
          final delta = details.delta.dy;
          final currentVolume = mediaProvider.settings.volume;
          final newVolume = (currentVolume - delta / 500).clamp(0.0, 1.0);
          mediaProvider.setVolume(newVolume);
        },
        child: Stack(
          children: [
            if (currentMedia.type == MediaType.video &&
                mediaProvider.videoService.isVideoMode)
              _buildVideoPlayer(mediaProvider)
            else
              _buildAudioPlayer(currentMedia),
            if (_showControls) _buildControls(context, mediaProvider, currentMedia),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(MediaProvider mediaProvider) {
    final controller = mediaProvider.videoService.controller;
    
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildAudioPlayer(MediaFile media) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withAlpha(77),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(77),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: media.artworkPath != null && File(media.artworkPath!).existsSync()
                    ? Image.file(
                        File(media.artworkPath!),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.music_note,
                          size: 120,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    media.displayTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    media.displayArtist,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    media.displayAlbum,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, MediaProvider mediaProvider, MediaFile media) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(179),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withAlpha(230),
          ],
        ),
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Reproduzindo'),
            actions: [
              IconButton(
                icon: Icon(
                  media.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                onPressed: () => mediaProvider.toggleFavorite(media),
              ),
              if (media.type == MediaType.video)
                IconButton(
                  icon: Icon(
                    mediaProvider.videoService.isVideoMode
                        ? Icons.music_video
                        : Icons.audiotrack,
                  ),
                  onPressed: () {
                    mediaProvider.videoService.toggleVideoMode();
                    setState(() {});
                  },
                ),
            ],
          ),
          const Spacer(),
          _buildPlayerControls(mediaProvider),
        ],
      ),
    );
  }

  Widget _buildPlayerControls(MediaProvider mediaProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<Duration>(
            stream: mediaProvider.audioService.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = mediaProvider.audioService.duration ?? Duration.zero;
              
              return Column(
                children: [
                  Slider(
                    value: duration.inMilliseconds > 0
                        ? position.inMilliseconds.toDouble()
                        : 0.0,
                    min: 0.0,
                    max: duration.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      mediaProvider.seek(Duration(milliseconds: value.toInt()));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position)),
                        Text(_formatDuration(duration)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(_getRepeatIcon(mediaProvider.settings.repeatMode)),
                iconSize: 24,
                onPressed: mediaProvider.cycleRepeatMode,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: 36,
                onPressed: mediaProvider.previous,
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: IconButton(
                  icon: Icon(
                    mediaProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  iconSize: 48,
                  onPressed: () {
                    if (mediaProvider.isPlaying) {
                      mediaProvider.pause();
                    } else {
                      mediaProvider.play();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 36,
                onPressed: mediaProvider.next,
              ),
              IconButton(
                icon: Icon(
                  mediaProvider.settings.shuffleEnabled
                      ? Icons.shuffle_on_outlined
                      : Icons.shuffle,
                ),
                iconSize: 24,
                onPressed: mediaProvider.toggleShuffle,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.volume_down),
              Expanded(
                child: Slider(
                  value: mediaProvider.settings.volume,
                  onChanged: mediaProvider.setVolume,
                ),
              ),
              const Icon(Icons.volume_up),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return Icons.repeat;
      case RepeatMode.one:
        return Icons.repeat_one;
      case RepeatMode.all:
        return Icons.repeat_on;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
