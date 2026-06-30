import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

/// A tappable field that opens a bottom sheet with a searchable list.
/// Used for selecting an Indian state in the travel form.
class SearchableDropdown extends StatelessWidget {
  const SearchableDropdown({
    super.key,
    required this.label,
    List<String>? options,
    List<String>? items,
    required this.onSelected,
    this.selected,
    this.selectedValue,
    this.hint = 'Search...',
    this.errorText,
    this.enabled = true,
  }) : options = options ?? items ?? const [];

  final String label;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final String? selected;
  final String? selectedValue;
  final String hint;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: enabled ? () => _openSheet(context) : null,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? Colors.red
                    : _selectedValue != null
                        ? AppColors.primary
                        : AppColors.border,
                width: errorText != null || _selectedValue != null ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedValue ?? hint,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: _selectedValue != null
                          ? FontWeight.w500
                          : FontWeight.w400,
                      color: _selectedValue != null
                          ? AppColors.textDark
                          : AppColors.hint,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _selectedValue != null
                      ? AppColors.primary
                      : AppColors.hint,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ],
    );
  }

  String? get _selectedValue => selected ?? selectedValue;

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchSheet(
        options: options,
        onSelected: (value) {
          Navigator.pop(context);
          onSelected(value);
        },
      ),
    );
  }
}

// ── Internal search sheet ─────────────────────────────────────────────────
class _SearchSheet extends StatefulWidget {
  const _SearchSheet({required this.options, required this.onSelected});

  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _controller = TextEditingController();
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.options;
    _controller.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _controller.text.toLowerCase().trim();
    setState(() {
      _filtered = query.isEmpty
          ? widget.options
          : widget.options
              .where((o) => o.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.hint),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.hint, size: 20),
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No results found',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: AppColors.textLight),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      return ListTile(
                        title: Text(
                          item,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                        onTap: () => widget.onSelected(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
