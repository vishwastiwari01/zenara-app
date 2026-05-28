import 'package:flutter/material.dart';

class AppColors {
  // ─── Core Backgrounds (Light Theme matching design assets) ─────────
  static const Color bg = Color(0xFFF8FAFC);           // Off-white/slate-50
  static const Color bgCard = Color(0xFFFFFFFF);        // Pure white cards
  static const Color bgGlass = Color(0xCCFFFFFF);       // Semi-transparent white
  static const Color bgElevated = Color(0xFFF1F5F9);    // Elevated/hover elements (slate-100)

  // ─── Brand Colors from Spec ────────────────────────────────────────
  static const Color purple = Color(0xFF6C5CE7);        // Primary brand purple
  static const Color purpleLight = Color(0xFF8B5CF6);   // Lighter purple accent
  static const Color purpleDark = Color(0xFF4B40A0);    // Dark purple

  // ─── Accent Colors from Spec ───────────────────────────────────────
  static const Color teal = Color(0xFF22D3EE);          // Cyan
  static const Color tealLight = Color(0xFF67E8F9);     // Light cyan
  static const Color coral = Color(0xFFF472B6);         // Pink
  static const Color pink = Color(0xFFF472B6);          // Pink
  static const Color peach = Color(0xFFFBBF24);         // Yellow/Orange
  static const Color gold = Color(0xFFFBBF24);          // Yellow/Orange

  // ─── Text & UI Colors ───────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);   // Dark slate for main text
  static const Color white = Color(0xFFFFFFFF);         // Pure white (for text on dark bg)
  static const Color muted = Color(0xFF64748B);         // Muted secondary text (slate-500)

  // ─── Borders ────────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);        // Light slate border (slate-200)
  static const Color borderSubtle = Color(0xFFF1F5F9);  // Subtle border (slate-100)
}
