import 'package:flutter/material.dart';

class AppColors {
  // ─── Core Dark Backgrounds ─────────
  static const Color bg = Color(0xFF0F172A);
  static const Color bgCard = Color(0xFF111827);
  static const Color bgGlass = Color(0x33111827);
  static const Color bgElevated = Color(0xFF1E293B);

  // ─── Core Light Backgrounds ─────────
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgCardLight = Color(0xFFFFFFFF);
  static const Color bgGlassLight = Color(0x33FFFFFF);
  static const Color bgElevatedLight = Color(0xFFF1F5F9);

  // ─── Brand Colors ────────────────────────────────────────
  static const Color purple = Color(0xFF6C5CE7);
  static const Color purpleLight = Color(0xFF8B5CF6);
  static const Color purpleDark = Color(0xFF4B40A0);

  // ─── Accent Colors ───────────────────────────────────────
  static const Color teal = Color(0xFF22D3EE);
  static const Color tealLight = Color(0xFF67E8F9);
  static const Color coral = Color(0xFFF472B6);
  static const Color pink = Color(0xFFF9A8D4);
  static const Color peach = Color(0xFFFBBF24);
  static const Color gold = Color(0xFFFBBF24);

  // ─── Text & UI Colors (Dark) ───────────────────────────
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF94A3B8);

  // ─── Text & UI Colors (Light) ──────────────────────────
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color mutedLight = Color(0xFF64748B);

  // ─── Borders ────────────────────────────────────────────
  static const Color border = Color(0xFF334155);
  static const Color borderSubtle = Color(0xFF1E293B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // ─── Helper: theme-aware getters ────────────────────────
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? bg : bgLight;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? bgCard : bgCardLight;

  static Color glass(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? bgGlass : bgGlassLight;

  static Color elevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? bgElevated : bgElevatedLight;

  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textPrimary : textPrimaryLight;

  static Color mutedText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? muted : mutedLight;

  static Color cardBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? border : borderLight;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
