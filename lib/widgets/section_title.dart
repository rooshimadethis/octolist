import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/expressive_theme.dart';

/// A manga-style section title with optional "See All" button
/// Used to label content sections on the home page
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final double vibeScore;

  const SectionTitle({
    super.key,
    required this.title,
    this.onPressed,
    this.vibeScore = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final primaryText = ExpressiveTheme.getPrimaryText(vibeScore);
    final inverseText = Theme.of(context).scaffoldBackgroundColor;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ExpressiveTheme.spacingXL,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ExpressiveTheme.spacingM,
              vertical: ExpressiveTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: primaryText,
              border: Border.all(
                color: primaryText,
                width: ExpressiveTheme.borderWidthThin,
              ),
            ),
            child: Text(
              title.toUpperCase(),
              style: ExpressiveTheme.titleLarge(color: inverseText),
            ),
          ),
          if (onPressed != null)
            TextButton(
              onPressed: onPressed,
              child: Text(
                'See All >',
                style: GoogleFonts.teko(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: primaryText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
