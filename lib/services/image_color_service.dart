import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// Service to extract and cache dominant colors from images (e.g. user avatars)
class ImageColorService {
  ImageColorService._();

  static final Map<String, Color> _colorCache = {};
  static final Map<String, Future<Color?>> _pendingExtracts = {};

  /// Extracts the dominant color from a network image.
  /// Uses caching to avoid redundant extractions.
  static Future<Color?> extractDominantColor(String imageUrl) async {
    if (imageUrl.isEmpty) return null;

    // Return cached color if available
    if (_colorCache.containsKey(imageUrl)) {
      return _colorCache[imageUrl];
    }

    // Return pending future if extraction is already in progress
    if (_pendingExtracts.containsKey(imageUrl)) {
      return _pendingExtracts[imageUrl];
    }

    // Start extraction
    final future = _extract(imageUrl);
    _pendingExtracts[imageUrl] = future;

    final color = await future;
    _pendingExtracts.remove(imageUrl);

    if (color != null) {
      _colorCache[imageUrl] = color;
    }

    return color;
  }

  static Future<Color?> _extract(String imageUrl) async {
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        maximumColorCount: 16, // Low count for speed
        filters: [], // No filters to get raw colors
      );

      // Try for vibrant color first, then dominant, then any
      return paletteGenerator.vibrantColor?.color ??
          paletteGenerator.dominantColor?.color ??
          paletteGenerator.colors.firstOrNull;
    } catch (e) {
      debugPrint('Error extracting color from $imageUrl: $e');
      return null;
    }
  }

  /// Synchronously get color if it's already cached
  static Color? getCachedColor(String imageUrl) {
    return _colorCache[imageUrl];
  }
}
