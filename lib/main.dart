import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/camera_profile.dart';
import 'models/film_stock.dart';
import 'services/storage_service.dart';
import 'screens/transposer_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/roll_logger_screen.dart';
import 'screens/fov_screen.dart';
import 'screens/gear_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF121418),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const TheFilmApp());
}

class TheFilmApp extends StatelessWidget {
  const TheFilmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Film App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0C0E),
        primaryColor: const Color(0xFFF59E0B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF59E0B),
          secondary: Color(0xFF06B6D4),
          surface: Color(0xFF121418),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  double _initialTimerSeconds = 4.0;

  List<CameraProfile> _cameras = defaultCameras;
  List<LensProfile> _lenses = defaultLenses;
  List<FilmStock> _filmStocks = defaultFilmStocks;

  @override
  void initState() {
    super.initState();
    _loadGear();
  }

  Future<void> _loadGear() async {
    final cams = await StorageService.loadCameras();
    final lenses = await StorageService.loadLenses();
    final stocks = await StorageService.loadFilmStocks();
    setState(() {
      _cameras = cams;
      _lenses = lenses;
      _filmStocks = stocks;
    });
  }

  void _onNavigateToTimer(double seconds) {
    setState(() {
      _initialTimerSeconds = seconds;
      _currentIndex = 1; // Timer tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TransposerScreen(
        filmStocks: _filmStocks,
        onNavigateToTimer: _onNavigateToTimer,
      ),
      TimerScreen(
        filmStocks: _filmStocks,
        initialSeconds: _initialTimerSeconds,
      ),
      RollLoggerScreen(
        cameras: _cameras,
        lenses: _lenses,
        filmStocks: _filmStocks,
      ),
      const FovScreen(),
      GearScreen(
        cameras: _cameras,
        lenses: _lenses,
        filmStocks: _filmStocks,
        onGearUpdated: _loadGear,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF121418),
          indicatorColor: const Color(0xFFF59E0B).withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF59E0B),
              );
            }
            return const TextStyle(fontSize: 11, color: Colors.grey);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFFF59E0B), size: 22);
            }
            return const IconThemeData(color: Colors.grey, size: 22);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) {
            HapticFeedback.selectionClick();
            setState(() => _currentIndex = idx);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.tune),
              label: 'Meter',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Timer',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Logger',
            ),
            NavigationDestination(
              icon: Icon(Icons.aspect_ratio),
              label: 'FOV',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt),
              label: 'Gear',
            ),
          ],
        ),
      ),
    );
  }
}
