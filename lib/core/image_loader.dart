import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../models/wheel_segment.dart';

Future<ui.Image> loadImage(String path) async {
  ByteData data;
  if (path.startsWith('http://') || path.startsWith('https://')) {
    data = await NetworkAssetBundle(Uri.parse(path)).load("");
  } else {
    data = await rootBundle.load(path);
  }
  final Uint8List list = data.buffer.asUint8List();
  final ui.Codec codec = await ui.instantiateImageCodec(list);
  final ui.FrameInfo frame = await codec.getNextFrame();
  return frame.image;
}

Future<List<WheelSegment>> loadSegmentImages(
    List<WheelSegment> segments) async {
  List<WheelSegment> processedSegments = [];

  for (var segment in segments) {
    if ((segment.path ?? '').isNotEmpty) {
      processedSegments.add(WheelSegment(
        label: segment.label,
        color: segment.color,
        value: segment.value,
        path: segment.path,
        image: await loadImage(segment.path!),
      ));
    } else {
      processedSegments.add(segment);
    }
  }

  return processedSegments;
}
