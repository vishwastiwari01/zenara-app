import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _activeTab = 'Overview';

  final List<Map<String, dynamic>> _stats = [
    {'label': 'Anxiety', 'value': '↓ 18%', 'color': AppColors.teal},
    {'label': 'Sleep Quality', 'value': '↑ 12%', 'color': AppColors.purpleLight},
    {'label': 'Energy', 'value': '↑ 8%', 'color': AppColors.gold},
  ];

  final List<Map<String, dynamic>> _themes = [
    {'label': 'Work Stress', 'pct': 32, 'color': AppColors.purpleLight},
    {'label': 'Self Worth', 'pct': 24, 'color': AppColors.teal},
    {'label': 'Burnout', 'pct': 18, 'color': AppColors.pink},
    {'label': 'Relationships', 'pct': 14, 'color': AppColors.peach},
    {'label': 'Other', 'pct': 12, 'color': AppColors.muted},
  ];

  final List<String> _daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                const SizedBox(height: 24),
                _buildTabs().animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildActiveTabContent(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = AppColors.isDark(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.purple.withOpacity(isDark ? 0.3 : 0.15)),
              ),
              child: const Icon(Icons.analytics_outlined, color: AppColors.purpleLight, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              'THERAPIST PORTAL',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.mutedText(context),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Sarah Johnson',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Last session: May 24, 2026 (with Dr. Hayes)',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.purpleLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final isDark = AppColors.isDark(context);
    final List<String> tabs = ['Overview', 'Mood', 'Themes', 'Sessions'];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgGlass : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : AppColors.borderLight),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isActive = _activeTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = tab),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.purple.withOpacity(isDark ? 0.4 : 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isActive ? [BoxShadow(color: AppColors.purple.withOpacity(0.3), blurRadius: 12)] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  tab,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? (isDark ? Colors.white : AppColors.purple)
                        : AppColors.mutedText(context),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 'Mood':
        return _buildMoodTab();
      case 'Themes':
        return _buildThemesTab();
      case 'Sessions':
        return _buildSessionsTab();
      case 'Overview':
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      key: const ValueKey('Overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (int i = 0; i < _stats.length; i++) ...[
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Column(
                    children: [
                      Text(
                        _stats[i]['value'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _stats[i]['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _stats[i]['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.mutedText(context),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 200 + (i * 100))).slideY(begin: 0.1),
              ),
              if (i < _stats.length - 1) const SizedBox(width: 12),
            ]
          ],
        ),
        const SizedBox(height: 24),
        _buildMoodTrendChart().animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
        const SizedBox(height: 24),
        _buildAiSummaryCard().animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMoodTab() {
    return Column(
      key: const ValueKey('Mood'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMoodTrendChart(),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ENERGY LEVEL SPLIT',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedText(context),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildProgressRow('Mental', 65, AppColors.purpleLight),
              const SizedBox(height: 16),
              _buildProgressRow('Physical', 40, AppColors.teal),
              const SizedBox(height: 16),
              _buildProgressRow('Social', 30, AppColors.coral),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildThemesTab() {
    return Column(
      key: const ValueKey('Themes'),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOP THEMES IDENTIFIED BY NOVA',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedText(context),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              for (var theme in _themes) ...[
                _buildProgressRow(theme['label'] as String, theme['pct'] as int, theme['color'] as Color),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsTab() {
    final isDark = AppColors.isDark(context);
    return Column(
      key: const ValueKey('Sessions'),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CLINICAL NOTES',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedText(context),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildSessionItem(
                date: 'May 24, 2026',
                topic: 'Boundary Setting & Work-Life Separation',
                notes: 'Dr. Hayes noted: Sarah is practicing asserting boundaries but feels immense guilt. Plan is to address self-worth blocks.',
              ),
              Divider(color: isDark ? Colors.white.withOpacity(0.1) : AppColors.borderLight, height: 32),
              _buildSessionItem(
                date: 'May 17, 2026',
                topic: 'Reframing Imposter Syndrome',
                notes: 'Explored roots of anxiety in high-pressure situations. Introduced box breathing as a somatic interrupter.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionItem({required String date, required String topic, required String notes}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(date, style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText(context), fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 12),
        Text(topic, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text(context))),
        const SizedBox(height: 8),
        Text(notes, style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText(context), height: 1.5)),
      ],
    );
  }

  Widget _buildMoodTrendChart() {
    final isDark = AppColors.isDark(context);
    return GlassCard(
      glow: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MOOD TREND',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedText(context),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'This Week',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.purpleLight, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= _daysOfWeek.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _daysOfWeek[index],
                            style: GoogleFonts.inter(color: AppColors.mutedText(context), fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 4),
                      FlSpot(1, 5),
                      FlSpot(2, 6.5),
                      FlSpot(3, 8),
                      FlSpot(4, 7),
                      FlSpot(5, 9),
                      FlSpot(6, 8.5),
                    ],
                    isCurved: true,
                    color: AppColors.purpleLight,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: isDark ? Colors.white : Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppColors.purple,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.purple.withOpacity(isDark ? 0.4 : 0.2),
                          AppColors.purple.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().shimmer(duration: 2000.ms, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildAiSummaryCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.teal, size: 18),
              const SizedBox(width: 8),
              Text(
                'AI WEEKLY SUMMARY',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Sarah's mood has improved by 12% compared to last week. The primary driver of stress remains 'Work', but coping mechanisms (Box Breathing) used on Wednesday and Thursday correlated with a rapid return to baseline.",
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: AppColors.text(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, int pct, Color color) {
    final isDark = AppColors.isDark(context);
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.text(context), fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : AppColors.borderLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutQuart,
                  width: (pct / 100) * 200, // Approximate max width
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '$pct%',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
