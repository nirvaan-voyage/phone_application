import 'package:flutter/material.dart';

/// Central color palette for Nirvaan.
/// Every color used anywhere in the app must be defined here.
abstract final class AppColors {
  // ── Brand blues ──────────────────────────────────────────────────────────
  /// Primary action color — buttons, active states, links.
  static const Color primary = Color(0xFF3D6B9E);

  /// Darker shade — gradients, pressed states, header banners.
  static const Color primaryDark = Color(0xFF1a3a5c);

  /// Lighter shade — error builders, onboarding slide fallback gradient.
  static const Color primaryLight = Color(0xFF8FB8D9);

  /// Accent — italic highlights in banners (e.g. "Journey" in travel form).
  static const Color accent = Color(0xFFC5D8EE);

  // ── Neutral text ─────────────────────────────────────────────────────────
  /// Main body text, headings.
  static const Color textDark = Color(0xFF1A1A2E);

  /// Secondary / caption text.
  static const Color textLight = Color(0xFF7A8DAA);

  /// Mid-weight text — used in blog filter chips etc.
  static const Color textMid = Color(0xFF4A5568);

  // ── Surfaces & inputs ────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);

  /// Input field background fill.
  static const Color inputFill = Color(0xFFF4F7FB);

  /// Border color for inputs, dividers, cards.
  static const Color border = Color(0xFFDDE3EE);

  /// Placeholder / hint text inside inputs.
  static const Color hint = Color(0xFFADB8CC);
}
