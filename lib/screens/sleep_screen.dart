import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  double _sleepHours = 7.0;
  double _sleepMinutes = 24.0;
  double _sleepQuality = 0.7; // 0.0 = very tired, 1.0 = very alert
  bool _uninterruptedSleep = true;
  bool _dreamRecall = true;
  final TextEditingController _notesController = TextEditingController();

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  final List<String> _qualityLabels = ['Very tired', 'Tired', 'Okay', 'Rested', 'Very alert'];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _loadSleepData();
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSleepData() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';
    final data = prefs.getString('zenara_sleep_$dateKey');
    if (data != null) {
      try {
        final map = json.decode(data);
        setState(() {
          _sleepHours = (map['hours'] ?? 7).toDouble();
          _sleepMinutes = (map['minutes'] ?? 0).toDouble();
          _sleepQuality = (map['quality'] ?? 0.7).toDouble();
          _uninterruptedSleep = map['uninterrupted'] ?? true;
          _dreamRecall = map['dreamRecall'] ?? false;
          _notesController.text = map['notes'] ?? '';
        });
      } catch (_) {}
    } else {
      setState(() {
        _sleepHours = 7.0;
        _sleepMinutes = 24.0;
        _sleepQuality = 0.7;
        _uninterruptedSleep = true;
        _dreamRecall = true;
        _notesController.text = '';
      });
    }
  }

  Future<void> _saveSleepData() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';
    await prefs.setString('zenara_sleep_$dateKey', json.encode({
      'hours': _sleepHours.round(),
      'minutes': _sleepMinutes.round(),
      'quality': _sleepQuality,
      'uninterrupted': _uninterruptedSleep,
      'dreamRecall': _dreamRecall,
      'notes': _notesController.text,
    }));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sleep data saved ✓', style: GoogleFonts.dmSans()),
          backgroundColor: AppColors.teal,
          duration: const Duration(seconds: 2),
        ),
      );
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
            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sleep',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Calendar Card
            _buildCalendarCard(),
            const SizedBox(height: 16),

            // Sleep Duration Circle
            _buildSleepDurationCard(),
            const SizedBox(height: 16),

            // Sleep Quality Card
            _buildSleepQualityCard(),
            const SizedBox(height: 16),

            // Dream Recall & Uninterrupted
            _buildTogglesCard(),
            const SizedBox(height: 16),

            // Notes
            _buildNotesCard(),
            const SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              onPressed: _saveSleepData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: AppColors.purple.withOpacity(0.4),
              ),
              child: Text(
                'Save Sleep Data',
                style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday; // 1=Mon, 7=Sun
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                  });
                  _loadSleepData();
                },
                child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
              ),
              Text(
                '${months[_selectedDate.month - 1]} ${_selectedDate.year}',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                  });
                  _loadSleepData();
                },
                child: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) => SizedBox(
              width: 36,
              child: Center(
                child: Text(d, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),

          // Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: ((startWeekday % 7) + daysInMonth),
            itemBuilder: (context, index) {
              final dayOffset = startWeekday % 7; // Sunday = 0
              if (index < dayOffset) return const SizedBox();

              final day = index - dayOffset + 1;
              if (day > daysInMonth) return const SizedBox();

              final isToday = day == now.day && _selectedDate.month == now.month && _selectedDate.year == now.year;
              final isSelected = day == _selectedDate.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                  });
                  _loadSleepData();
                  _progressController.reset();
                  _progressController.forward();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.purple
                        : isToday
                            ? AppColors.purple.withOpacity(0.15)
                            : Colors.transparent,
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.purple.withOpacity(0.5))
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : isToday ? AppColors.purpleLight : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSleepDurationCard() {
    final totalMinutes = (_sleepHours * 60 + _sleepMinutes).round();
    final displayHours = totalMinutes ~/ 60;
    final displayMinutes = totalMinutes % 60;
    final sleepFraction = (totalMinutes / (10 * 60)).clamp(0.0, 1.0); // 10h = full circle

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1340), Color(0xFF0D0B1E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.purple.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Sleep circle
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: SleepCirclePainter(
                    progress: sleepFraction * _progressAnimation.value,
                    color: AppColors.purpleLight,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.nightlight_round, color: AppColors.purpleLight, size: 28),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${displayHours}h ',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: '${displayMinutes}m',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.purpleLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Total Sleep',
                          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Hours slider
          Row(
            children: [
              Text('Hours', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.purpleLight,
                    inactiveTrackColor: Colors.white.withOpacity(0.06),
                    trackHeight: 4.0,
                    thumbColor: AppColors.purpleLight,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                    overlayColor: AppColors.purpleLight.withOpacity(0.12),
                  ),
                  child: Slider(
                    value: _sleepHours,
                    min: 0,
                    max: 14,
                    divisions: 14,
                    onChanged: (val) => setState(() => _sleepHours = val),
                  ),
                ),
              ),
              Text('${_sleepHours.round()}h', style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              Text('Minutes', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.teal,
                    inactiveTrackColor: Colors.white.withOpacity(0.06),
                    trackHeight: 4.0,
                    thumbColor: AppColors.teal,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                    overlayColor: AppColors.teal.withOpacity(0.12),
                  ),
                  child: Slider(
                    value: _sleepMinutes,
                    min: 0,
                    max: 59,
                    divisions: 59,
                    onChanged: (val) => setState(() => _sleepMinutes = val),
                  ),
                ),
              ),
              Text('${_sleepMinutes.round()}m', style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepQualityCard() {
    final labelIndex = (_sleepQuality * (_qualityLabels.length - 1)).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How did you feel when you woke up?',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Very tired', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.muted)),
              Text('Very alert', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.muted)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.teal,
              inactiveTrackColor: Colors.white.withOpacity(0.06),
              trackHeight: 6.0,
              thumbColor: AppColors.teal,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9.0),
              overlayColor: AppColors.teal.withOpacity(0.15),
            ),
            child: Slider(
              value: _sleepQuality,
              min: 0.0,
              max: 1.0,
              onChanged: (val) => setState(() => _sleepQuality = val),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.teal.withOpacity(0.2)),
              ),
              child: Text(
                _qualityLabels[labelIndex],
                style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.tealLight, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTogglesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildToggleRow(
            label: 'Uninterrupted sleep',
            value: _uninterruptedSleep,
            onChanged: (val) => setState(() => _uninterruptedSleep = val),
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.06)),
          const SizedBox(height: 14),
          _buildToggleRow(
            label: 'Dreams recall',
            subtitle: _dreamRecall ? 'Yes' : 'No',
            value: _dreamRecall,
            onChanged: (val) => setState(() => _dreamRecall = val),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
            if (subtitle != null)
              Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted)),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.purpleLight,
          activeTrackColor: AppColors.purple.withOpacity(0.4),
          inactiveThumbColor: AppColors.muted,
          inactiveTrackColor: Colors.white.withOpacity(0.06),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add a note...',
            style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13.5, height: 1.5),
            decoration: InputDecoration(
              hintText: 'How was your sleep? Any dreams?',
              hintStyle: GoogleFonts.dmSans(color: AppColors.muted.withOpacity(0.6)),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sleep Duration Circle Painter ───────────────────────────────────────────
class SleepCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  SleepCirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -1.5708,
        endAngle: 4.7124,
        colors: [color.withOpacity(0.3), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Start from top
      progress * 2 * 3.14159,
      false,
      progressPaint,
    );

    // Glow dot at the end
    if (progress > 0.01) {
      final angle = -1.5708 + progress * 2 * 3.14159;
      final dotCenter = Offset(
        center.dx + radius * (angle == -1.5708 ? 0 : _cos(angle)),
        center.dy + radius * (angle == -1.5708 ? -1 : _sin(angle)),
      );
      final glowPaint = Paint()..color = color.withOpacity(0.5);
      canvas.drawCircle(dotCenter, 6, glowPaint);
      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(dotCenter, 3, dotPaint);
    }
  }

  double _cos(double angle) => (angle != 0) ? (angle).abs() < 0.001 ? 1 : _realCos(angle) : 1;
  double _sin(double angle) => (angle != 0) ? (angle).abs() < 0.001 ? 0 : _realSin(angle) : 0;

  double _realCos(double x) {
    // Use dart:math
    return x.abs() < 0.001 ? 1.0 : _taylorCos(x);
  }
  double _realSin(double x) {
    return x.abs() < 0.001 ? 0.0 : _taylorSin(x);
  }

  double _taylorCos(double x) {
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }
  double _taylorSin(double x) {
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(SleepCirclePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
