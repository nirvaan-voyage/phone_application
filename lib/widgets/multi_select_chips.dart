import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class MultiSelectChips extends StatefulWidget {
  const MultiSelectChips({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.onToggle,
    required this.onToggleSurprise,
    required this.surpriseSelected,
    this.enabled = true,
  });

  final String label;
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<String> onToggle;
  final VoidCallback onToggleSurprise;
  final bool surpriseSelected;
  final bool enabled;

  @override
  State<MultiSelectChips> createState() => _MultiSelectChipsState();
}

class _MultiSelectChipsState extends State<MultiSelectChips> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.surpriseSelected
        ? '✨ Surprise Me'
        : widget.selectedItems.isEmpty
            ? 'None'
            : '${widget.selectedItems.length} selected';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ───────────────────────────────────────────────────
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

        // ── Toggle header row ────────────────────────────────────────
        GestureDetector(
          onTap: widget.enabled
              ? () => setState(() => _isExpanded = !_isExpanded)
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.inputFill
                  : AppColors.border.withValues(alpha: 0.3),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft:
                    Radius.circular(_isExpanded ? 0 : 12),
                bottomRight:
                    Radius.circular(_isExpanded ? 0 : 12),
              ),
              border: Border.all(
                color: _isExpanded
                    ? AppColors.primary
                    : AppColors.border,
                width: _isExpanded ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.enabled
                        ? selectedCount
                        : 'Select a state first',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: widget.enabled
                          ? (widget.selectedItems.isEmpty &&
                                  !widget.surpriseSelected
                              ? AppColors.hint
                              : AppColors.textDark)
                          : AppColors.hint,
                    ),
                  ),
                ),
                if (widget.enabled)
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.hint,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Expandable city list ──────────────────────────────────────
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: _CityList(
            items: widget.items,
            selectedItems: widget.selectedItems,
            surpriseSelected: widget.surpriseSelected,
            onToggle: widget.onToggle,
            onToggleSurprise: widget.onToggleSurprise,
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),

        // ── Selected chips preview (when collapsed) ──────────────────
        if (!_isExpanded &&
            widget.enabled &&
            (widget.selectedItems.isNotEmpty ||
                widget.surpriseSelected)) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (widget.surpriseSelected)
                _SelectedChip(
                  label: '✨ Surprise Me ✨',
                  onRemove: widget.onToggleSurprise,
                )
              else
                ...widget.selectedItems.map(
                  (city) => _SelectedChip(
                    label: city,
                    onRemove: () => widget.onToggle(city),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── City list panel ──────────────────────────────────────────────────────────
class _CityList extends StatefulWidget {
  const _CityList({
    required this.items,
    required this.selectedItems,
    required this.surpriseSelected,
    required this.onToggle,
    required this.onToggleSurprise,
  });

  final List<String> items;
  final List<String> selectedItems;
  final bool surpriseSelected;
  final ValueChanged<String> onToggle;
  final VoidCallback onToggleSurprise;

  @override
  State<_CityList> createState() => _CityListState();
}

class _CityListState extends State<_CityList> {
  final TextEditingController _searchController =
      TextEditingController();
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void didUpdateWidget(_CityList old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items) {
      _filtered = widget.items;
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 1.5),
          right: BorderSide(color: AppColors.primary, width: 1.5),
          bottom: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search city...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.hint),
                prefixIcon: const Icon(Icons.search,
                    size: 18, color: AppColors.hint),
                isDense: true,
                filled: true,
                fillColor: AppColors.inputFill,
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
              onChanged: (q) {
                setState(() {
                  _filtered = q.isEmpty
                      ? widget.items
                      : widget.items
                          .where((c) => c
                              .toLowerCase()
                              .contains(q.toLowerCase()))
                          .toList();
                });
              },
            ),
          ),

          // Scrollable city list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                // Surprise Me option always at top
                _CityTile(
                  label: '✨ Surprise Me ✨',
                  isSelected: widget.surpriseSelected,
                  isSurprise: true,
                  onTap: widget.onToggleSurprise,
                ),

                const Divider(
                    height: 1,
                    color: AppColors.border,
                    indent: 16,
                    endIndent: 16),

                if (_filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No cities found',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: AppColors.textLight),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ..._filtered.map((city) => _CityTile(
                        label: city,
                        isSelected:
                            widget.selectedItems.contains(city),
                        onTap: widget.surpriseSelected
                            ? null
                            : () => widget.onToggle(city),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single city row ──────────────────────────────────────────────────────────
class _CityTile extends StatelessWidget {
  const _CityTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSurprise = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isSurprise;

  @override
  Widget build(BuildContext context) {
    final color =
        isSurprise ? AppColors.accent : AppColors.primary;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        color: isSelected
            ? color.withValues(alpha: 0.08)
            : Colors.transparent,
        child: Row(
          children: [
            // Checkbox style indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: isSelected
                  ? const Icon(Icons.check,
                      size: 13, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: isSelected
                      ? color
                      : (onTap == null
                          ? AppColors.hint
                          : AppColors.textDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Selected chip (shown when collapsed) ─────────────────────────────────────
class _SelectedChip extends StatelessWidget {
  const _SelectedChip(
      {required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close,
                size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}