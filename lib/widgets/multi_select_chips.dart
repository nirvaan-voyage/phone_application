import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

/// A horizontally-wrapping set of tappable chips for multi-selection.
/// Used for city selection in the travel form.
class MultiSelectChips extends StatelessWidget {
  const MultiSelectChips({
    super.key,
    List<String>? options,
    List<String>? items,
    List<String>? selected,
    List<String>? selectedItems,
    required this.onToggle,
    this.label,
    this.surpriseSelected = false,
    this.onToggleSurprise,
    this.enabled = true,
  })  : options = options ?? items ?? const [],
        selected = selected ?? selectedItems ?? const [];

  final String? label;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final bool surpriseSelected;
  final VoidCallback? onToggleSurprise;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty && onToggleSurprise == null) return const SizedBox.shrink();

    final chipOptions = [
      if (onToggleSurprise != null) 'Surprise Me',
      ...options,
    ];

    final chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chipOptions.map((option) {
        final isSurprise = option == 'Surprise Me';
        final isSelected = selected.contains(option);
        final active = isSurprise ? surpriseSelected : isSelected;
        final canTap = enabled && (!surpriseSelected || isSurprise);

        return GestureDetector(
          onTap: canTap
              ? () {
                  if (isSurprise) {
                    onToggleSurprise?.call();
                  } else {
                    onToggle(option);
                  }
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary
                  : AppColors.inputFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              option,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppColors.white : AppColors.textDark,
              ),
            ),
          ),
        );
      }).toList(),
    );

    if (label == null) return chips;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        chips,
      ],
    );
  }
}
