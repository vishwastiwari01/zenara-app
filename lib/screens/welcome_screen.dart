import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../widgets/lotus_logo.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onConsentGranted;

  const WelcomeScreen({Key? key, required this.onConsentGranted}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _step = 1;
  bool _consentTherapist = false;
  bool _consentDisclaimer = false;
  
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGoal;

  final List<String> _goals = [
    'Track Mood',
    'Manage Stress',
    'Better Sleep',
    'Build Habits',
  ];

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.psychology_outlined,
      'color': AppColors.purpleLight,
      'title': 'Daily Check-Ins',
      'desc': 'Understand your emotions through tracking physical, mental and social energy.',
    },
    {
      'icon': Icons.menu_book_outlined,
      'color': AppColors.tealLight,
      'title': 'Personalized Journal',
      'desc': 'Express yourself freely via text, guided prompts and quick reflections.',
    },
    {
      'icon': Icons.forum_outlined,
      'color': AppColors.pink,
      'title': 'AI Companion',
      'desc': 'Empathetic chat support with Nova, your companion for cognitive reframing.',
    },
    {
      'icon': Icons.spa_outlined,
      'color': AppColors.peach,
      'title': 'Coping Library',
      'desc': 'Access sensory reset soundboards and grounding techniques on demand.',
    },
    {
      'icon': Icons.analytics_outlined,
      'color': AppColors.gold,
      'title': 'Therapist Insights',
      'desc': 'Bridging the gap by feeding structured trends to your clinical sessions.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _step == 1 ? _buildStep1() : _step == 2 ? _buildStep2() : _buildStep3(),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      key: const ValueKey(1),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Logo group
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple.withOpacity(0.08),
              border: Border.all(color: AppColors.purple.withOpacity(0.15), width: 1.5),
            ),
            child: const LotusLogo(size: 64, glow: true),
          ),
          const SizedBox(height: 12),
          Text(
            'zenara',
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 12, color: AppColors.purpleLight),
              const SizedBox(width: 6),
              Text(
                'Your mind. Your space. Your growth.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Features List
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x19191636), // rgba(25, 22, 54, 0.3)
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: _features.map((f) => _buildFeatureItem(f)).toList(),
            ),
          ),
          const SizedBox(height: 32),
          // Footer / Button
          Text(
            'Mindful. Intelligent. Personal. This is Zenara. ✦',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => _step = 2),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppColors.purple.withOpacity(0.4),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      key: const ValueKey(2),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          // Mini Logo Group
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple.withOpacity(0.08),
              border: Border.all(color: AppColors.purple.withOpacity(0.15)),
            ),
            child: const LotusLogo(size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            'Consent & Gateways',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Zenara is a clinical tool. Please review below.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 20),
          // Consent Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xB2191636), // rgba(25, 22, 54, 0.7)
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.purple.withOpacity(0.22), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.purpleLight, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Data Protection & Consent',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Zenara complies with India\'s Digital Personal Data Protection (DPDP) Act, 2023. We encrypt all your journals, logs, and chats using AES-256.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 18),
                // Checkbox 1
                _buildCheckboxItem(
                  value: _consentTherapist,
                  onChanged: (val) => setState(() => _consentTherapist = val ?? false),
                  label: 'I consent to sharing my daily mood trends and journal summaries with my licensed therapist (Dr. Hayes).',
                ),
                const SizedBox(height: 12),
                // Checkbox 2
                _buildCheckboxItem(
                  value: _consentDisclaimer,
                  onChanged: (val) => setState(() => _consentDisclaimer = val ?? false),
                  label: 'I understand that the AI companion (Nova) is a supportive tool and NOT a licensed medical professional.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Disclaimer Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0x0FF06C8A), // rgba(240, 108, 138, 0.06)
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x2EF06C8A)), // rgba(240, 108, 138, 0.18)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFF06C8A), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'PERSISTENT CLINICAL DISCLAIMER',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF06C8A),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'In case of crisis, emergency, or self-harm thoughts, please close the app and call local emergency services immediately.',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    height: 1.4,
                    color: const Color(0xFFF06C8A).withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Enter App Button
          ElevatedButton(
            onPressed: (_consentTherapist && _consentDisclaimer) ? () => setState(() => _step = 3) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              disabledBackgroundColor: AppColors.purple.withOpacity(0.2),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withOpacity(0.4),
              elevation: (_consentTherapist && _consentDisclaimer) ? 4 : 0,
              shadowColor: AppColors.purple.withOpacity(0.4),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.check, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _step = 1),
            child: Text(
              'Back',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final canSubmit = _nameController.text.trim().isNotEmpty && _selectedGoal != null;
    return SingleChildScrollView(
      key: const ValueKey(3),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple.withOpacity(0.08),
              border: Border.all(color: AppColors.purple.withOpacity(0.15)),
            ),
            child: const LotusLogo(size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Personalize Zenara',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\\'s set up your space.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 32),
          
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'What should we call you?',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.dmSans(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. Sarah',
              hintStyle: GoogleFonts.dmSans(color: AppColors.muted),
              filled: true,
              fillColor: AppColors.bgElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.purple),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'What is your primary focus?',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _goals.map((goal) {
              final isSelected = _selectedGoal == goal;
              return GestureDetector(
                onTap: () => setState(() => _selectedGoal = goal),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.purple : AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.purple : AppColors.border,
                    ),
                  ),
                  child: Text(
                    goal,
                    style: GoogleFonts.dmSans(
                      color: isSelected ? Colors.white : AppColors.muted,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: canSubmit ? () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('zenara_user_name', _nameController.text.trim());
              await prefs.setString('zenara_primary_goal', _selectedGoal!);
              widget.onConsentGranted();
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              disabledBackgroundColor: AppColors.purple.withOpacity(0.2),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withOpacity(0.4),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Complete Onboarding',
                  style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.check, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _step = 2),
            child: Text(
              'Back',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(Map<String, dynamic> f) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(f['icon'] as IconData, color: f['color'] as Color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f['title'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  f['desc'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 11.5,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2, right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppColors.purple : AppColors.muted,
                  width: 1.5,
                ),
                color: value ? AppColors.purple : Colors.white.withOpacity(0.02),
                boxShadow: value
                    ? [
                        BoxShadow(
                          color: AppColors.purple.withOpacity(0.5),
                          blurRadius: 4,
                        )
                      ]
                    : null,
              ),
              child: value
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  height: 1.45,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
