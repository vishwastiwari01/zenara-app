import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class AnimatedMoodChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedMoodChip({
    Key? key,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(isDark ? 0.15 : 0.1)
              : (isDark ? AppColors.bgCard.withOpacity(0.3) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.5)
                : (isDark ? Colors.white.withOpacity(0.05) : AppColors.borderLight),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(isDark ? 0.2 : 0.12), blurRadius: 12)]
              : (isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))]),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? color : AppColors.mutedText(context),
          ),
        ),
      ).animate(target: isSelected ? 1 : 0)
       .scaleXY(end: 1.05, duration: 200.ms, curve: Curves.easeOut)
       .shimmer(duration: 1000.ms, color: Colors.white24, curve: Curves.easeInOut),
    );
  }
}
