import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../providers/theme_provider.dart';
import 'library_screen.dart';
import 'favorites_screen.dart';
import 'playlists_screen.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const LibraryScreen(),
    const FavoritesScreen(),
    const PlaylistsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaProvider = context.watch<MediaProvider>();
    final hasCurrentMedia = mediaProvider.currentMedia != null;

    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (hasCurrentMedia)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: hasCurrentMedia ? 70 : 0,
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.library_music),
              label: 'Biblioteca',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            NavigationDestination(
              icon: Icon(Icons.playlist_play),
              label: 'Playlists',
            ),
          ],
        ),
      ),
    );
  }
}
