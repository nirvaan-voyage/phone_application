import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class QuestionOptionCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const QuestionOptionCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          key: ValueKey("selected"),
                        )
                      : const Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.grey,
                          key: ValueKey("unselected"),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
