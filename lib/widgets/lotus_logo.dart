import 'package:flutter/material.dart';

class LotusLogo extends StatelessWidget {
  final double size;
  final bool glow;

  const LotusLogo({
    super.key,
    this.size = 32,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/logo.jpeg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );

    if (glow) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA89AF7).withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
