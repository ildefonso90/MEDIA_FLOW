import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../providers/theme_provider.dart';
import '../models/media_file.dart';
import '../models/app_settings.dart';
import '../widgets/media_list_item.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaProvider = context.watch<MediaProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              if (value == 'all') {
                mediaProvider.setFilterType(null);
              } else if (value == 'audio') {
                mediaProvider.setFilterType(MediaType.audio);
              } else if (value == 'video') {
                mediaProvider.setFilterType(MediaType.video);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Todos')),
              const PopupMenuItem(value: 'audio', child: Text('Apenas Áudio')),
              const PopupMenuItem(value: 'video', child: Text('Apenas Vídeo')),
            ],
          ),
          PopupMenuButton<SortBy>(
            icon: const Icon(Icons.sort),
            onSelected: mediaProvider.setSortBy,
            itemBuilder: (context) => const [
              PopupMenuItem(value: SortBy.title, child: Text('Título')),
              PopupMenuItem(value: SortBy.artist, child: Text('Artista')),
              PopupMenuItem(value: SortBy.album, child: Text('Álbum')),
              PopupMenuItem(value: SortBy.dateAdded, child: Text('Data')),
              PopupMenuItem(value: SortBy.duration, child: Text('Duração')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
              ),
              onChanged: mediaProvider.setSearchQuery,
            ),
          ),
          if (mediaProvider.isScanning)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(value: mediaProvider.scanProgress),
                  const SizedBox(height: 8),
                  Text(
                    'Encontrados: ${mediaProvider.foundCount} ficheiros',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          Expanded(
            child: mediaProvider.filteredMedia.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text('Nenhum ficheiro encontrado'),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: mediaProvider.scanMedia,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Procurar Ficheiros'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: mediaProvider.scanMedia,
                    child: ListView.builder(
                      itemCount: mediaProvider.filteredMedia.length,
                      itemBuilder: (context, index) {
                        final media = mediaProvider.filteredMedia[index];
                        return MediaListItem(media: media);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mediaProvider.scanMedia,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
