import 'package:flutter/material.dart';

class ChatBubble extends ShapeBorder {
  final Color color;
  final Alignment alignment;

  ChatBubble({
    required this.color,
    required this.alignment,
  });

  final BorderSide _side = BorderSide.none;
  final BorderRadiusGeometry _borderRadius = BorderRadius.zero;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(_side.width);

  @override
  Path getInnerPath(
    Rect rect, {
    TextDirection? textDirection,
  }) {
    final Path path = Path();

    path.addRRect(
      _borderRadius.resolve(textDirection).toRRect(rect).deflate(_side.width),
    );

    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double triangleH = 5;
    final double triangleW = 15.0;
    final double width = rect.width;
    final double hWidth = width * 0.5;
    final Path trianglePath = Path();
    trianglePath.addRRect(RRect.fromRectAndRadius(
        rect.shift(Offset(0, triangleH)), Radius.circular(20)));
    // Bezier Tail
    final startPoint =
        Offset(rect.right, rect.center.dy); // Right middle of RRect

    if (alignment == Alignment.topRight) {
      trianglePath
        ..moveTo(hWidth, 0)
        ..quadraticBezierTo(
            hWidth, triangleH, hWidth - triangleW * 0.5, triangleH)
        ..quadraticBezierTo(
            hWidth, triangleH, hWidth + triangleW * 0.5, triangleH)
        ..close();
    } else {
      trianglePath
        ..moveTo(hWidth, 0)
        ..quadraticBezierTo(
            hWidth, triangleH, hWidth + triangleW * 0.5, triangleH)
        ..quadraticBezierTo(
            hWidth, triangleH, hWidth - triangleW * 0.5, triangleH)
        ..close();
    }

    return trianglePath;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => RoundedRectangleBorder(
        side: _side.scale(t),
        borderRadius: _borderRadius * t,
      );
}

class InputBubble extends CustomPainter {
  final Color color;
  final Alignment alignment;
  InputBubble({
    required this.color,
    required this.alignment,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    final double triangleH = 10;
    final double triangleW = 15.0;
    final double width = size.width;
    final double height = size.height;
    final double hWidth = width * 0.5;
    final Path trianglePath;
    if (alignment == Alignment.topRight) {
      trianglePath = Path()
        ..moveTo(hWidth, 0)
        ..quadraticBezierTo(
            hWidth, triangleH, hWidth - triangleW * 0.5, triangleH)
        ..quadraticBezierTo(
            hWidth, triangleH, hWidth + triangleW * 0.5, triangleH)
        ..close();
    } else {
      trianglePath = Path()
        ..moveTo(hWidth, 0)
        ..quadraticBezierTo(
            hWidth, triangleH, hWidth + triangleW * 0.5, triangleH)
        ..quadraticBezierTo(
            hWidth, triangleH, hWidth - triangleW * 0.5, triangleH)
        ..close();
    }
    canvas.drawPath(trianglePath, paint);
    final BorderRadius borderRadius = BorderRadius.circular(15);
    final Rect rect = Rect.fromLTRB(0, triangleH, width, height - triangleH);
    final RRect outer = borderRadius.toRRect(rect);
    canvas.drawRRect(outer, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
