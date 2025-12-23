import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/expressive_theme.dart';

/// A manga-style section title with optional "See All" button
/// Used to label content sections on the home page
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const SectionTitle({super.key, required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
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
              color: ExpressiveTheme.primaryBlack,
              border: Border.all(
                color: ExpressiveTheme.primaryBlack,
                width: ExpressiveTheme.borderWidthThin,
              ),
            ),
            child: Text(
              title.toUpperCase(),
              style: ExpressiveTheme.titleLarge(
                color: ExpressiveTheme.surfaceWhite,
              ),
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
                  color: ExpressiveTheme.primaryBlack,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
