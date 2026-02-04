import 'dart:math';

import 'package:flutter/material.dart';

// Custom painter for the decorative border
class BorderPainter extends CustomPainter {
  final double size;

  BorderPainter(this.size);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;

    // Outer blue border
    final outerBorderPaint = Paint()
      ..color = const Color(0xFF398CC2) // Blue color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.012;

    canvas.drawCircle(center, radius - size * 0.005, outerBorderPaint);

    // Blue ring
    final blueRingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF247EBA),
          Color(0xFF3B9BC6),
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.06;

    canvas.drawCircle(center, radius - size * 0.035, blueRingPaint);

    // Draw decorative dots on the blue ring
    const numDots = 8; // Number of dots around the circle
    final dotRadius = size * 0.012; // Smaller dot size
    final dotsCircleRadius = radius - size * 0.035; // Match blue ring position

    // Shadow for dots
    final dotShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.005);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const RadialGradient(
        radius: 0.5,
        center: Alignment.center,
        stops: [0.7, 1],
        colors: [
          Color(0xFFFFCEA7),
          Color(0xFFFFB00A),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    for (int i = 0; i < numDots; i++) {
      final angle = (2 * pi / numDots) * i + (pi / numDots);
      final dotX = center.dx + cos(angle) * dotsCircleRadius;
      final dotY = center.dy + sin(angle) * dotsCircleRadius;

      // Draw shadow first
      canvas.drawCircle(
        Offset(dotX + size * 0.002, dotY + size * 0.002),
        dotRadius,
        dotShadowPaint,
      );

      // Draw dot on top
      canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
    }

    // Draw triangular markers on the blue ring
    // Number of triangular markers
    const numMarkers = 8;
    // Base of the triangle, increased for wider base
    final markerBaseSize = size * 0.06;
    // Height of the triangle, increased for more prominent tip
    final markerHeight = size * 0.035;
    // Match blue ring position
    final markersCircleRadius = radius - size * 0.06;

    final markerPaint = Paint()
      ..color = const Color(0xFF81D4FA) // Light blue from the image
      ..style = PaintingStyle.fill;

    for (int i = 0; i < numMarkers; i++) {
      // Position markers at regular intervals
      final angle = (2 * pi / numMarkers) * i;

      // Calculate points for outward-pointing triangle
      final tipX =
          center.dx + (markersCircleRadius + markerHeight) * cos(angle);
      final tipY =
          center.dy + (markersCircleRadius + markerHeight) * sin(angle);

      final baseAngle1 = angle - (markerBaseSize / (2 * markersCircleRadius));
      final baseAngle2 = angle + (markerBaseSize / (2 * markersCircleRadius));

      final base1X = center.dx + markersCircleRadius * cos(baseAngle1);
      final base1Y = center.dy + markersCircleRadius * sin(baseAngle1);

      final base2X = center.dx + markersCircleRadius * cos(baseAngle2);
      final base2Y = center.dy + markersCircleRadius * sin(baseAngle2);

      final path = Path()
        ..moveTo(tipX, tipY) // Tip pointing outward
        ..lineTo(base1X, base1Y) // Base point 1
        ..lineTo(base2X, base2Y) // Base point 2
        ..close();
      canvas.drawPath(path, markerPaint);
    }

    // Inner blue border
    final innerBorderPaint = Paint()
      ..color = const Color(0xFF81D4FA) // Blue color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.02;

    final innerBorderPaint2 = Paint()
      ..color = const Color(0xFFB1EFFF) // Blue color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.005;

    // Shadow for inner border
    final innerBorderShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.069
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.04);

    canvas.save();
    canvas.clipPath(
      Path()
        ..addOval(
          Rect.fromCircle(
            center: center,
            radius: radius - size * 0.062,
          ),
        ),
    );
    canvas.drawCircle(center, radius - size * 0.062, innerBorderShadowPaint);
    canvas.restore();

    // Draw the actual inner border
    canvas.drawCircle(center, radius - size * 0.07, innerBorderPaint);
    canvas.drawCircle(center, radius - size * 0.075, innerBorderPaint2);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => oldDelegate.size != size;
}
