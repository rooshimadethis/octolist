import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/expressive_theme.dart';
import 'pressable_card.dart';

/// A standardized button widget that adheres to the Expressive/Manga design system.
///
/// Features:
/// - Hard borders and shadows
/// - Press animations (scale/translate)
/// - Haptic feedback
/// - Customizable colors and dimensions
/// - Support for Icon-only or Label-only or both
class ExpressiveButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? child;
  final IconData? icon;
  final String? label;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double borderWidth;
  final Offset shadowOffset;
  final EdgeInsetsGeometry? padding;
  final bool isDisabled;
  final double size; // For square icon buttons
  final bool isSquare; // Force square aspect ratio

  const ExpressiveButton({
    super.key,
    required this.onTap,
    this.child,
    this.icon,
    this.label,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.shadowOffset = const Offset(2, 2),
    this.borderWidth = 2.0,
    this.padding,
    this.isDisabled = false,
    this.size = 32.0,
    this.isSquare = false,
  });

  const ExpressiveButton.icon({
    super.key,
    required this.onTap,
    required this.icon,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.shadowOffset = const Offset(2, 2),
    this.borderWidth = 2.0,
    this.isDisabled = false,
    this.size = 32.0,
    EdgeInsetsGeometry? padding,
    bool? isSquare,
  }) : child = null,
       label = null,
       padding = padding ?? const EdgeInsets.all(6),
       isSquare = isSquare ?? true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.scaffoldBackgroundColor;
    final fg = foregroundColor ?? ExpressiveTheme.primaryBlack;
    final border = borderColor ?? fg;
    final shadow = shadowColor ?? fg;

    // Dim colors if disabled
    final finalBg = isDisabled ? bg.withValues(alpha: 0.5) : bg;
    final finalFg = isDisabled ? fg.withValues(alpha: 0.5) : fg;
    final finalBorder = isDisabled ? border.withValues(alpha: 0.5) : border;

    return PressableCard(
      onTap: isDisabled ? null : onTap,
      shadowOffset: Offset.zero, // We handle shadow in the container decoration
      builder: (context, isPressed) {
        // Physical press effect: Move down-right when pressed
        final effectiveOffset = (isPressed && !isDisabled)
            ? const Offset(2, 2)
            : const Offset(0, 0);

        // Shadow is hidden when pressed (simulating being pressed into the surface)
        final effectiveShadowOffset = (isPressed && !isDisabled)
            ? Offset.zero
            : const Offset(2, 2);

        Widget content;
        if (child != null) {
          content = child!;
        } else if (icon != null && label == null) {
          content = Icon(icon, color: finalFg, size: size * 0.6);
        } else if (label != null && icon == null) {
          content = Text(
            label!,
            style: GoogleFonts.teko(
              fontSize: size * 0.6,
              fontWeight: FontWeight.bold,
              color: finalFg,
              height: 1.0,
            ),
          );
        } else {
          // Both label and icon
          content = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: finalFg, size: size * 0.6),
                const SizedBox(width: 4),
              ],
              if (label != null)
                Text(
                  label!,
                  style: GoogleFonts.teko(
                    fontSize: size * 0.6,
                    fontWeight: FontWeight.bold,
                    color: finalFg,
                  ),
                ),
            ],
          );
        }

        return AnimatedContainer(
          duration: ExpressiveTheme.animationFastPress,
          transform: Matrix4.translationValues(
            effectiveOffset.dx,
            effectiveOffset.dy,
            0,
          ),
          decoration: BoxDecoration(
            color: finalBg,
            border: Border.all(color: finalBorder, width: borderWidth),
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: isDisabled ? Colors.transparent : shadow,
                offset: effectiveShadowOffset,
                blurRadius: 0,
              ),
            ],
          ),
          padding: padding ?? const EdgeInsets.all(8),
          width: isSquare ? size : null,
          height: isSquare ? size : null,
          alignment: Alignment.center,
          child: content,
        );
      },
    );
  }
}
