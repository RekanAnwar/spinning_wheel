import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinning_wheel/widgets/border_painter.dart';
import 'package:spinning_wheel/widgets/wheel_painter.dart';

import '../models/wheel_segment.dart';

// Custom painter for the triangle indicator

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
                )
              else
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
                          padding: EdgeInsets.all(size * 0.062),
                          child: CustomPaint(
                            size: Size(size, size),
                            painter: WheelPainter(
                              segments,
                              imageHeight: imageHeight ?? (size * 0.11),
                              imageWidth: imageWidth ?? (size * 0.11),
                              style: labelStyle,
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
              // Center button
              Container(
                width: size * 0.25,
                height: size * 0.25,
                margin: EdgeInsets.only(bottom: size * 0.05),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/center_indicator.png',
                  package: 'spinning_wheel',
                  fit: BoxFit.contain,
                ),
              ),
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
