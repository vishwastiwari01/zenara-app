import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

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
    {'label': 'Work Stress', 'pct': 32, 'color': AppColors.purple},
    {'label': 'Self Worth', 'pct': 24, 'color': AppColors.teal},
    {'label': 'Burnout', 'pct': 18, 'color': AppColors.pink},
    {'label': 'Relationships', 'pct': 14, 'color': AppColors.peach},
    {'label': 'Other', 'pct': 12, 'color': AppColors.muted},
  ];

  final List<String> _daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<String> _sparklineDays = ['T', 'W', 'T', 'F', 'S', 'S', 'M'];
  
  // Normalized points for mood curve (y: 0.0 is top/best, 1.0 is bottom/worst in drawing coordinates)
  // Let's use drawing heights (e.g. 55, 50, 45, 38, 48, 32, 20)
  final List<double> _moodPoints = [0.7, 0.65, 0.58, 0.49, 0.55, 0.42, 0.25];

  final List<int> _activityHeights = [60, 30, 70, 50, 40, 60, 50]; // Max 70

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
            // Header
            _buildHeader(),
            const SizedBox(height: 16),

            // Tab Buttons
            _buildTabs(),
            const SizedBox(height: 16),

            // Tab Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildActiveTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.analytics_outlined, color: AppColors.purpleLight, size: 14),
            ),
            const SizedBox(width: 8),
            Text(
              'THERAPIST PORTAL',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.muted,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Sarah Johnson',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Last session: May 24, 2026 (with Dr. Hayes)',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final List<String> tabs = ['Overview', 'Mood', 'Themes', 'Sessions'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isActive = _activeTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.purple : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  tab,
                  style: GoogleFonts.dmSans(
                    fontSize: 11.5,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Colors.white : AppColors.muted,
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
        // Stats row
        Row(
          children: [
            for (int i = 0; i < _stats.length; i++) ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _stats[i]['value'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _stats[i]['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _stats[i]['label'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              if (i < _stats.length - 1) const SizedBox(width: 10),
            ]
          ],
        ),
        const SizedBox(height: 16),

        // Mood Trend Card
        _buildMoodTrendCard(),
        const SizedBox(height: 16),

        // Journal Activity Card
        _buildJournalActivityCard(),
        const SizedBox(height: 16),

        // AI Weekly Summary Card
        _buildAiSummaryCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMoodTab() {
    return Column(
      key: const ValueKey('Mood'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMoodTrendCard(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard.withOpacity(0.7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ENERGY LEVEL SPLIT',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.muted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              _buildEnergyProgressRow('Mental Energy', 68, AppColors.purpleLight),
              const SizedBox(height: 12),
              _buildEnergyProgressRow('Physical Energy', 74, AppColors.teal),
              const SizedBox(height: 12),
              _buildEnergyProgressRow('Social Energy', 52, AppColors.pink),
              const SizedBox(height: 16),
              Text(
                'Sarah\'s mental and physical energy averages are rising, but social battery remains depleted. Suggest suggesting more somatic rest exercises.',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEnergyProgressRow(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 12.5, color: Colors.white)),
            Text('$value%', style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: value / 100.0,
              color: color,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemesTab() {
    return Column(
      key: const ValueKey('Themes'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard.withOpacity(0.7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DOMINANT COGNITIVE THEMES',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.muted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 14),
              ..._themes.map((theme) {
                final color = theme['color'] as Color;
                final pct = theme['pct'] as int;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(theme['label'] as String, style: GoogleFonts.dmSans(fontSize: 12.5, color: Colors.white)),
                          Text('$pct%', style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 6,
                          child: LinearProgressIndicator(
                            value: pct / 100.0,
                            color: color,
                            backgroundColor: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSessionsTab() {
    return Column(
      key: const ValueKey('Sessions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SESSION HISTORY',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.muted,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Next: May 31, 2026',
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(height: 16),
              _buildSessionItem(
                date: 'May 24, 2026',
                topic: 'Boundary Setting & Work-Life Separation',
                notes: 'Dr. Hayes noted: Sarah is practicing asserting boundaries but feels immense guilt. Plan is to address self-worth blocks.',
              ),
              const Divider(color: Colors.white10, height: 24),
              _buildSessionItem(
                date: 'May 17, 2026',
                topic: 'Reframing Imposter Syndrome',
                notes: 'Dr. Hayes noted: Evaluated cognitive distortions regarding new manager feedback. Discovered personalization bias.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSessionItem({required String date, required String topic, required String notes}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(topic, style: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(date, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.muted)),
          ],
        ),
        const SizedBox(height: 6),
        Text(notes, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted, height: 1.4)),
      ],
    );
  }

  Widget _buildMoodTrendCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MOOD TREND',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.muted,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'Last 7 days',
                style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.muted),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Sparkline canvas representation
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: MoodTrendPainter(points: _moodPoints, days: _sparklineDays),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalActivityCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'JOURNAL ACTIVITY',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.muted,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'This week',
                style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.muted),
              )
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_activityHeights.length, (index) {
                final h = _activityHeights[index];
                final day = _daysOfWeek[index];
                final isToday = index == 6; // Sunday/Today

                return Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 14,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: h / 70.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.purple.withOpacity(isToday ? 1.0 : 0.5),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: isToday
                                    ? [
                                        BoxShadow(
                                          color: AppColors.purple.withOpacity(0.4),
                                          blurRadius: 6,
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        day,
                        style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.muted),
                      ),
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAiSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xCC1A1040), // deep space purple/indigo
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Weekly Summary',
                style: GoogleFonts.dmSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.purple),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 10, color: AppColors.purpleLight),
                    const SizedBox(width: 4),
                    Text(
                      'AI Generated',
                      style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.purpleLight),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Sarah shows improved emotional regulation this week with reduced anxiety levels and increased moments of calm. Journals indicate ongoing work stress and self-worth challenges. Continue exploring boundaries and self-compassion in upcoming sessions.',
            style: GoogleFonts.dmSans(
              fontSize: 12.5,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading full report PDF...', style: GoogleFonts.dmSans()),
                  backgroundColor: AppColors.purple,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple.withOpacity(0.15),
              elevation: 0,
              side: const BorderSide(color: AppColors.purple),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'View Full Report',
              style: GoogleFonts.dmSans(color: AppColors.purpleLight, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}

// ─── MOOD TREND SPARKLINE PAINTER ────────────────────────────────────────────
class MoodTrendPainter extends CustomPainter {
  final List<double> points;
  final List<String> days;

  MoodTrendPainter({required this.points, required this.days});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final width = size.width;
    final height = size.height - 20; // reserve space for text labels

    // Calculate x coordinates for each point
    final double stepX = width / (points.length - 1);
    final List<Offset> pathPoints = [];

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      // points[i] is y-factor (0.0 is top/best, 1.0 is bottom/worst). Let's map it:
      final y = points[i] * height;
      pathPoints.add(Offset(x, y));
    }

    // Create curved path (smooth curves)
    final path = Path();
    path.moveTo(pathPoints[0].dx, pathPoints[0].dy);

    for (int i = 0; i < pathPoints.length - 1; i++) {
      final p0 = pathPoints[i];
      final p1 = pathPoints[i + 1];
      final controlX1 = p0.dx + stepX / 2;
      final controlY1 = p0.dy;
      final controlX2 = p1.dx - stepX / 2;
      final controlY2 = p1.dy;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
    }

    // Fill path underneath with gradient
    final fillPath = Path.from(path);
    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.purple.withOpacity(0.35), AppColors.purple.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw outline
    final strokePaint = Paint()
      ..color = AppColors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // Draw a glowing dot at today's point (the last point)
    final lastPoint = pathPoints.last;
    final dotPaint = Paint()..color = Colors.white;
    final glowPaint = Paint()..color = AppColors.purpleLight.withOpacity(0.5);

    canvas.drawCircle(lastPoint, 6, glowPaint);
    canvas.drawCircle(lastPoint, 3, dotPaint);

    // Draw text labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < days.length; i++) {
      final x = i * stepX;
      textPainter.text = TextSpan(
        text: days[i],
        style: GoogleFonts.dmSans(
          color: AppColors.muted,
          fontSize: 9,
          fontWeight: FontWeight.normal,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
