import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onDataErased;

  const SettingsScreen({Key? key, required this.onDataErased}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;
  bool _savingKey = false;
  bool _isDarkMode = false;
  Color? _customBgColor;

  final List<Map<String, dynamic>> _bgColors = [
    {'name': 'Default (Slate)', 'color': null},
    {'name': 'Soft Blue', 'color': const Color(0xFFE0F2FE)},
    {'name': 'Blush Pink', 'color': const Color(0xFFFDF2F8)},
    {'name': 'Mint Green', 'color': const Color(0xFFECFDF5)},
    {'name': 'Pure White', 'color': const Color(0xFFFFFFFF)},
  ];

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _loadThemePrefs();
  }

  Future<void> _loadThemePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('zenara_is_dark') ?? false;
      final bgVal = prefs.getInt('zenara_custom_bg');
      _customBgColor = bgVal != null ? Color(bgVal) : null;
    });
  }

  Future<void> _toggleTheme(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('zenara_is_dark', val);
    setState(() => _isDarkMode = val);
    themeNotifier.value = ThemeState(val ? ThemeMode.dark : ThemeMode.light, _customBgColor);
  }

  Future<void> _setBgColor(Color? c) async {
    final prefs = await SharedPreferences.getInstance();
    if (c == null) {
      await prefs.remove('zenara_custom_bg');
    } else {
      await prefs.setInt('zenara_custom_bg', c.value);
    }
    setState(() => _customBgColor = c);
    themeNotifier.value = ThemeState(_isDarkMode ? ThemeMode.dark : ThemeMode.light, c);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = prefs.getString('zenara_openrouter_api_key') ?? '';
    });
  }

  Future<void> _saveApiKey() async {
    setState(() {
      _savingKey = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('zenara_openrouter_api_key', _apiKeyController.text.trim());
      messenger.showSnackBar(
        SnackBar(
          content: Text('API Key saved successfully!', style: GoogleFonts.dmSans()),
          backgroundColor: AppColors.teal,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save API Key.', style: GoogleFonts.dmSans()),
          backgroundColor: const Color(0xFFF06C8A),
        ),
      );
    } finally {
      setState(() {
        _savingKey = false;
      });
    }
  }

  Future<void> _confirmDeleteData() async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFFF06C8A).withValues(alpha: 0.3), width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFF06C8A)),
              const SizedBox(width: 8),
              Text(
                'Delete Personal Data?',
                style: GoogleFonts.playfairDisplay(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            'This action is complying with the India DPDP Act 2023. It will permanently erase all journals, mood check-ins, consent parameters, and API keys. This cannot be undone.',
            style: GoogleFonts.dmSans(
              color: AppColors.muted,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.dmSans(color: AppColors.muted, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _performDataErasure();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF06C8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Erase Everything',
                style: GoogleFonts.dmSans(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDataErasure() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All personal data has been erased successfully.', style: GoogleFonts.dmSans()),
          backgroundColor: const Color(0xFFF06C8A),
        ),
      );
      widget.onDataErased();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Text(
              'Settings',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'App Preferences & Compliance',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 20),

            // Theme Appearance Card
            _buildSectionHeader('APPEARANCE'),
            const SizedBox(height: 10),
            _buildAppearanceCard(),
            const SizedBox(height: 24),

            // API Config Card
            _buildSectionHeader('AI COMPANION CONFIGURATION'),
            const SizedBox(height: 10),
            _buildApiKeyCard(),
            const SizedBox(height: 24),

            // DPDP Act Card
            _buildSectionHeader('PRIVACY & COMPLIANCE (DPDP ACT 2023)'),
            const SizedBox(height: 10),
            _buildDpdPCard(),
            const SizedBox(height: 24),

            // Clinical Disclaimer Card
            _buildSectionHeader('CLINICAL & LEGAL NOTICES'),
            const SizedBox(height: 10),
            _buildDisclaimerCard(),
            const SizedBox(height: 24),

            // Theoretical Framework Card
            _buildSectionHeader('THEORETICAL FRAMEWORK'),
            const SizedBox(height: 10),
            _buildTheoreticalFrameworkCard(),
            const SizedBox(height: 24),

            // App Version Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Zenara v1.0.0 (Flutter)',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Secure & Empathetic Space ✦',
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.muted.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dark Mode',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Switch(
                value: _isDarkMode,
                onChanged: _toggleTheme,
                activeColor: AppColors.purpleLight,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Background Color',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _bgColors.map((bg) {
                final color = bg['color'] as Color?;
                final isSelected = _customBgColor == color;
                return GestureDetector(
                  onTap: () => _setBgColor(color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color ?? AppColors.bg,
                      border: Border.all(
                        color: isSelected ? AppColors.purpleLight : AppColors.border,
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.purpleLight.withOpacity(0.3), blurRadius: 4)]
                          : null,
                    ),
                    child: color == null 
                        ? Icon(Icons.format_color_reset, size: 14, color: AppColors.muted)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.muted,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildApiKeyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'OpenRouter API Key',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your OpenRouter API Key to unlock online companion mode. Leave empty to use local offline mock responses.',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.purple.withOpacity(0.2)),
            ),
            child: TextField(
              controller: _apiKeyController,
              obscureText: _obscureApiKey,
              style: GoogleFonts.dmSans(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'sk-ant-api03-...',
                hintStyle: GoogleFonts.dmSans(color: AppColors.muted),
                border: InputBorder.none,
                isDense: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.muted,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _savingKey ? null : _saveApiKey,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              disabledBackgroundColor: AppColors.purple.withOpacity(0.3),
              foregroundColor: AppColors.textPrimary,
              minimumSize: const Size(double.infinity, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _savingKey
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).textTheme.bodyMedium?.color),
                  )
                : Text(
                    'Save API Key',
                    style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDpdPCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.teal, size: 18),
              const SizedBox(width: 8),
              Text(
                'Digital Personal Data Protection',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Under Section 12 of the India DPDP Act 2023, you have the absolute right to correct, complete, or request erasure of your personal data stored within this application.',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _confirmDeleteData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0x2EF06C8A), // faint pink
              foregroundColor: const Color(0xFFF06C8A),
              elevation: 0,
              side: BorderSide(color: const Color(0xFFF06C8A).withOpacity(0.5)),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Delete All Personal Data',
              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Clinical Support Limitations',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Zenara is a clinical tool intended to complement therapy and mindfulness practices. The AI companion (Nova) is designed for cognitive reframing and emotional support, but is NOT a clinical psychologist, psychiatrist, or medical professional.',
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'If you are experiencing severe crisis or thoughts of self-harm, please exit the app and dial emergency lifelines (e.g. 988 or 112) or seek psychiatric emergency services immediately.',
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              color: const Color(0xFFF06C8A),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTheoreticalFrameworkCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, color: AppColors.purpleLight, size: 18),
              const SizedBox(width: 8),
              Text(
                'Clinical Protocols & Safety',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Zenara is designed in accordance with established mental health app quality assessment guidelines. It incorporates core criteria from the Mobile App Rating Scale (A-MARS) and the user version (uMARS) focusing on:\n\n• Evidence of effectiveness & quality information\n• SMART goal setting strategies\n• Integration with clinical interoperability standards\n• Focus on accessible resources and active user engagement\n\nThese frameworks ensure our digital mental health services provide safe, reliable, and high-quality psychological support based on peer-reviewed evaluations.',
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Read Research Papers ↗',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
