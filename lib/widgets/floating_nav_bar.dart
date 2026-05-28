import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class FloatingNavBar extends StatelessWidget {
  final String activeScreenId;
  final Function(String) onNavigate;
  final List<Map<String, dynamic>> tabs;

  const FloatingNavBar({
    Key? key,
    required this.activeScreenId,
    required this.onNavigate,
    required this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xCC111827) : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: AppColors.purple.withOpacity(0.06),
              blurRadius: 40,
              spreadRadius: 0,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isDark ? 20 : 10, sigmaY: isDark ? 20 : 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: tabs.map((tab) {
                final isActive = activeScreenId == tab['id'];
                final activeColor = isDark ? Colors.white : AppColors.purple;
                final inactiveColor = AppColors.mutedText(context);
                final icon = isActive ? tab['activeIcon'] as IconData : tab['icon'] as IconData;

                return GestureDetector(
                  onTap: () => onNavigate(tab['id'] as String),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: isActive ? 16 : 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isDark ? AppColors.purple.withOpacity(0.3) : AppColors.purple.withOpacity(0.1))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isActive
                          ? [BoxShadow(color: AppColors.purple.withOpacity(isDark ? 0.25 : 0.1), blurRadius: 12)]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: isActive ? activeColor : inactiveColor, size: 22),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Text(
                            tab['label'] as String,
                            style: GoogleFonts.inter(
                              color: activeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.2, end: 0, duration: 200.ms),
                        ]
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
