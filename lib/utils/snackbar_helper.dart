import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/expressive_theme.dart';

/// Helper class for showing consistent styled SnackBars throughout the app
/// Eliminates duplication of SnackBar creation code
class SnackBarHelper {
  SnackBarHelper._();

  /// Shows a success SnackBar with consistent styling
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.green[800]!,
      duration: duration,
    );
  }

  /// Shows an error SnackBar with consistent styling
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.red[800]!,
      duration: duration,
    );
  }

  /// Shows an info SnackBar with consistent styling
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.blue[800]!,
      duration: duration,
    );
  }

  /// Internal method to show SnackBar with consistent styling
  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Duration duration,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.toUpperCase(),
          style: GoogleFonts.teko(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ExpressiveTheme.surfaceWhite,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: ExpressiveTheme.primaryBlack,
            width: ExpressiveTheme.borderWidthMedium,
          ),
        ),
        duration: duration,
      ),
    );
  }
}
