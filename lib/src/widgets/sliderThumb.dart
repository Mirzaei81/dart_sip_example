import 'package:flutter/material.dart';

class RRectSliderThumbShape extends SliderComponentShape {
  const RRectSliderThumbShape({
    this.enabledThumbRadius = 10.0,
    required this.disabledThumbRadius,
  });

  final double enabledThumbRadius;

  final double disabledThumbRadius;
  double get _disabledThumbRadius => disabledThumbRadius;
  static Paint paintThumb = Paint()
    ..style = PaintingStyle.stroke
    ..colorFilter =
        ColorFilter.mode(Color.fromARGB(255, 27, 114, 254), BlendMode.srcIn)
    ..strokeWidth = 2;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
        isEnabled == true ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

    final Canvas canvas = context.canvas;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: 8, height: 8),
            Radius.circular(1)),
        paintThumb);
  }
}
