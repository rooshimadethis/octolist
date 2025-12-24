import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Encapsulates all vibe-dependent colors and styling properties
class VibeColors {
  final double vibeScore;
  final Color primaryText;
  final Color scaffoldBg;
  final Color shadowColor;
  final Offset shadowOffset;
  final Curve animationCurve;
  final Duration animationDuration;
  final ColorFilter? imageFilter;
  final double grainOpacity;
  final List<Color> confettiColors;

  const VibeColors({
    required this.vibeScore,
    required this.primaryText,
    required this.scaffoldBg,
    required this.shadowColor,
    required this.shadowOffset,
    required this.animationCurve,
    required this.animationDuration,
    required this.imageFilter,
    required this.grainOpacity,
    required this.confettiColors,
  });

  // Cache for VibeColors instances
  static final Map<int, VibeColors> _cache = {};
  static final Map<String, VibeColors> _accentCache = {};

  /// Factory constructor to compute all colors from a vibe score
  factory VibeColors.fromScore(double score, [Color? accentColor]) {
    // Quantize score to reduce cache size (0.01 precision)
    final cacheKey = (score * 100).round();

    // Check cache based on whether we have an accent color
    if (accentColor == null) {
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey]!;
      }
    } else {
      final accentKey = '${cacheKey}_${accentColor.hashCode}';
      if (_accentCache.containsKey(accentKey)) {
        return _accentCache[accentKey]!;
      }
    }

    // Compute new VibeColors instance
    final vibeColors = VibeColors(
      vibeScore: score,
      primaryText: ExpressiveTheme.getPrimaryText(score),
      scaffoldBg: ExpressiveTheme.getScaffoldBg(score),
      shadowColor: ExpressiveTheme.getShadowColor(
        score,
        accentColor ?? ExpressiveTheme.primaryBlack,
      ),
      shadowOffset: ExpressiveTheme.getShadowOffset(score),
      animationCurve: ExpressiveTheme.vibeCurve(score),
      animationDuration: ExpressiveTheme.vibeDuration(score),
      imageFilter: ExpressiveTheme.getImageFilter(score),
      grainOpacity: ExpressiveTheme.getGrainOpacity(score),
      confettiColors: ExpressiveTheme.getConfettiColors(score),
    );

    // Cache the result (limit cache size to prevent memory issues)
    if (accentColor == null) {
      if (_cache.length > 100) {
        _cache.clear();
      }
      _cache[cacheKey] = vibeColors;
    } else {
      if (_accentCache.length > 100) {
        _accentCache.clear();
      }
      final accentKey = '${cacheKey}_${accentColor.hashCode}';
      _accentCache[accentKey] = vibeColors;
    }

    return vibeColors;
  }

  /// Get inverse color (for text on colored backgrounds)
  Color get inverseColor => scaffoldBg;
}

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
  static const Color bloodRed = Color(0xFF8B0000);
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

  static const Duration animationFastPress = Duration(milliseconds: 100);
  static const Duration animationFast = Duration(milliseconds: 300);
  static const Duration animationMedium = Duration(milliseconds: 400);
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

  /// Helper to get a dynamic curve based on vibe
  static Curve vibeCurve(double score) {
    return score > 0.5 ? Curves.easeInOutCubic : Curves.elasticOut;
  }

  /// Helper to get a dynamic duration based on vibe
  static Duration vibeDuration(double score) {
    return Duration(milliseconds: (400 + (600 * score)).toInt());
  }

  /// Creates the MaterialApp ThemeData for the Expressive Anime prototype
  static ThemeData themeData({double vibeScore = 0.0}) {
    // Smoothly transition background from pure white to dark with easing
    final t = Curves.easeInOutCubic.transform(vibeScore);
    final Color scaffoldBg = Color.lerp(
      surfaceWhite,
      const Color(0xFF0A0A0A),
      t,
    )!;

    // Use a very narrow text transition to maintain readability
    // Text stays pure black/white except in a small transition zone
    final double textT = vibeScore < 0.47
        ? 0.0
        : vibeScore > 0.53
            ? 1.0
            : (vibeScore - 0.47) / 0.06; // Linear interpolation in the 0.47-0.53 range

    final Color primaryText = Color.lerp(primaryBlack, surfaceWhite, textT)!;

    final Color primaryColor = Color.lerp(primaryBlack, bloodRed, vibeScore)!;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: Color.lerp(mangaRed, const Color(0xFF4A0000), vibeScore)!,
        surface: scaffoldBg,
        onSurface: primaryText,
        brightness: vibeScore > 0.5 ? Brightness.dark : Brightness.light,
      ),
      textTheme: GoogleFonts.bangersTextTheme().copyWith(
        headlineMedium: headlineMedium(
          color: primaryText,
        ).copyWith(letterSpacing: 1.2 - (0.5 * vibeScore)),
        titleLarge: titleLarge(color: primaryText),
        titleMedium: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          color: primaryText,
        ),
      ),
    );
  }

  /// Static access to dynamic tokens for manual styling

  /// Get the scaffold background color for a given vibe score
  static Color getScaffoldBg(double score) {
    // Use an easing curve to make the middle values less muddy
    // This keeps backgrounds cleaner in the 0.3-0.7 range
    final t = Curves.easeInOutCubic.transform(score);
    return Color.lerp(surfaceWhite, const Color(0xFF0A0A0A), t)!;
  }

  static Color getPrimaryText(double score) {
    // Very narrow transition window for maximum readability
    final double textT = score < 0.47
        ? 0.0
        : score > 0.53
            ? 1.0
            : (score - 0.47) / 0.06;
    return Color.lerp(primaryBlack, surfaceWhite, textT)!;
  }

  static Color getShadowColor(double score, [Color baseColor = primaryBlack]) {
    if (baseColor == primaryBlack) {
      // Use easing to avoid muddy middle colors
      final t = Curves.easeInQuad.transform(score);
      return Color.lerp(primaryBlack, bloodRed, t)!;
    }

    final hsl = HSLColor.fromColor(baseColor);

    // Vibe 0: Vibrant Pastel version (more visible)
    // Darkened slightly to replace the contrast lost from removing the black skeleton
    final pastel = hsl
        .withLightness((hsl.lightness * 0.4 + 0.2).clamp(0.2, 0.7))
        .withSaturation((hsl.saturation * 1.2).clamp(0.6, 1.0))
        .toColor();

    // Vibe 1: Darker/Serious version
    final serious = hsl
        .withLightness((hsl.lightness * 0.3).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0))
        .toColor();

    // Use easing for smoother transition
    final t = Curves.easeInOut.transform(score);
    return Color.lerp(pastel, serious, t)!;
  }

  static Offset getShadowOffset(double score) =>
      Offset.lerp(shadowOffsetXLarge, const Offset(10, 10), score)!;

  /// Returns black or white text color based on background luminance
  static Color getContrastText(Color background) {
    return background.computeLuminance() > 0.5 ? primaryBlack : surfaceWhite;
  }

  // Cache for expensive ColorFilter calculations
  static final Map<int, ColorFilter?> _imageFilterCache = {};

  /// Creates a dynamic image filter based on vibe score
  /// Returns null if the effect would be invisible (vibe near 0)
  ///
  /// The filter desaturates and darkens images as vibe increases:
  /// - 50% saturation reduction
  /// - 30% brightness reduction
  static ColorFilter? getImageFilter(double score) {
    if (score < 0.1) return null;

    // Use cached value if available (quantize to reduce cache size)
    final cacheKey = (score * 100).round();
    if (_imageFilterCache.containsKey(cacheKey)) {
      return _imageFilterCache[cacheKey];
    }

    // Interpolation factor with easing for smoother transitions
    final t = Curves.easeInOut.transform(score);

    // Target values: 50% desaturated + 70% brightness
    // These values are derived from Rec.709 grayscale coefficients
    // scaled by 0.7 for brightness reduction
    const kDesatR = 0.4244, kDesatG1 = 0.2503, kDesatB1 = 0.0253;
    const kDesatG2 = 0.6003, kDesatG3 = 0.0253;
    const kDesatB2 = 0.2503, kDesatB3 = 0.3753;
    const kDesatR2 = 0.0744;

    // Lerp from identity matrix to target desaturated matrix
    final filter = ColorFilter.matrix([
      1.0 + (kDesatR - 1.0) * t,
      kDesatG1 * t,
      kDesatB1 * t,
      0,
      0,
      kDesatR2 * t,
      1.0 + (kDesatG2 - 1.0) * t,
      kDesatG3 * t,
      0,
      0,
      kDesatR2 * t,
      kDesatB2 * t,
      1.0 + (kDesatB3 - 1.0) * t,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);

    // Cache the result (limit cache size to prevent memory issues)
    if (_imageFilterCache.length > 100) {
      _imageFilterCache.clear();
    }
    _imageFilterCache[cacheKey] = filter;

    return filter;
  }

  /// Calculates the grain overlay opacity for a given vibe score
  static double getGrainOpacity(double score) {
    return score < 0.2 ? 0.0 : (score - 0.2) * 0.5;
  }

  /// Gets the confetti colors based on vibe score.
  /// Transitions from multi-color to blood red.
  static List<Color> getConfettiColors(double score) {
    if (score >= 0.8) {
      return [bloodRed, const Color(0xFF600000), Colors.black];
    }

    final baseColors = [
      Colors.red,
      Colors.blue,
      Colors.cyan,
      Colors.green,
      Colors.deepOrangeAccent,
      Colors.yellow,
      Colors.amber,
      Colors.purple,
      Colors.orange,
    ];

    // As score goes from 0 to 0.8, replace a larger percentage of colors with bloodRed
    // Use ceil to ensure the first transition happens immediately as vibe increases
    final replaceCount = ((score / 1.2) * baseColors.length).ceil().clamp(
      0,
      baseColors.length,
    );
    final result = List<Color>.from(baseColors);

    for (int i = 0; i < replaceCount; i++) {
      // Replace from the end (orange, purple, etc.) to make the transition more noticeably "bloody"
      result[result.length - 1 - i] = bloodRed;
    }

    return result;
  }
}
