import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_slider.dart';
import '../widgets/animated_mood_chip.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, int> energy;
  final ValueChanged<Map<String, int>> onEnergyChanged;
  final List<String> emotions;
  final ValueChanged<String> onEmotionToggled;
  final Map<String, int> emotionIntensities;
  final ValueChanged<Map<String, int>> onIntensitiesChanged;
  final ValueChanged<String> onNavigate;
  final String userName;

  const HomeScreen({
    Key? key,
    required this.energy,
    required this.onEnergyChanged,
    required this.emotions,
    required this.onEmotionToggled,
    required this.emotionIntensities,
    required this.onIntensitiesChanged,
    required this.onNavigate,
    required this.userName,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _allEmotions = [
    {'label': 'Calm', 'color': AppColors.teal},
    {'label': 'Anxious', 'color': AppColors.purpleLight},
    {'label': 'Tired', 'color': AppColors.muted},
    {'label': 'Hopeful', 'color': AppColors.peach},
    {'label': 'Overwhelmed', 'color': AppColors.coral},
    {'label': 'Happy', 'color': AppColors.gold},
    {'label': 'Sad', 'color': AppColors.purpleDark},
    {'label': 'Grateful', 'color': AppColors.tealLight},
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Hero
            Text(
              '${_getGreeting()}, ${widget.userName.isNotEmpty ? widget.userName : "there"}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.mutedText(context),
                fontWeight: FontWeight.w500,
                letterSpacing: 1.1,
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOutQuart),
            const SizedBox(height: 8),
            Text(
              'How are you feeling today?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: AppColors.text(context),
                height: 1.2,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutQuart),
            const SizedBox(height: 28),

            // Daily Insight Glass Card
            _buildDailyInsightCard().animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
            const SizedBox(height: 24),

            // Energy Levels
            _buildEnergyCard().animate().fadeIn(delay: 300.ms, duration: 500.ms).slideX(begin: 0.1, curve: Curves.easeOutQuart),
            const SizedBox(height: 24),

            // Mood Meter
            _buildMoodMeterCard().animate().fadeIn(delay: 400.ms, duration: 500.ms).slideX(begin: 0.1, curve: Curves.easeOutQuart),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActionsRow().animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(begin: 0.2, curve: Curves.easeOutQuart),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyInsightCard() {
    return GlassCard(
      glow: true,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(AppColors.isDark(context) ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.purple.withOpacity(0.3)),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.purpleLight, size: 22)
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: Colors.white54),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY INSIGHT',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.purpleLight,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your anxiety is lower than usual this week. Great job checking in!',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENERGY LEVELS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.mutedText(context),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          _buildEnergySlider(
            label: 'Mental',
            icon: Icons.psychology_outlined,
            value: widget.energy['mental'] ?? 50,
            color: AppColors.purpleLight,
            onChanged: (val) {
              final e = Map<String, int>.from(widget.energy);
              e['mental'] = val;
              widget.onEnergyChanged(e);
            },
          ),
          const SizedBox(height: 20),
          _buildEnergySlider(
            label: 'Physical',
            icon: Icons.favorite_outline,
            value: widget.energy['physical'] ?? 50,
            color: AppColors.teal,
            onChanged: (val) {
              final e = Map<String, int>.from(widget.energy);
              e['physical'] = val;
              widget.onEnergyChanged(e);
            },
          ),
          const SizedBox(height: 20),
          _buildEnergySlider(
            label: 'Social',
            icon: Icons.people_outline,
            value: widget.energy['social'] ?? 50,
            color: AppColors.coral,
            onChanged: (val) {
              final e = Map<String, int>.from(widget.energy);
              e['social'] = val;
              widget.onEnergyChanged(e);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnergySlider({
    required String label,
    required IconData icon,
    required int value,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Text(
              '$value%',
              style: GoogleFonts.inter(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PremiumSlider(
          value: value.toDouble(),
          min: 0,
          max: 100,
          activeColor: color,
          onChanged: (v) => onChanged(v.toInt()),
        ),
      ],
    );
  }

  Widget _buildMoodMeterCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EMOTIONAL STATE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedText(context),
                  letterSpacing: 1.2,
                ),
              ),
              if (widget.emotions.isNotEmpty)
                Text(
                  '${widget.emotions.length} selected',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.purpleLight, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _allEmotions.map((mood) {
              final isSelected = widget.emotions.contains(mood['label']);
              return AnimatedMoodChip(
                label: mood['label'] as String,
                color: mood['color'] as Color,
                isSelected: isSelected,
                onTap: () => widget.onEmotionToggled(mood['label'] as String),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: 'Journal',
            subtitle: 'Clear your mind',
            icon: Icons.edit_note,
            color: AppColors.purpleLight,
            onTap: () => widget.onNavigate('journal'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            title: 'Breathe',
            subtitle: 'Take a pause',
            icon: Icons.air,
            color: AppColors.teal,
            onTap: () => widget.onNavigate('library'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              color: AppColors.text(context),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: AppColors.mutedText(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
