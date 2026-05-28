import 'package:flutter/material.dart';
import '../theme/colors.dart';

class PremiumSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color activeColor;

  const PremiumSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.activeColor = AppColors.teal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeColor,
        inactiveTrackColor: isDark ? Colors.white.withOpacity(0.05) : AppColors.borderLight,
        trackHeight: 6.0,
        thumbColor: isDark ? Colors.white : activeColor,
        overlayColor: activeColor.withOpacity(0.15),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 10.0,
          elevation: 4,
          pressedElevation: 8,
        ),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}
