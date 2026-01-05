import 'dart:math';

import '../models/wheel_segment.dart';

class SpinResult {
  final double start;
  final double end;
  SpinResult(this.start, this.end);
}

SpinResult spinWheel(double startRotation) {
  final Random random = Random();
  final int spinCount = 5 + random.nextInt(5);
  final double extraSpin = random.nextDouble() * 2 * pi;
  double endRotation = startRotation + (spinCount * 2 * pi) + extraSpin;

  return SpinResult(startRotation, endRotation);
}

SpinResult calculateSpinToResult(
    double startRotation, int targetIndex, int totalSegments,
    {int spins = 5}) {
  final Random random = Random();
  final double segmentAngle = 2 * pi / totalSegments;

  // Calculate the center angle of the target segment in "inverted" space
  // (index + 0.5) puts us in the center of the segment
  double targetInvertedAngle = (targetIndex + 0.5) * segmentAngle;

  // Add some randomness within the segment (stay within 80% of segment width to be safe)
  double randomOffset = (random.nextDouble() - 0.5) * segmentAngle * 0.8;
  targetInvertedAngle += randomOffset;

  // Convert back to normal rotation space
  // normalizedAngle = 2*pi - invertedAngle
  double targetNormalizedAngle = (2 * pi - targetInvertedAngle) % (2 * pi);

  // Calculate relative rotation needed
  double currentNormalized = startRotation % (2 * pi);
  double rotationDiff = targetNormalizedAngle - currentNormalized;

  // Ensure we always rotate forward
  if (rotationDiff <= 0) {
    rotationDiff += 2 * pi;
  }

  // Add full spins
  double totalRotation = startRotation + rotationDiff + (spins * 2 * pi);

  return SpinResult(startRotation, totalRotation);
}

int determineSegment(List<WheelSegment> segments, double endRotation) {
  final double normalizedAngle = endRotation % (2 * pi);
  final double segmentAngle = 2 * pi / segments.length;
  final double invertedAngle = 2 * pi - normalizedAngle;
  final int segmentIndex = (invertedAngle ~/ segmentAngle) % segments.length;

  return segmentIndex;
}
