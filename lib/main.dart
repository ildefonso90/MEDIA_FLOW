import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'models/media_file.dart';
import 'models/playlist.dart';
import 'models/app_settings.dart';
import 'providers/media_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.mediaplayerapp.app.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  
  await Hive.initFlutter();
  
  Hive.registerAdapter(MediaFileAdapter());
  Hive.registerAdapter(MediaTypeAdapter());
  Hive.registerAdapter(PlaylistAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(RepeatModeAdapter());
  Hive.registerAdapter(SortByAdapter());
  
  await Hive.openBox<MediaFile>(AppConstants.hiveBoxMedia);
  await Hive.openBox<Playlist>(AppConstants.hiveBoxPlaylists);
  await Hive.openBox<AppSettings>(AppConstants.hiveBoxSettings);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
