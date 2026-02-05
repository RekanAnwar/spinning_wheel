import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class WheelSegment {
  final String label;
  final Color color;
  final int value;
  final String? path;
  final ui.Image? image;

  const WheelSegment({
    required this.label,
    required this.color,
    required this.value,
    this.path,
    this.image,
  });
}
