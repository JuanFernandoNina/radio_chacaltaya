import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:radio_chacaltaya/screens/EventsScreen.dart';
import 'package:radio_chacaltaya/screens/MembersScreen.dart';
import 'package:radio_chacaltaya/screens/MusicScreen.dart';
import 'package:radio_chacaltaya/screens/home_screen.dart';
import 'firebase_options.dart'; // 🔥 Archivo que creaste
import 'providers/content_provider.dart';
import 'providers/category_provider.dart';
import 'providers/carousel_provider.dart';
import 'providers/event_provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicializar JustAudioBackground para reproducción en segundo plano
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.radio_chacaltaya.channel.audio',
    androidNotificationChannelName: 'Radio Chacaltaya Audio',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
    androidNotificationClickStartsActivity: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
    notificationColor: const Color(0xFFFFB700),
  );

  // ✅ Inicializar localización en español
  await initializeDateFormatting('es', null);

  // 🔥 Inicializar Firebase (reemplaza Supabase)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CarouselProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Montserrat',
        ),
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MembersScreen(),
    const GruposScreen(),
    const EventsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color.fromARGB(255, 255, 196, 0),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.home_12_regular),
          activeIcon: Icon(FluentIcons.home_12_filled),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.people_12_regular),
          activeIcon: Icon(FluentIcons.people_12_filled),
          label: 'Miembros',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.music_note_2_24_regular),
          activeIcon: Icon(FluentIcons.music_note_2_24_filled),
          label: 'Música',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.calendar_16_regular),
          activeIcon: Icon(FluentIcons.calendar_12_filled),
          label: 'Eventos',
        ),
      ],
    );
  }
}