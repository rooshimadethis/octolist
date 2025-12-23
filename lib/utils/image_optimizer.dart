import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageOptimizer {
  /// Compresses a file and returns the compressed file.
  ///
  /// [file] is the original image file.
  /// [minWidth] and [minHeight] are the minimum dimensions to resize to.
  /// [quality] is the compression quality (0-100).
  ///
  /// Returns a new [XFile] pointing to the compressed image in the temporary directory.
  static Future<XFile?> compressFile(
    File file, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 85,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final String targetPath = p.join(
      tempDir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    try {
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        // Rotate the image based on EXIF data
        rotate: 0,
      );

      return result;
    } catch (e) {
      // Handle error or return null
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Compresses a byte list and returns the compressed bytes.
  static Future<List<int>> compressBytes(
    List<int> list, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 85,
  }) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        (list is Uint8List) ? list : Uint8List.fromList(list),
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
      );
      return result;
    } catch (e) {
      debugPrint('Error compressing bytes: $e');
      return [];
    }
  }
}
