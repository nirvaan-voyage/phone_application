import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class NirvaanLogo extends StatelessWidget {
  const NirvaanLogo({
    super.key,
    this.size = 140,
    this.showTagline = true,
    this.darkBackground = false,
  });

  final double size;
  final bool showTagline;
  final bool darkBackground;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Real logo image ──────────────────────────────────────
        Image.asset(
          'assets/images/nirvaan_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),

        SizedBox(height: size * 0.08),

        if (showTagline) ...[
          Text(
            'Go.Far. Stay.Zen.',
            style: GoogleFonts.poppins(
              fontSize: size * 0.1,
              fontWeight: FontWeight.w400,
              color: darkBackground
                  ? Colors.white70
                  : AppColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}