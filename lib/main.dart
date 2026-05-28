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
import 'widgets/floating_nav_bar.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Color? customBgColor;
  ThemeState(this.themeMode, this.customBgColor);
}

final ValueNotifier<ThemeState> themeNotifier = ValueNotifier(ThemeState(ThemeMode.dark, null));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Load saved theme preference
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('zenara_is_dark') ?? true;
  themeNotifier.value = ThemeState(isDark ? ThemeMode.dark : ThemeMode.light, null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeState>(
      valueListenable: themeNotifier,
      builder: (context, themeState, _) {
        // System chrome based on theme
        final isDark = themeState.themeMode == ThemeMode.dark;
        SystemChrome.setSystemUIOverlayStyle(
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        );

        return MaterialApp(
          title: 'Zenara',
          debugShowCheckedModeBanner: false,
          themeMode: themeState.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.bgLight,
            colorScheme: const ColorScheme.light(
              primary: AppColors.purple,
              secondary: AppColors.teal,
              surface: AppColors.bgCardLight,
              onSurface: AppColors.textPrimaryLight,
              error: AppColors.coral,
            ),
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.light().textTheme,
            ).apply(
              bodyColor: AppColors.textPrimaryLight,
              displayColor: AppColors.textPrimaryLight,
            ),
            dialogBackgroundColor: AppColors.bgCardLight,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.bg,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.purple,
              secondary: AppColors.teal,
              surface: AppColors.bgCard,
              onSurface: AppColors.textPrimary,
              error: AppColors.coral,
            ),
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.dark().textTheme,
            ).apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.bgCard,
          ),
          home: const MainShell(),
        );
      },
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
  String _screen = 'home';
  String _userName = '';

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
      final storedConsent = prefs.getBool('zenara_consent_granted') ?? false;
      final storedUserName = prefs.getString('zenara_user_name') ?? '';

      final energyJson = prefs.getString('zenara_checkin_energy');
      Map<String, int> loadedEnergy = {'mental': 72, 'physical': 64, 'social': 38};
      if (energyJson != null) {
        loadedEnergy = Map<String, int>.from(json.decode(energyJson));
      }

      final emotionsJson = prefs.getString('zenara_checkin_emotions');
      List<String> loadedEmotions = ['Calm', 'Anxious', 'Overwhelmed'];
      if (emotionsJson != null) {
        loadedEmotions = List<String>.from(json.decode(emotionsJson));
      }

      final intensitiesJson = prefs.getString('zenara_checkin_intensities');
      Map<String, int> loadedIntensities = {'Calm': 60, 'Anxious': 45, 'Overwhelmed': 75};
      if (intensitiesJson != null) {
        loadedIntensities = Map<String, int>.from(json.decode(intensitiesJson));
      }

      setState(() {
        _consentGranted = storedConsent;
        _userName = storedUserName;
        _energy = loadedEnergy;
        _emotions = loadedEmotions;
        _emotionIntensities = loadedIntensities;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error loading local states: $e");
      setState(() => _loading = false);
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
      final storedUserName = prefs.getString('zenara_user_name') ?? '';
      setState(() {
        _consentGranted = true;
        _userName = storedUserName;
        _screen = 'home';
      });
    } catch (e) {
      debugPrint("Error saving consent status: $e");
    }
  }

  void _handleDataErased() {
    setState(() {
      _consentGranted = false;
      _userName = '';
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
    final isDark = AppColors.isDark(context);

    if (_loading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0B0F19), Color(0xFF130F2A), Color(0xFF0B0F19)],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFFFFF), Color(0xFFEDE9FE)],
                  ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? AppColors.purple.withOpacity(0.2) : AppColors.purpleLight.withOpacity(0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Image.asset(
                    isDark ? 'assets/logo.png' : 'assets/logo2.png',
                    width: 80,
                    height: 80,
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 2000.ms, curve: Curves.easeInOut)
                   .fadeIn(duration: 800.ms),
                ),
                const SizedBox(height: 24),
                Text(
                  'Zenara',
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.text(context),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 800.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      );
    }

    if (!_consentGranted) {
      return WelcomeScreen(onConsentGranted: _handleConsentGranted);
    }

    final List<Map<String, dynamic>> tabs = [
      {'id': 'home', 'label': 'Home', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
      {'id': 'journal', 'label': 'Journal', 'icon': Icons.menu_book_outlined, 'activeIcon': Icons.menu_book},
      {'id': 'nova', 'label': 'Nova', 'icon': Icons.forum_outlined, 'activeIcon': Icons.forum},
      {'id': 'library', 'label': 'Library', 'icon': Icons.spa_outlined, 'activeIcon': Icons.spa},
      {'id': 'therapist', 'label': 'Insights', 'icon': Icons.analytics_outlined, 'activeIcon': Icons.analytics},
    ];

    final isSettings = _screen == 'settings';

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F172A), Color(0xFF130F2A), Color(0xFF0F172A)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFEDE9FE)],
                    ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(isDark ? 'assets/logo.png' : 'assets/logo2.png', width: 28, height: 28, errorBuilder: (_, __, ___) => const LotusLogo(size: 26)),
                          const SizedBox(width: 12),
                          Text(
                            'Zenara',
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.text(context),
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _screen = _screen == 'settings' ? 'home' : 'settings';
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSettings
                                ? AppColors.purple.withOpacity(0.15)
                                : (isDark ? AppColors.bgGlass : Colors.white),
                            border: Border.all(
                              color: isSettings
                                  ? AppColors.purple.withOpacity(0.5)
                                  : (isDark ? Colors.white.withOpacity(0.1) : AppColors.borderLight),
                            ),
                            boxShadow: isDark
                                ? []
                                : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            color: isSettings ? AppColors.purpleLight : AppColors.mutedText(context),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _buildActiveScreen(),
                  ),
                ),
                // Space for floating nav bar
                const SizedBox(height: 88),
              ],
            ),
          ),

          // Floating Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: FloatingNavBar(
              activeScreenId: _screen,
              onNavigate: _onNavigate,
              tabs: tabs,
            ),
          ),
        ],
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
        return InsightsScreen(key: const ValueKey('therapist'), userName: _userName);
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
            setState(() => _energy = val);
            _saveStates();
          },
          emotions: _emotions,
          onEmotionToggled: _toggleEmotion,
          emotionIntensities: _emotionIntensities,
          onIntensitiesChanged: (val) {
            setState(() => _emotionIntensities = val);
            _saveStates();
          },
          onNavigate: _onNavigate,
          userName: _userName,
        );
    }
  }
}
