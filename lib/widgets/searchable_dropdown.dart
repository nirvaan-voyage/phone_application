import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class SearchableDropdown extends StatefulWidget {
  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onSelected,
    this.selectedValue,
    this.enabled = true,
    this.errorText,
  });

  final String label;
  final String hint;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final String? selectedValue;
  final bool enabled;
  final String? errorText;

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filtered = [];
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void dispose() {
    _closeDropdown();
    _searchController.dispose();
    super.dispose();
  }

  void _openDropdown() {
    if (!widget.enabled) return;
    _filtered = widget.items;
    _searchController.clear();
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  void _filter(String query) {
    setState(() {
      _filtered = widget.items
          .where((e) => e.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _select(String value) {
    widget.onSelected(value);
    _closeDropdown();
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (_) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: StatefulBuilder(
              builder: (_, setOverlayState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search box inside dropdown
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.hint),
                        prefixIcon: const Icon(Icons.search,
                            size: 18, color: AppColors.hint),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                      ),
                      onChanged: (v) {
                        _filter(v);
                        setOverlayState(() {});
                      },
                    ),
                  ),

                  // List
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: _filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('No results',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.textLight)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) {
                              final item = _filtered[i];
                              final isSelected =
                                  item == widget.selectedValue;
                              return InkWell(
                                onTap: () => _select(item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  color: isSelected
                                      ? AppColors.primary
                                          .withValues(alpha: 0.08)
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check,
                                            size: 16,
                                            color: AppColors.primary),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _isOpen ? _closeDropdown : _openDropdown,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: widget.enabled
                    ? AppColors.inputFill
                    : AppColors.border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.errorText != null
                      ? Colors.red
                      : _isOpen
                          ? AppColors.primary
                          : AppColors.border,
                  width: _isOpen || widget.errorText != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedValue ?? widget.hint,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: widget.selectedValue != null
                            ? AppColors.textDark
                            : AppColors.hint,
                      ),
                    ),
                  ),
                  Icon(
                    _isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.hint,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (widget.errorText != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.errorText!,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}