import 'package:flutter/material.dart';

/// Shared Nirvaan brand mark used in splash, login, and auth surfaces.
/// Uses the real logo assets so every screen stays visually consistent.
class NirvaanLogo extends StatelessWidget {
  const NirvaanLogo({
    super.key,
    this.size = 120,
    this.showTagline = false,
    this.variant = NirvaanLogoVariant.auto,
  });

  /// Controls the rendered logo height. Width is derived from the asset.
  final double size;

  /// Kept for compatibility with older screens that pass this value.
  /// The official asset already includes the Nirvaan wordmark.
  final bool showTagline;

  final NirvaanLogoVariant variant;

  @override
  Widget build(BuildContext context) {
    final resolvedVariant = variant == NirvaanLogoVariant.auto && size <= 92
        ? NirvaanLogoVariant.wide
        : variant == NirvaanLogoVariant.auto
            ? NirvaanLogoVariant.square
            : variant;

    final assetPath = switch (resolvedVariant) {
      NirvaanLogoVariant.compact => 'assets/images/nirvaan_logo_compact.png',
      NirvaanLogoVariant.wide => 'assets/images/nirvaan_logo_wide.jpeg',
      NirvaanLogoVariant.square => 'assets/images/nirvaan_logo_square.jpeg',
      NirvaanLogoVariant.auto => 'assets/images/nirvaan_logo_square.jpeg',
    };

    final width = switch (resolvedVariant) {
      NirvaanLogoVariant.compact => size * 2.8,
      NirvaanLogoVariant.wide => size * 2.8,
      NirvaanLogoVariant.square => size,
      NirvaanLogoVariant.auto => size,
    };

    return Semantics(
      label: 'Nirvaan',
      image: true,
      child: Image.asset(
        assetPath,
        height: size,
        width: width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

enum NirvaanLogoVariant {
  auto,
  square,
  wide,
  compact,
}
