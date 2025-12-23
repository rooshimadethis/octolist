import 'package:flutter/material.dart';
import '../theme/expressive_theme.dart';

/// A manga-style metadata chip with icon, label, and colored shadow
/// Used on anime detail pages to display metadata like season, status, genres
class MetadataChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color shadowColor;

  const MetadataChip({
    super.key,
    required this.label,
    required this.icon,
    this.shadowColor = ExpressiveTheme.primaryBlack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ExpressiveTheme.spacingM,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: ExpressiveTheme.surfaceWhite,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: ExpressiveTheme.primaryBlack,
          width: ExpressiveTheme.borderWidthThin,
        ),
        boxShadow: ExpressiveTheme.hardShadows(
          color: shadowColor,
          offset: ExpressiveTheme.shadowOffsetSmall,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ExpressiveTheme.primaryBlack),
          const SizedBox(width: ExpressiveTheme.spacingXS),
          Text(label.toUpperCase(), style: ExpressiveTheme.monoMedium()),
        ],
      ),
    );
  }
}
