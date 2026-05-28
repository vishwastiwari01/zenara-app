import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/colors.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/nova_screen.dart';
import 'screens/library_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/lotus_logo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.purple,
          secondary: AppColors.teal,
          surface: AppColors.bgCard,
          error: Color(0xFFF06C8A),
        ),
        textTheme: GoogleFonts.dmSansTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _loading = true;
  bool _consentGranted = false;
  String _screen = 'home'; // 'home', 'journal', 'nova', 'library', 'therapist', 'settings'

  // Daily User States (Persisted in SharedPreferences)
  Map<String, int> _energy = {'mental': 72, 'physical': 64, 'social': 38};
  List<String> _emotions = ['Calm', 'Anxious', 'Overwhelmed'];
  Map<String, int> _emotionIntensities = {'Calm': 60, 'Anxious': 45, 'Overwhelmed': 75};

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Consent State
      final storedConsent = prefs.getBool('zenara_consent_granted') ?? false;

      // 2. Check-In Energy
      final energyJson = prefs.getString('zenara_checkin_energy');
      Map<String, int> loadedEnergy = {'mental': 72, 'physical': 64, 'social': 38};
      if (energyJson != null) {
        loadedEnergy = Map<String, int>.from(json.decode(energyJson));
      }

      // 3. Check-In Emotions List
      final emotionsJson = prefs.getString('zenara_checkin_emotions');
      List<String> loadedEmotions = ['Calm', 'Anxious', 'Overwhelmed'];
      if (emotionsJson != null) {
        loadedEmotions = List<String>.from(json.decode(emotionsJson));
      }

      // 4. Check-In Intensities Map
      final intensitiesJson = prefs.getString('zenara_checkin_intensities');
      Map<String, int> loadedIntensities = {'Calm': 60, 'Anxious': 45, 'Overwhelmed': 75};
      if (intensitiesJson != null) {
        loadedIntensities = Map<String, int>.from(json.decode(intensitiesJson));
      }

      setState(() {
        _consentGranted = storedConsent;
        _energy = loadedEnergy;
        _emotions = loadedEmotions;
        _emotionIntensities = loadedIntensities;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error loading local states: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('zenara_checkin_energy', json.encode(_energy));
      await prefs.setString('zenara_checkin_emotions', json.encode(_emotions));
      await prefs.setString('zenara_checkin_intensities', json.encode(_emotionIntensities));
    } catch (e) {
      debugPrint("Error saving local states: $e");
    }
  }

  Future<void> _handleConsentGranted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('zenara_consent_granted', true);
      setState(() {
        _consentGranted = true;
        _screen = 'home';
      });
    } catch (e) {
      debugPrint("Error saving consent status: $e");
    }
  }

  void _handleDataErased() {
    setState(() {
      _consentGranted = false;
      _screen = 'home';
      _energy = {'mental': 50, 'physical': 50, 'social': 50};
      _emotions = [];
      _emotionIntensities = {};
    });
  }

  void _toggleEmotion(String em) {
    setState(() {
      final exists = _emotions.contains(em);
      if (exists) {
        _emotions.remove(em);
      } else {
        if (_emotions.length < 5) {
          _emotions.add(em);
          if (!_emotionIntensities.containsKey(em)) {
            _emotionIntensities[em] = 50;
          }
        }
      }
      _saveStates();
    });
  }

  void _onNavigate(String tab) {
    setState(() {
      switch (tab) {
        case 'home':
          _screen = 'home';
          break;
        case 'journal':
          _screen = 'journal';
          break;
        case 'nova':
          _screen = 'nova';
          break;
        case 'library':
          _screen = 'library';
          break;
        case 'therapist':
        case 'insights':
          _screen = 'therapist';
          break;
        default:
          _screen = 'home';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LotusLogo(size: 64, glow: true),
              const SizedBox(height: 18),
              Text(
                'Loading Zenara...',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_consentGranted) {
      return WelcomeScreen(onConsentGranted: _handleConsentGranted);
    }

    final List<Map<String, dynamic>> tabs = [
      {
        'id': 'home',
        'label': 'Home',
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
      },
      {
        'id': 'journal',
        'label': 'Journal',
        'icon': Icons.menu_book_outlined,
        'activeIcon': Icons.menu_book,
      },
      {
        'id': 'nova',
        'label': 'Nova',
        'icon': Icons.forum_outlined,
        'activeIcon': Icons.forum,
      },
      {
        'id': 'library',
        'label': 'Library',
        'icon': Icons.spa_outlined,
        'activeIcon': Icons.spa,
      },
      {
        'id': 'therapist',
        'label': 'Insights',
        'icon': Icons.analytics_outlined,
        'activeIcon': Icons.analytics,
      },
    ];

    final isSettings = _screen == 'settings';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const LotusLogo(size: 26),
                      const SizedBox(width: 8),
                      Text(
                        'zenara',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_screen == 'settings') {
                          _screen = 'home';
                        } else {
                          _screen = 'settings';
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSettings ? AppColors.bgElevated : Colors.transparent,
                        border: Border.all(
                          color: isSettings ? AppColors.purple : Colors.transparent,
                        ),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: isSettings ? AppColors.purpleLight : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildActiveScreen(),
              ),
            ),

            // Bottom Navigation Bar
            Container(
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.bgCard,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: tabs.map((tab) {
                  final isActive = _screen == tab['id'];
                  final icon = isActive ? tab['activeIcon'] as IconData : tab['icon'] as IconData;
                  final color = isActive ? AppColors.purple : AppColors.muted;

                  return InkWell(
                    onTap: () => _onNavigate(tab['id'] as String),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.purple.withOpacity(0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, color: color, size: 22),
                          const SizedBox(height: 2),
                          Text(
                            tab['label'] as String,
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              color: color,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Persistent Legal Clinical Disclaimer Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bg,
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.03), width: 0.5),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Support companion — not a substitute for clinical therapy. In crisis? Call 988 or 9152987821.',
                style: GoogleFonts.dmSans(
                  color: AppColors.muted,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveScreen() {
    switch (_screen) {
      case 'journal':
        return const JournalScreen(key: ValueKey('journal'));
      case 'nova':
        return const NovaScreen(key: ValueKey('nova'));
      case 'library':
        return const LibraryScreen(key: ValueKey('library'));
      case 'therapist':
        return const InsightsScreen(key: ValueKey('therapist'));
      case 'settings':
        return SettingsScreen(
          key: const ValueKey('settings'),
          onDataErased: _handleDataErased,
        );
      case 'home':
      default:
        return HomeScreen(
          key: const ValueKey('home'),
          energy: _energy,
          onEnergyChanged: (val) {
            setState(() {
              _energy = val;
            });
            _saveStates();
          },
          emotions: _emotions,
          onEmotionToggled: _toggleEmotion,
          emotionIntensities: _emotionIntensities,
          onIntensitiesChanged: (val) {
            setState(() {
              _emotionIntensities = val;
            });
            _saveStates();
          },
          onNavigate: _onNavigate,
        );
    }
  }
}
