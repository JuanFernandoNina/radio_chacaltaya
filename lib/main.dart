import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_chacaltaya/screens/EventsScreen.dart';
import 'package:radio_chacaltaya/screens/MembersScreen.dart';
import 'package:radio_chacaltaya/screens/MusicScreen.dart';
import 'package:radio_chacaltaya/screens/home_screen.dart';
import 'providers/content_provider.dart';
import 'providers/category_provider.dart';
import 'providers/carousel_provider.dart';
import 'services/supabase_service.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'providers/event_provider.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSupabaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _initSupabase();
  }

  Future<void> _initSupabase() async {
    try {
      await SupabaseService.initialize(
        supabaseUrl: 'https://cvzscfcciaegdgnyrkgg.supabase.co',
        supabaseAnonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2enNjZmNjaWFlZ2Rnbnlya2dnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA3OTQwMjMsImV4cCI6MjA3NjM3MDAyM30.dmAE84YXEtc9667I3b31fehIn_m8-9DIyBGrpppDRMY',
      );

      if (mounted) {
        setState(() => _isSupabaseInitialized = true);
      }
      debugPrint('✅ Supabase initialized');
    } catch (e) {
      debugPrint('❌ Error initializing Supabase: $e');
      if (mounted) {
        setState(() => _isSupabaseInitialized = true);
      }
    }
  }

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
        home: _isSupabaseInitialized
            ? const MainScreen()
            : const _SplashScreen(),
        //  routes: {
        //    '/admin-login': (context) => const AdminLoginScreen(),
        //  },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 208, 0),
              Color.fromARGB(255, 233, 140, 0),
              Color.fromARGB(255, 255, 166, 0),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.radio, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'Radio Chacaltaya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Cargando...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
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
