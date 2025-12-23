import 'package:flutter/material.dart';

/// Utility functions for parsing and handling anime colors
class ColorParser {
  ColorParser._();

  /// Parses a hex color string from AniList API (format: "#RRGGBB")
  /// Returns the parsed color or a default fallback color if parsing fails
  static Color parseAnimeColor(
    String? colorHex, {
    Color fallback = Colors.black,
  }) {
    if (colorHex == null || colorHex.isEmpty) {
      return fallback;
    }

    try {
      // Remove '#' and add '0xFF' prefix for Flutter Color
      final hexColor = colorHex.replaceAll('#', '0xFF');
      return Color(int.parse(hexColor));
    } catch (e) {
      // Return fallback color if parsing fails
      return fallback;
    }
  }
}
