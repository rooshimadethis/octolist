import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// A custom rating slider that displays a 10-point scale with a popup showing
/// the current value and haptic feedback when the value changes.
class RatingSlider extends StatefulWidget {
  final double initialValue;
  final Color primaryColor;
  final Color backgroundColor;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  const RatingSlider({
    super.key,
    required this.initialValue,
    required this.primaryColor,
    required this.backgroundColor,
    required this.onChanged,
    this.onChangeEnd,
  });

  @override
  State<RatingSlider> createState() => _RatingSliderState();
}

class _RatingSliderState extends State<RatingSlider> {
  late double _currentValue;
  int? _lastIntValue;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _lastIntValue = _currentValue.round();
  }

  void _handleValueChange(double value) {
    setState(() {
      _currentValue = value;
      _isDragging = true;
    });

    // Trigger haptic feedback when crossing integer boundaries
    final newIntValue = value.round();
    if (_lastIntValue != newIntValue) {
      HapticFeedback.selectionClick();
      _lastIntValue = newIntValue;
    }

    widget.onChanged(value);
  }

  void _handleChangeEnd(double value) {
    setState(() {
      _isDragging = false;
    });
    widget.onChangeEnd?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = _currentValue.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Slider with popup
        SizedBox(
          height: 60, // Extra height to accommodate popup
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // The slider itself
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 8,
                    thumbShape: _CustomThumbShape(
                      enabledThumbRadius: 14,
                      primaryColor: widget.primaryColor,
                      backgroundColor: widget.backgroundColor,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 0,
                    ),
                    activeTrackColor: widget.primaryColor,
                    inactiveTrackColor:
                        widget.primaryColor.withValues(alpha: 0.2),
                    thumbColor: widget.primaryColor,
                    valueIndicatorShape:
                        const PaddleSliderValueIndicatorShape(),
                  ),
                  child: Slider(
                    value: _currentValue,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    onChanged: _handleValueChange,
                    onChangeEnd: _handleChangeEnd,
                  ),
                ),
              ),
              // Popup value indicator
              if (_isDragging)
                Positioned(
                  bottom: 30,
                  left: _calculatePopupPosition(),
                  child: _PopupIndicator(
                    value: displayValue,
                    primaryColor: widget.primaryColor,
                    backgroundColor: widget.backgroundColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Calculate the horizontal position of the popup based on slider value
  double _calculatePopupPosition() {
    // Get the slider track width (approximate)
    final screenWidth = MediaQuery.of(context).size.width - 48; // Account for padding
    final trackWidth = screenWidth - 48; // Account for slider padding
    final thumbPosition = (_currentValue / 10) * trackWidth;

    // Center the popup above the thumb (28px is half the popup width)
    return thumbPosition + 24 - 28;
  }
}

/// Custom thumb shape with border
class _CustomThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final Color primaryColor;
  final Color backgroundColor;

  const _CustomThumbShape({
    required this.enabledThumbRadius,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(
      center + const Offset(2, 2),
      enabledThumbRadius,
      shadowPaint,
    );

    // Draw white background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, enabledThumbRadius, bgPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, enabledThumbRadius, borderPaint);

    // Draw inner circle
    final innerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, enabledThumbRadius - 5, innerPaint);
  }
}

/// Popup indicator showing the current value
class _PopupIndicator extends StatelessWidget {
  final int value;
  final Color primaryColor;
  final Color backgroundColor;

  const _PopupIndicator({
    required this.value,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor,
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        value.toString(),
        style: GoogleFonts.teko(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: backgroundColor,
          height: 1,
        ),
      ),
    );
  }
}
