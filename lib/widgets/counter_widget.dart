import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class CounterWidget extends StatelessWidget {
  const CounterWidget({
    super.key,
    required this.label,
    required this.subtitle,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
    this.min = 0,
    this.max = 20,
  });

  final String label;
  final String subtitle;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Label + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          // Counter controls
          Row(
            children: [
              _CounterButton(
                icon: Icons.remove,
                onTap: count > min ? onDecrement : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$count',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              _CounterButton(
                icon: Icons.add,
                onTap: count < max ? onIncrement : null,
                filled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: filled
              ? (isEnabled ? AppColors.primary : AppColors.border)
              : Colors.transparent,
          border: filled
              ? null
              : Border.all(
                  color: isEnabled ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled
              ? AppColors.white
              : (isEnabled ? AppColors.primary : AppColors.hint),
        ),
      ),
    );
  }
}
