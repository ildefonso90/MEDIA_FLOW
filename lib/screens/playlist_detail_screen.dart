import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../providers/media_provider.dart';
import '../widgets/media_list_item.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final mediaProvider = context.watch<MediaProvider>();
    final playlistMedia = mediaProvider.getPlaylistMedia(playlist);

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMediaDialog(context),
          ),
        ],
      ),
      body: playlistMedia.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text('Playlist vazia'),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione músicas ou vídeos à playlist',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              itemCount: playlistMedia.length,
              onReorder: (oldIndex, newIndex) {
                playlist.reorderMedia(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final media = playlistMedia[index];
                return Dismissible(
                  key: ValueKey(media.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    mediaProvider.removeFromPlaylist(playlist.id, media.id);
                  },
                  child: MediaListItem(
                    media: media,
                    playlist: playlistMedia,
                  ),
                );
              },
            ),
      floatingActionButton: playlistMedia.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                mediaProvider.playMedia(playlistMedia[0], playlist: playlistMedia);
              },
              child: const Icon(Icons.play_arrow),
            )
          : null,
    );
  }

  void _showAddMediaDialog(BuildContext context) {
    final mediaProvider = context.read<MediaProvider>();
    final availableMedia = mediaProvider.allMedia
        .where((m) => !playlist.mediaIds.contains(m.id))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar à Playlist'),
        content: SizedBox(
          width: double.maxFinite,
          child: availableMedia.isEmpty
              ? const Center(child: Text('Nenhum ficheiro disponível'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableMedia.length,
                  itemBuilder: (context, index) {
                    final media = availableMedia[index];
                    return ListTile(
                      leading: Icon(
                        media.type == MediaType.audio
                            ? Icons.music_note
                            : Icons.video_library,
                      ),
                      title: Text(media.displayTitle),
                      subtitle: Text(media.displayArtist),
                      onTap: () {
                        mediaProvider.addToPlaylist(playlist.id, media);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
