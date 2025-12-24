import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// A custom rating slider that displays a 10-point scale with a popup showing
/// the current value and haptic feedback when the value changes.
class RatingSlider extends StatefulWidget {
  final double initialValue;
  final Color primaryColor;
  final Color? activeColor;
  final Color backgroundColor;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  const RatingSlider({
    super.key,
    required this.initialValue,
    required this.primaryColor,
    this.activeColor,
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
      HapticFeedback.lightImpact();
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
          height: 40, // More compact height
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
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
                        trackHeight: 12, // Match episode progress bar
                        trackShape: _FullWidthTrackShape(),
                        thumbShape: _CustomSquareThumbShape(
                          thumbSize: 30, // Larger thumb for better presence
                          primaryColor: widget.primaryColor,
                          backgroundColor: widget.backgroundColor,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 0,
                        ),
                        tickMarkShape: SliderTickMarkShape.noTickMark,
                        activeTrackColor:
                            widget.activeColor ?? widget.primaryColor,
                        inactiveTrackColor:
                            (widget.activeColor ?? widget.primaryColor)
                                .withValues(alpha: 0.2),
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
                      bottom: 32, // Adjusted for larger thumb
                      left: (_currentValue / 10) * constraints.maxWidth,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, 0),
                        child: _PopupIndicator(
                          value: displayValue,
                          primaryColor: widget.primaryColor,
                          backgroundColor: widget.backgroundColor,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Custom square thumb shape with border
class _CustomSquareThumbShape extends SliderComponentShape {
  final double thumbSize;
  final Color primaryColor;
  final Color backgroundColor;

  const _CustomSquareThumbShape({
    required this.thumbSize,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.square(thumbSize);
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

    // Draw 3D box shadow (solid offset, no blur)
    final shadowRect = Rect.fromCenter(
      center: center + const Offset(4, 4),
      width: thumbSize,
      height: thumbSize,
    );
    final shadowPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(shadowRect, shadowPaint);

    // Draw white background square
    final bgRect = Rect.fromCenter(
      center: center,
      width: thumbSize,
      height: thumbSize,
    );
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(bgRect, bgPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; // Match episode progress bar border
    canvas.drawRect(bgRect, borderPaint);

    // Draw inner square (ensure it's perfectly centered using rounded center)
    final roundedCenter = Offset(
      center.dx.roundToDouble(),
      center.dy.roundToDouble(),
    );
    final innerRect = Rect.fromCenter(
      center: roundedCenter,
      width: thumbSize - 12, // Maintain proportional inner square
      height: thumbSize - 12,
    );
    final innerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(innerRect, innerPaint);
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
            color: primaryColor.withValues(alpha: 0.3),
            offset: const Offset(4, 4),
            blurRadius: 0,
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

class _FullWidthTrackShape extends RectangularSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Canvas canvas = context.canvas;

    // 1. Draw Background (Scaffold Background look)
    final Paint bgPaint = Paint()
      ..color = Colors
          .transparent // The container below already has scaffoldBg
      ..style = PaintingStyle.fill;
    canvas.drawRect(trackRect, bgPaint);

    // 2. Draw Active Fill (from left to thumb)
    final Paint activePaint = Paint()
      ..color = sliderTheme.activeTrackColor!
      ..style = PaintingStyle.fill;

    final Rect activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );
    canvas.drawRect(activeRect, activePaint);

    // 3. Draw Border (Outline) - Match episode progress bar (width: 2)
    final Paint borderPaint = Paint()
      ..color =
          sliderTheme.thumbColor! // Use primaryColor passed via thumbColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(trackRect, borderPaint);
  }
}
