import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/lotus_logo.dart';

class MicroPauseScreen extends StatefulWidget {
  const MicroPauseScreen({Key? key}) : super(key: key);

  @override
  State<MicroPauseScreen> createState() => _MicroPauseScreenState();
}

class _MicroPauseScreenState extends State<MicroPauseScreen>
    with TickerProviderStateMixin {
  bool _exerciseActive = false;
  int _breathPhase = 0; // 0=inhale, 1=hold, 2=exhale, 3=hold
  int _phaseSeconds = 0;
  int _totalCycles = 0;
  int _selectedDuration = 2; // minutes
  Timer? _breathTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final List<String> _phaseLabels = ['Inhale', 'Hold', 'Exhale', 'Hold'];
  final List<int> _phaseDurations = [4, 4, 4, 4]; // Box breathing - 4 seconds each
  final List<Color> _phaseColors = [
    AppColors.teal,
    AppColors.purpleLight,
    AppColors.pink,
    AppColors.purpleLight,
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathTimer?.cancel();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _exerciseActive = true;
      _breathPhase = 0;
      _phaseSeconds = 0;
      _totalCycles = 0;
    });
    _updatePulseForPhase(0);

    _breathTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _phaseSeconds++;
        if (_phaseSeconds >= _phaseDurations[_breathPhase]) {
          _phaseSeconds = 0;
          _breathPhase = (_breathPhase + 1) % 4;
          if (_breathPhase == 0) {
            _totalCycles++;
            if (_totalCycles >= (_selectedDuration * 60 ~/ 16)) {
              // Each cycle = 16 seconds (4+4+4+4)
              _stopExercise();
              return;
            }
          }
          _updatePulseForPhase(_breathPhase);
        }
      });
    });
  }

  void _updatePulseForPhase(int phase) {
    _pulseController.stop();
    if (phase == 0) {
      // Inhale - expand
      _pulseController.duration = Duration(seconds: _phaseDurations[0]);
      _pulseController.forward(from: 0.0);
    } else if (phase == 2) {
      // Exhale - contract
      _pulseController.duration = Duration(seconds: _phaseDurations[2]);
      _pulseController.reverse(from: 1.0);
    }
    // Hold phases - stay at current position
  }

  void _stopExercise() {
    _breathTimer?.cancel();
    _pulseController.stop();
    setState(() {
      _exerciseActive = false;
    });
  }

  String _formatRemainingTime() {
    final totalBreathSeconds = _selectedDuration * 60;
    final elapsed = _totalCycles * 16 + _breathPhase * 4 + _phaseSeconds;
    final remaining = totalBreathSeconds - elapsed;
    final mins = remaining ~/ 60;
    final secs = remaining % 60;
    return '${mins}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_exerciseActive) _stopExercise();
                    Navigator.of(context).maybePop();
                  },
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
                const Spacer(),
                Text(
                  'Micro Pause',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 36),
              ],
            ),
            const SizedBox(height: 30),

            // Illustration area
            _buildBreathingCircle(),
            const SizedBox(height: 28),

            // Info Card
            _buildInfoCard(),
            const SizedBox(height: 16),

            // Duration Selector
            if (!_exerciseActive) _buildDurationSelector(),
            if (!_exerciseActive) const SizedBox(height: 20),

            // Start / Stop Button
            ElevatedButton(
              onPressed: _exerciseActive ? _stopExercise : _startExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: _exerciseActive ? AppColors.coral : AppColors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: (_exerciseActive ? AppColors.coral : AppColors.purple).withOpacity(0.4),
              ),
              child: Text(
                _exerciseActive ? 'Stop Exercise' : 'Start Break',
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            // Snooze button
            if (!_exerciseActive)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Snoozed for 15 min', style: GoogleFonts.dmSans()),
                      backgroundColor: AppColors.purple,
                    ),
                  );
                },
                child: Text(
                  'Snooze 15 min',
                  style: GoogleFonts.dmSans(color: AppColors.muted, fontSize: 13),
                ),
              ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingCircle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        final scale = _exerciseActive ? _pulseAnimation.value : 0.8;
        final phaseColor = _exerciseActive
            ? _phaseColors[_breathPhase]
            : AppColors.purpleLight;

        return Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: phaseColor.withOpacity(_glowAnimation.value * 0.4),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        phaseColor.withOpacity(0.15),
                        phaseColor.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: phaseColor.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Inner content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_exerciseActive) ...[
                    Text(
                      _phaseLabels[_breathPhase],
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: phaseColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_phaseDurations[_breathPhase] - _phaseSeconds}',
                      style: GoogleFonts.dmSans(
                        fontSize: 42,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatRemainingTime(),
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.muted),
                    ),
                  ] else ...[
                    const LotusLogo(size: 48, glow: true),
                    const SizedBox(height: 12),
                    Text(
                      'Take a mindful\nbreak ☕',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (_exerciseActive) ...[
            Text(
              'Box Breathing',
              style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Inhale 4s → Hold 4s → Exhale 4s → Hold 4s',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _breathPhase ? _phaseColors[i] : AppColors.muted.withOpacity(0.3),
                  ),
                );
              }),
            ),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.teal, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "You've been on your device for 45 minutes.",
                    style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'How about a $_selectedDuration-minute breathing break?',
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    final durations = [2, 5, 10];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: durations.map((d) {
        final isSelected = _selectedDuration == d;
        return GestureDetector(
          onTap: () => setState(() => _selectedDuration = d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.purple : AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.purple : AppColors.border,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppColors.purple.withOpacity(0.3), blurRadius: 8)]
                  : null,
            ),
            child: Text(
              '$d min',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.muted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
