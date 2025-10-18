import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_file.dart';
import '../providers/media_provider.dart';
import '../screens/player_screen.dart';

class MediaListItem extends StatelessWidget {
  final MediaFile media;
  final List<MediaFile>? playlist;

  const MediaListItem({
    super.key,
    required this.media,
    this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    final mediaProvider = context.watch<MediaProvider>();
    final isCurrentlyPlaying = mediaProvider.currentMedia?.id == media.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isCurrentlyPlaying ? 4 : 1,
      child: ListTile(
        leading: _buildLeading(context, isCurrentlyPlaying),
        title: Text(
          media.displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isCurrentlyPlaying ? FontWeight.bold : FontWeight.normal,
            color: isCurrentlyPlaying
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              media.displayArtist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${media.durationFormatted} • ${media.fileSizeFormatted}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                media.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: media.isFavorite ? Colors.red : null,
              ),
              onPressed: () => mediaProvider.toggleFavorite(media),
            ),
            if (isCurrentlyPlaying && mediaProvider.isPlaying)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        onTap: () async {
          await mediaProvider.playMedia(media, playlist: playlist);
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlayerScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildLeading(BuildContext context, bool isCurrentlyPlaying) {
    if (media.artworkPath != null && File(media.artworkPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(media.artworkPath!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isCurrentlyPlaying
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        media.type == MediaType.audio ? Icons.music_note : Icons.video_library,
        color: isCurrentlyPlaying
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
