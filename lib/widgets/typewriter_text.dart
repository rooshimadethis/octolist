import 'package:flutter/material.dart';

/// A widget that displays text with a typewriter animation effect.
/// Characters appear one by one, optionally with a blinking cursor.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration? cursorBlinkDuration;
  final bool showCursor;
  final int maxLines;
  final TextOverflow? overflow;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 2000),
    this.cursorBlinkDuration,
    this.showCursor = false,
    this.maxLines = 1,
    this.overflow,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with TickerProviderStateMixin {
  late AnimationController _typeController;
  late AnimationController? _cursorController;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();

    // Typewriter animation controller
    _typeController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _characterCount = StepTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(parent: _typeController, curve: Curves.easeInOut),
    );

    // Cursor blink animation controller (optional)
    if (widget.showCursor) {
      _cursorController = AnimationController(
        duration:
            widget.cursorBlinkDuration ?? const Duration(milliseconds: 530),
        vsync: this,
      )..repeat(reverse: true);
    }

    // Start the typewriter animation
    _typeController.forward();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _cursorController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart animation if text changes
    if (oldWidget.text != widget.text) {
      _typeController.reset();
      _characterCount = StepTween(begin: 0, end: widget.text.length).animate(
        CurvedAnimation(parent: _typeController, curve: Curves.easeInOut),
      );
      _typeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _typeController,
      builder: (context, child) {
        final displayedText = widget.text.substring(0, _characterCount.value);

        if (!widget.showCursor) {
          return Text(
            displayedText,
            style: widget.style,
            maxLines: widget.maxLines,
            overflow: widget.overflow,
          );
        }

        // Show blinking cursor continuously when enabled
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayedText,
              style: widget.style,
              maxLines: widget.maxLines,
              overflow: widget.overflow,
            ),
            FadeTransition(
              opacity: _cursorController!,
              child: Text('|', style: widget.style),
            ),
          ],
        );
      },
    );
  }
}
