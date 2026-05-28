import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

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
    {'label': 'Calm', 'color': Color(0xFF4ECDC4)},
    {'label': 'Anxious', 'color': Color(0xFFA89AF7)},
    {'label': 'Tired', 'color': Color(0xFF7C9ABF)},
    {'label': 'Hopeful', 'color': Color(0xFFF7C59F)},
    {'label': 'Overwhelmed', 'color': Color(0xFFF7A8D4)},
    {'label': 'Happy', 'color': Color(0xFFF7E08A)},
    {'label': 'Sad', 'color': Color(0xFF7C6FF7)},
    {'label': 'Grateful', 'color': Color(0xFF4ECDC4)},
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              '${_getGreeting()}, ${widget.userName.isNotEmpty ? widget.userName : "there"}',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'How are you feeling today?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 20),

            // Daily Insight
            _buildDailyInsightCard(),
            const SizedBox(height: 16),

            // Energy Levels
            _buildEnergyCard(),
            const SizedBox(height: 16),

            // Mood Meter
            _buildMoodMeterCard(),
            const SizedBox(height: 16),

            // Quick Actions
            _buildQuickActionsRow(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyInsightCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF221B4A), Color(0xFF1A1340)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.purpleLight, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY INSIGHT',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.purpleLight,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your anxiety is lower than usual this week. Great job checking in!',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    height: 1.5,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENERGY LEVELS',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.muted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          _buildEnergySlider(
            label: 'Mental',
            icon: Icons.psychology_outlined,
            value: widget.energy['mental'] ?? 50,
            color: AppColors.purple,
            onChanged: (val) {
              final e = Map<String, int>.from(widget.energy);
              e['mental'] = val;
              widget.onEnergyChanged(e);
            },
          ),
          const SizedBox(height: 18),
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
          const SizedBox(height: 18),
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
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '$value%',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: AppColors.textPrimary.withValues(alpha: 0.07),
            trackHeight: 8.0,
            thumbColor: color,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9.0),
            overlayColor: color.withValues(alpha: 0.15),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18.0),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodMeterCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MOOD METER',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.muted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select up to 5 emotions',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _allEmotions.map((em) {
              final label = em['label'] as String;
              final color = em['color'] as Color;
              final selected = widget.emotions.contains(label);
              final intensity = widget.emotionIntensities[label] ?? 50;

              return GestureDetector(
                onTap: () => widget.onEmotionToggled(label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? color.withValues(alpha: 0.12)
                        : AppColors.textPrimary.withValues(alpha: 0.04),
                    border: Border.all(
                      color: selected ? color : AppColors.textPrimary.withValues(alpha: 0.12),
                      width: selected ? 2.0 : 1.0,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.25),
                              blurRadius: 14,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: selected ? AppColors.textPrimary : AppColors.muted,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (selected) ...[
                        const SizedBox(height: 3),
                        Text(
                          '$intensity%',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.menu_book_outlined,
        'label': 'Journal',
        'tab': 'journal',
        'color': AppColors.purple,
      },
      {
        'icon': Icons.forum_outlined,
        'label': 'Nova',
        'tab': 'nova',
        'color': AppColors.purpleLight,
      },
      {
        'icon': Icons.spa_outlined,
        'label': 'Library',
        'tab': 'library',
        'color': AppColors.teal,
      },
      {
        'icon': Icons.analytics_outlined,
        'label': 'Insights',
        'tab': 'therapist',
        'color': AppColors.gold,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.muted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: items.asMap().entries.map((entry) {
            final idx = entry.key;
            final action = entry.value;
            final Color color = action['color'] as Color;

            return Expanded(
              child: GestureDetector(
                onTap: () => widget.onNavigate(action['tab'] as String),
                child: Container(
                  margin: EdgeInsets.only(right: idx < items.length - 1 ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(action['icon'] as IconData, color: color, size: 22),
                      const SizedBox(height: 6),
                      Text(
                        action['label'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
