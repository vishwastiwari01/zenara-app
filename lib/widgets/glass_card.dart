import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool glow;

  const GlassCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.borderRadius = 24.0,
    this.onTap,
    this.glow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard.withOpacity(0.4) : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : AppColors.borderLight,
          width: 1.0,
        ),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: -5,
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          if (glow)
            BoxShadow(
              color: AppColors.purple.withOpacity(isDark ? 0.12 : 0.08),
              blurRadius: 24,
              spreadRadius: 2,
            ),
        ],
      ),
      child: isDark
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                child: child,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: child,
            ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}
