import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';

enum NovaState { idle, thinking, typing, stressed, happy, sleeping }

class NovaOrb extends StatefulWidget {
  final NovaState state;
  final double size;

  const NovaOrb({
    Key? key,
    this.state = NovaState.idle,
    this.size = 180.0,
  }) : super(key: key);

  @override
  State<NovaOrb> createState() => _NovaOrbState();
}

class _NovaOrbState extends State<NovaOrb> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NovaOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      // Adjust pulse speed based on state
      switch (widget.state) {
        case NovaState.stressed:
        case NovaState.sleeping:
          _pulseController.duration = const Duration(seconds: 6);
          break;
        case NovaState.typing:
        case NovaState.thinking:
          _pulseController.duration = const Duration(seconds: 2);
          break;
        case NovaState.happy:
        case NovaState.idle:
        default:
          _pulseController.duration = const Duration(seconds: 4);
          break;
      }
      if (_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  List<Color> _getGradientColors(bool isDark) {
    switch (widget.state) {
      case NovaState.thinking:
      case NovaState.typing:
        return [
          AppColors.teal,
          AppColors.purpleLight,
          AppColors.purple,
        ];
      case NovaState.happy:
        return [
          AppColors.pink,
          AppColors.purpleLight,
          AppColors.purple,
        ];
      case NovaState.stressed:
        return [
          AppColors.coral.withOpacity(0.8),
          AppColors.purpleDark,
          isDark ? const Color(0xFF130F2A) : AppColors.mutedLight,
        ];
      case NovaState.sleeping:
        return [
          AppColors.purpleDark,
          const Color(0xFF130F2A),
          const Color(0xFF0F172A),
        ];
      case NovaState.idle:
      default:
        return [
          AppColors.tealLight,
          AppColors.purpleLight,
          AppColors.purple,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final colors = _getGradientColors(isDark);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseValue = _pulseController.value;
        final scale = 1.0 + (pulseValue * 0.05); // Subtle 5% scale breathing

        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow / Aura
              Container(
                width: widget.size * 1.5,
                height: widget.size * 1.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors[1].withOpacity(0.4),
                      colors[2].withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 0.6, 1.0],
                  ),
                ),
              ),
              
              // Animated Particles (simplified for performance)
              if (widget.state == NovaState.thinking || widget.state == NovaState.happy)
                ...List.generate(3, (index) {
                  return Positioned(
                    child: Container(
                      width: widget.size * 1.1,
                      height: widget.size * 1.1,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors[0].withOpacity(0.2 - (pulseValue * 0.1)),
                          width: 2,
                        ),
                      ),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .rotate(duration: Duration(seconds: 10 + (index * 2)))
                   .scaleXY(begin: 1.0, end: 1.1 + (index * 0.05), duration: 2.seconds);
                }),

              // Core Orb
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors[0],
                      colors[1],
                      colors[2],
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors[1].withOpacity(0.6 + (pulseValue * 0.2)),
                      blurRadius: 40 + (pulseValue * 20),
                      spreadRadius: pulseValue * 10,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: -2,
                    ), // Inner highlight illusion
                  ],
                ),
              ),
              
              // Face / Eyes (Subtle)
              if (widget.state != NovaState.sleeping)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildEye(),
                    SizedBox(width: widget.size * 0.25),
                    _buildEye(),
                  ],
                ).animate(target: widget.state == NovaState.thinking ? 1 : 0)
                 .slideY(end: -0.1, duration: 400.ms, curve: Curves.easeInOut)
            ],
          ),
        );
      },
    );
  }

  Widget _buildEye() {
    return Container(
      width: widget.size * 0.1,
      height: widget.state == NovaState.happy ? widget.size * 0.05 : widget.size * 0.12,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(widget.size * 0.1),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scaleY(begin: 1.0, end: 0.1, duration: 150.ms, delay: 4.seconds) // Blink
     .then(delay: 150.ms);
  }
}
