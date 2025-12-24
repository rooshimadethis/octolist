import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable wrapper widget that provides press animation and haptic feedback
/// for any card-like widget. Eliminates code duplication across the app.
///
/// Usage:
/// ```dart
/// PressableCard(
///   shadowOffset: Offset(8, 8),
///   onTap: () => Navigator.push(...),
///   child: YourCardWidget(),
/// )
/// ```
class PressableCard extends StatefulWidget {
  /// The widget to wrap with press behavior
  final Widget? child;

  /// A builder that provides the current press state.
  /// Use this if the child needs to react to being pressed (e.g. for collapsing shadows).
  final Widget Function(BuildContext context, bool isPressed)? builder;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Shadow offset to use for press animation
  /// The card will translate to this offset when pressed
  final Offset shadowOffset;

  /// Duration of the press animation
  final Duration animationDuration;

  /// Curve for the press animation
  final Curve animationCurve;

  /// Delay after tap before triggering onTap callback
  /// This allows the press animation to complete before navigation
  final Duration? tapDelay;

  const PressableCard({
    super.key,
    this.child,
    this.builder,
    this.onTap,
    this.shadowOffset = const Offset(8, 8),
    this.animationDuration = const Duration(milliseconds: 100),
    this.animationCurve = Curves.easeOutQuad,
    this.tapDelay,
  }) : assert(
         child != null || builder != null,
         'Either child or builder must be provided',
       );

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!_isPressed) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null) return;

    // Only trigger haptic if not already pressed (avoid duplicate from onTapDown)
    if (!_isPressed) {
      setState(() => _isPressed = true);
    }
    HapticFeedback.lightImpact();

    // Wait for animation to complete
    await Future.delayed(widget.tapDelay ?? widget.animationDuration);

    if (mounted && _isPressed) {
      setState(() => _isPressed = false);
    }

    // Small delay before navigation for better UX
    await Future.delayed(const Duration(milliseconds: 50));

    if (mounted) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        transform: Matrix4.translationValues(
          _isPressed ? widget.shadowOffset.dx : 0,
          _isPressed ? widget.shadowOffset.dy : 0,
          0,
        ),
        child: widget.builder != null
            ? widget.builder!(context, _isPressed)
            : widget.child,
      ),
    );
  }
}
