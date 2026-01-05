import 'dart:math';

import 'package:flutter/material.dart';

import '../controller/spin_controller.dart';
import '../core/animation_handler.dart';
import '../core/image_loader.dart';
import '../core/spin_calculations.dart';
import '../models/wheel_segment.dart';
import '../widgets/wheel_display.dart';

class SpinnerWheel extends StatefulWidget {
  final SpinnerController controller;
  final List<WheelSegment> segments;
  final Function(WheelSegment, int) onComplete;
  final Color? wheelColor;
  final Color? indicatorColor;
  final Widget? centerChild;
  final Widget? indicator;
  final double? imageHeight;
  final double? imageWidth;
  final TextStyle? labelStyle;
  final bool showStand;
  final AnimationController? zoomController;

  const SpinnerWheel({
    super.key,
    required this.controller,
    required this.segments,
    required this.onComplete,
    this.wheelColor,
    this.indicatorColor,
    this.centerChild,
    this.indicator,
    this.imageHeight,
    this.imageWidth,
    this.labelStyle,
    this.showStand = true,
    this.zoomController,
  });

  @override
  State<SpinnerWheel> createState() => SpinnerWheelState();
}

class SpinnerWheelState extends State<SpinnerWheel>
    with SingleTickerProviderStateMixin {
  List<WheelSegment> processedSegments = [];
  late AnimationController _controller;
  double _startRotation = 0.0, _endRotation = 0.0;
  Curve _currentCurve = Curves.easeOutCirc;

  @override
  void initState() {
    widget.controller.attachState(this);
    processSegments();
    _controller = createSpinController(this, () {
      setState(() {
        _startRotation = _endRotation % (2 * pi);
        int wheelIndex = determineSegment(widget.segments, _endRotation);
        widget.onComplete(widget.segments[wheelIndex], wheelIndex);
      });
    }, () {
      setState(() {});
    });
    super.initState();
  }

  void processSegments() async {
    processedSegments = await loadSegmentImages(widget.segments);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> startSpin() async {
    _controller.stop();
    _currentCurve = Curves.easeOutCirc;
    _controller.duration = const Duration(seconds: 5);
    _controller.reset();
    final result = spinWheel(_startRotation);
    _endRotation = result.end;
    _controller.forward();
  }

  void startLoadingSpin() {
    _controller.stop();
    _currentCurve = Curves.linear;
    _controller.duration = const Duration(seconds: 1);
    // Continuous rotation
    _startRotation = 0;
    _endRotation = 2 * pi;
    _controller.repeat();
  }

  Future<void> spinToIndex(int index) async {
    // If we were in a loading spin (repeat), stop it first
    if (_controller.isAnimating) {
      _controller.stop();
      // Calculate where we are right now
      _startRotation = (_startRotation +
              (_endRotation - _startRotation) * _controller.value) %
          (2 * pi);
    }

    _currentCurve = Curves.easeOutCirc;
    _controller.reset();

    // Calculate total rotation needed
    // Reduce spins to 2 to keep duration reasonable while matching velocity
    final result = calculateSpinToResult(
        _startRotation, index, widget.segments.length,
        spins: 2);
    _endRotation = result.end;

    // Calculate dynamic duration to ensure smooth velocity transition
    // Loading speed is 1 revolution per second (2*pi rad/s)
    // We use a Quad Ease Out curve: f(t) = 1 - (1-t)^2
    // Velocity v(t) = 2(1-t)
    // Initial velocity v(0) = 2 (in normalized time units)
    // Real initial velocity V0 = (D/T) * 2
    // We want V0 = 2*pi (loading speed)
    // 2*pi = (D/T) * 2  =>  pi = D/T  =>  T = D/pi
    // This is equivalent to T = 2 * D / (2*pi)

    final totalRotateAmount = _endRotation - _startRotation;
    final initialVelocity = 2 * pi; // Matches loading speed (1 rev/sec)

    // Duration = 2 * Distance / InitialVelocity
    final durationSeconds = (2 * totalRotateAmount) / initialVelocity;

    _controller.duration =
        Duration(milliseconds: (durationSeconds * 1000).toInt());

    // Use custom curve that guarantees slope=2 at start
    _currentCurve = const _CustomEaseOutQuad();

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the size of the wheel based on constraints
        double wheelSize = min(constraints.maxWidth, constraints.maxHeight);
        if (constraints.maxHeight == double.infinity) {
          wheelSize = constraints.maxWidth;
        }

        return SizedBox(
          width: wheelSize,
          height: wheelSize,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              if (widget.showStand)
                Positioned(
                  // Position proportionally to wheel size
                  // Adjust this ratio to fine-tune the vertical position
                  bottom: -wheelSize * 0.23,
                  child: Image.asset(
                    'assets/stand.png',
                    package: 'spinning_wheel',
                    // Width proportional to wheel size (80% of wheel width)
                    width: wheelSize * 0.8,
                  ),
                ),
              WheelDisplay(
                controller: _controller,
                segments: processedSegments,
                startRotation: _startRotation,
                endRotation: _endRotation,
                centerChild: widget.centerChild,
                indicator: widget.indicator,
                wheelColor: widget.wheelColor,
                indicatorColor: widget.indicatorColor,
                imageHeight: widget.imageHeight,
                imageWidth: widget.imageWidth,
                labelStyle: widget.labelStyle,
                curve: _currentCurve,
                zoomController: widget.zoomController,
                // Ensure WheelDisplay fits our calculated size
                minSize: wheelSize,
                maxSize: wheelSize,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom Easing Curve with slope=2 at start (Linear Deceleration)
// f(t) = 1 - (1-t)^2
class _CustomEaseOutQuad extends Curve {
  const _CustomEaseOutQuad();

  @override
  double transform(double t) {
    return 1.0 - (1.0 - t) * (1.0 - t);
  }
}
