import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinning_wheel/widgets/wheel_painter.dart';

import '../models/wheel_segment.dart';

// Custom painter for the decorative border
class BorderPainter extends CustomPainter {
  final double size;

  BorderPainter(this.size);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;

    // Outer golden/yellow border
    final outerBorderPaint = Paint()
      ..color = const Color(0xFFFFC50F) // Golden color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.008;

    canvas.drawCircle(center, radius - size * 0.008, outerBorderPaint);

    // Teal/dark teal ring with gradient
    final tealRingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF1B5E5E), // Dark teal
          Color.fromARGB(255, 31, 96, 96), // Medium teal
          Color(0xFF1B5E5E), // Dark teal
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.048;

    // Position teal ring to connect with outer border (no gap)
    // Outer border inner edge is at: radius - 0.018
    // Teal ring center should be at: radius - 0.018 - (0.055 / 2)
    canvas.drawCircle(center, radius - size * 0.035, tealRingPaint);

    // Draw decorative dots on the teal ring with alternating colors
    const numDots = 24; // Number of dots around the circle
    final dotRadius = size * 0.008;
    final dotsCircleRadius = radius - size * 0.035; // Match teal ring position

    for (int i = 0; i < numDots; i++) {
      // Alternate between golden and bronze/orange dots
      final dotColor = i.isEven
          ? const Color(0xFFFFC50F) // Golden
          : const Color(0xFFFFC50F); // Bronze/Orange

      final dotPaint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill;

      final angle = (2 * pi / numDots) * i;
      final dotX = center.dx + cos(angle) * dotsCircleRadius;
      final dotY = center.dy + sin(angle) * dotsCircleRadius;
      canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
    }

    // Inner golden border
    final innerBorderPaint = Paint()
      ..color = const Color(0xFFFFC50F) // Golden color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.008;

    // Shadow for inner border (casting onto the spinner)
    final innerBorderShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.069
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.04);

    // Position inner border to connect with teal ring (no gap)
    // Teal ring inner edge is at: radius - 0.0455 - (0.055 / 2) = radius - 0.073
    // Inner border center should be at: radius - 0.073 - (0.012 / 2)

    // Draw shadow first (clipped to inside)
    // Create a clip path for the inside of the border
    // We want the shadow to appear ONLY on the spinner side (inside), not on the teal ring (outside)
    // The border is centered at `radius - size * 0.079`
    // We clip to that radius, so anything outside (larger radius) is cut off
    canvas.save();
    canvas.clipPath(
      Path()
        ..addOval(
            Rect.fromCircle(center: center, radius: radius - size * 0.062)),
    );
    canvas.drawCircle(center, radius - size * 0.062, innerBorderShadowPaint);
    canvas.restore();

    // Draw the actual border
    canvas.drawCircle(center, radius - size * 0.062, innerBorderPaint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => oldDelegate.size != size;
}

// Custom painter for the triangle indicator
class TriangleIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC50F) // Golden/yellow color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Create a downward-pointing triangle
    path.moveTo(size.width / 2, size.height); // Bottom center (tip)
    path.lineTo(0, 0); // Top left
    path.lineTo(size.width, 0); // Top right
    path.close();

    // Draw triangle
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TriangleIndicatorPainter oldDelegate) => false;
}

class WheelDisplay extends StatelessWidget {
  final AnimationController controller;
  final List<WheelSegment> segments;
  final double startRotation;
  final double endRotation;
  final Widget? centerChild;
  final Widget? indicator;
  final Color? wheelColor;
  final Color? indicatorColor;
  final double? imageHeight;
  final double? imageWidth;
  final TextStyle? labelStyle;
  final double minSize;
  final double maxSize;
  final double aspectRatio;
  final Curve curve;
  final AnimationController? zoomController;

  const WheelDisplay({
    super.key,
    required this.controller,
    required this.segments,
    required this.startRotation,
    required this.endRotation,
    this.centerChild,
    this.indicator,
    this.wheelColor,
    this.indicatorColor,
    this.imageHeight,
    this.imageWidth,
    this.labelStyle,
    this.minSize = 100.0,
    this.maxSize = double.infinity,
    this.aspectRatio = 1.0,
    this.curve = Curves.easeOutCirc,
    this.zoomController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive size with constraints
        double availableWidth = constraints.maxWidth;
        double availableHeight = constraints.maxHeight;

        // Respect aspect ratio while fitting within constraints
        double targetSize = min(availableWidth, availableHeight / aspectRatio);
        targetSize = targetSize.clamp(minSize, maxSize);

        // Ensure the widget fits within the available space
        double finalWidth = min(targetSize, availableWidth);
        double finalHeight = min(targetSize * aspectRatio, availableHeight);
        double size = min(finalWidth, finalHeight);

        return SizedBox(
          width: size,
          height: size,
          child: _buildWheel(size),
        );
      },
    );
  }

  Widget _buildWheel(double size) {
    final wheelStack = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          bottom: -10,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Rotating wheel content (Now at bottom)
              if (segments.isEmpty)
                SizedBox(
                  width: size,
                  height: size,
                  child: Image.asset(
                    'assets/backround.png',
                    package: 'spinning_wheel',
                    fit: BoxFit.contain,
                  ),
                ),
              SizedBox(
                width: size,
                height: size,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: Tween(begin: startRotation, end: endRotation)
                          .animate(
                            CurvedAnimation(
                              parent: controller,
                              curve: curve,
                            ),
                          )
                          .value,
                      child: Padding(
                        // Reduced padding to close the gap with the inner border
                        // Inner border inner edge is at radius - 0.085 * size
                        // So we set padding to matches that edge
                        padding: EdgeInsets.all(size * 0.062),
                        child: CustomPaint(
                          size: Size(size, size),
                          painter: WheelPainter(
                            segments,
                            imageHeight: imageHeight ?? (size * 0.11),
                            imageWidth: imageWidth ?? (size * 0.11),
                            style: _getResponsiveLabelStyle(size),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Decorative border layer (Now on top to cast shadow on spinner)
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: BorderPainter(size),
                ),
              ),
              // Indicator
              _buildIndicator(size),
              // Center button
              _buildCenterButton(size),
            ],
          ),
        ),
      ],
    );

    // If zoomController is provided, apply zoom animation
    if (zoomController != null) {
      return AnimatedBuilder(
        animation: zoomController!,
        builder: (context, child) {
          return Transform.scale(
            scale: Tween<double>(begin: 1.0, end: 2.0)
                .animate(
                  CurvedAnimation(
                    parent: zoomController!,
                    curve: Curves.easeInOutCubic,
                  ),
                )
                .value,
            alignment: Alignment.topCenter,
            child: child,
          );
        },
        child: wheelStack,
      );
    }

    return wheelStack;
  }

  Widget _buildIndicator(double size) {
    // Position below inner border
    // Inner border is at: radius - 0.079, with stroke width 0.012
    // Inner edge of inner border: radius - 0.079 - 0.006 = radius - 0.085
    // Center of wheel is at size/2, so top edge is at size/2 - (radius - 0.085)
    // Which simplifies to: size/2 - size/2 + 0.085 = 0.085
    return Positioned(
      top: size * 0.062,
      child: indicator ??
          CustomPaint(
            size: Size(size * 0.05, size * 0.05),
            painter: TriangleIndicatorPainter(),
          ),
    );
  }

  Widget _buildCenterButton(double size) {
    return Container(
      width: size * 0.12,
      height: size * 0.12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.3),
          radius: 0.8,
          colors: [
            Color(0xFFFFF4C2), // Light golden (highlight)
            Color(0xFFFFD700), // Gold
            Color(0xFFE6B800), // Darker gold
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: size * 0.015,
            spreadRadius: size * 0.002,
            offset: Offset(0, size * 0.005),
          ),
        ],
      ),
      child: centerChild,
    );
  }

  TextStyle? _getResponsiveLabelStyle(double size) {
    if (labelStyle != null) return labelStyle;

    // Provide a default responsive text style
    return TextStyle(
      fontSize: size * 0.025, // Responsive font size
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }
}
