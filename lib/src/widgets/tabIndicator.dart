import 'dart:ui';

import 'package:flutter/material.dart';

class BottomRoundedIndicator extends Decoration {
  final Color color;
  final double radius;

  BottomRoundedIndicator({required this.color, this.radius = 12});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _BottomRoundedPainter(color, radius);
  }
}

class _BottomRoundedPainter extends BoxPainter {
  final Color color;
  final double radius;

  _BottomRoundedPainter(this.color, this.radius);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()..color = color;
    final rect = offset & configuration.size!;

    // Draw path with bottom rounded corners
    final path = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(rect.left, rect.top, rect.width, 3),
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        ),
      );

    canvas.drawPath(path, paint);
  }
}
