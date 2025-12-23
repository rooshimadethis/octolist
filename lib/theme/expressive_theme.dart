import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized theme configuration for the Expressive Anime prototype.
/// Provides manga/comic-inspired design tokens and styles.
class ExpressiveTheme {
  ExpressiveTheme._();

  // ============================================================================
  // COLORS
  // ============================================================================

  static const Color primaryBlack = Colors.black;
  static const Color surfaceWhite = Colors.white;
  static final Color mangaRed = Colors.red[900]!;
  static final Color indicatorGrey = Colors.grey[300]!;

  // ============================================================================
  // BORDERS
  // ============================================================================

  static const double borderWidthThin = 2.0;
  static const double borderWidthMedium = 3.0;
  static const double borderWidthThick = 4.0;

  static const BorderSide thinBorder = BorderSide(
    color: primaryBlack,
    width: borderWidthThin,
  );

  static const BorderSide mediumBorder = BorderSide(
    color: primaryBlack,
    width: borderWidthMedium,
  );

  static const BorderSide thickBorder = BorderSide(
    color: primaryBlack,
    width: borderWidthThick,
  );

  // ============================================================================
  // SHADOWS
  // ============================================================================

  static const Offset shadowOffsetSmall = Offset(2, 2);
  static const Offset shadowOffsetMedium = Offset(4, 4);
  static const Offset shadowOffsetLarge = Offset(6, 6);
  static const Offset shadowOffsetXLarge = Offset(8, 8);
  static const Offset shadowOffsetXXLarge = Offset(10, 10);

  /// Creates a hard shadow (no blur) with the given color and offset
  static BoxShadow hardShadow({
    Color color = primaryBlack,
    Offset offset = shadowOffsetMedium,
  }) {
    return BoxShadow(color: color, offset: offset, blurRadius: 0);
  }

  /// Creates a list of hard shadows for BoxDecoration
  static List<BoxShadow> hardShadows({
    Color color = primaryBlack,
    Offset offset = shadowOffsetMedium,
  }) {
    return [hardShadow(color: color, offset: offset)];
  }

  // ============================================================================
  // SPACING
  // ============================================================================

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;

  // ============================================================================
  // ANIMATION
  // ============================================================================

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ============================================================================
  // CARD DIMENSIONS
  // ============================================================================

  /// Standard manga card width
  static const double cardWidth = 180.0;

  /// Standard manga card height
  static const double cardHeight = 280.0;

  /// Poster/cover width for detail pages
  static const double posterWidth = 180.0;

  /// Poster/cover height for detail pages
  static const double posterHeight = 270.0;

  /// Watching card width
  static const double watchingCardWidth = 280.0;

  /// Watching card height
  static const double watchingCardHeight = 180.0;

  /// Watching card image width
  static const double watchingCardImageWidth = 100.0;

  /// Avatar size
  static const double avatarSize = 56.0;

  /// Large avatar size (for dialogs)
  static const double avatarSizeLarge = 80.0;

  // ============================================================================
  // DECORATION HELPERS
  // ============================================================================

  /// Creates a standard manga-style container decoration with hard borders and shadow
  static BoxDecoration mangaContainer({
    Color backgroundColor = surfaceWhite,
    Color borderColor = primaryBlack,
    double borderWidth = borderWidthMedium,
    Color shadowColor = primaryBlack,
    Offset shadowOffset = shadowOffsetXLarge,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(width: borderWidth, color: borderColor),
      borderRadius: BorderRadius.zero,
      boxShadow: hardShadows(color: shadowColor, offset: shadowOffset),
    );
  }

  /// Creates a circular avatar decoration with border and shadow
  static BoxDecoration avatarDecoration({
    Color borderColor = primaryBlack,
    double borderWidth = borderWidthMedium,
    Color shadowColor = primaryBlack,
    Offset shadowOffset = shadowOffsetMedium,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: hardShadows(color: shadowColor, offset: shadowOffset),
    );
  }

  /// Creates a badge/chip decoration
  static BoxDecoration badgeDecoration({
    Color backgroundColor = primaryBlack,
    Color borderColor = surfaceWhite,
    double borderWidth = borderWidthThin,
    Offset shadowOffset = shadowOffsetSmall,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: hardShadows(offset: shadowOffset),
    );
  }

  // ============================================================================
  // TEXT STYLES
  // ============================================================================

  /// Large manga-style heading (e.g., page titles)
  static TextStyle headlineLarge({Color color = primaryBlack}) {
    return GoogleFonts.teko(
      fontSize: 42,
      fontWeight: FontWeight.bold,
      height: 0.9,
      color: color,
    );
  }

  /// Medium manga-style heading (e.g., section titles)
  static TextStyle headlineMedium({Color color = primaryBlack}) {
    return GoogleFonts.teko(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: color,
    );
  }

  /// Small manga-style heading
  static TextStyle headlineSmall({Color color = primaryBlack}) {
    return GoogleFonts.teko(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: color,
      fontStyle: FontStyle.italic,
    );
  }

  /// Title style with italic action feel
  static TextStyle titleLarge({Color color = primaryBlack}) {
    return GoogleFonts.teko(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: color,
      fontStyle: FontStyle.italic,
    );
  }

  /// Medium title style
  static TextStyle titleMedium({Color color = primaryBlack}) {
    return GoogleFonts.teko(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Card title style
  static TextStyle cardTitle({Color color = primaryBlack}) {
    return GoogleFonts.teko(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      height: 0.9,
      color: color,
    );
  }

  /// Small title style
  static TextStyle titleSmall({Color color = primaryBlack}) {
    return GoogleFonts.teko(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 2.0,
      color: color,
    );
  }

  /// Monospace style for technical text (scores, episode numbers)
  static TextStyle monoMedium({
    Color color = primaryBlack,
    double fontSize = 12,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Label style
  static TextStyle label({Color color = primaryBlack}) {
    return GoogleFonts.teko(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
      color: color,
    );
  }

  // ============================================================================
  // THEME DATA
  // ============================================================================

  /// Creates the MaterialApp ThemeData for the Expressive Anime prototype
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlack,
        primary: primaryBlack,
        secondary: mangaRed,
        surface: surfaceWhite,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.bangersTextTheme().copyWith(
        headlineMedium: headlineMedium(),
        titleLarge: titleLarge(),
        titleMedium: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          color: primaryBlack,
        ),
      ),
    );
  }
}
