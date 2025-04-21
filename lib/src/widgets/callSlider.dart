import 'package:flutter/material.dart';

class Callslider extends SliderComponentShape {
  final double size;
  final double thumbRadius;
  final IconData iconData;

  const Callslider(
      {required this.thumbRadius, required this.iconData, this.size = 64});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
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

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    final transPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withAlpha(156);
    // draw icon with text painter
    final TextPainter textPainter =
        TextPainter(textDirection: TextDirection.rtl);
    textPainter.text = TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: thumbRadius * 2,
          fontFamily: iconData.fontFamily,
          color: sliderTheme.thumbColor,
        ));
    textPainter.layout();

    final Offset textCenter = Offset(center.dx - (textPainter.width / 2),
        center.dy - (textPainter.height / 2));
    const cornerRadius = 50.0;

    // draw the background shape here..
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromCenter(center: center, width: 48, height: 48),
          cornerRadius, cornerRadius),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectXY(
          Rect.fromCenter(center: center, width: size, height: size),
          cornerRadius,
          cornerRadius),
      transPaint,
    );

    textPainter.paint(canvas, textCenter);
  }
}
