import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette – blue tones from the Nirvaan logo
  static const Color primary        = Color(0xFF3D6B9E);
  static const Color primaryLight   = Color(0xFF5B8FC5);
  static const Color primaryDark    = Color(0xFF254D78);

  // Accent / gold for the Journey italic
  static const Color accent = Color(0xFF8FB8D9);

  // Neutrals
  static const Color white          = Color(0xFFFFFFFF);
  static const Color background     = Color(0xFFF7F9FC);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color inputFill      = Color(0xFFF0F4F8);
  static const Color border         = Color(0xFFDDE3EC);
  static const Color hint           = Color(0xFF9AAABB);
  static const Color textDark       = Color(0xFF1A2533);
  static const Color textMid        = Color(0xFF4A607A);
  static const Color textLight      = Color(0xFF7A93AD);

  // Overlay gradient stops (used on Home screen)
  static const Color overlayStart   = Color(0x00000000);
  static const Color overlayEnd     = Color(0xCC000000);
}
