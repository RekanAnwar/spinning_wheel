import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../models/wheel_segment.dart';

// Create a singleton CacheManager with custom configuration
class CustomCacheManager {
  static const key = 'customCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );
}

// Helper to wrap ImageProvider loading into a Future<ui.Image>
Future<ui.Image> loadImage(String path, {int? width, int? height}) {
  ImageProvider provider;
  if (path.startsWith('http://') || path.startsWith('https://')) {
    provider = CachedNetworkImageProvider(
      path,
      cacheManager: CustomCacheManager.instance,
    );
  } else {
    provider = AssetImage(path);
  }

  if (width != null || height != null) {
    provider = ResizeImage(provider, width: width, height: height);
  }

  final Completer<ui.Image> completer = Completer<ui.Image>();

  try {
    final ImageStream stream = provider.resolve(const ImageConfiguration());

    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        completer.completeError(exception);
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);
  } catch (e) {
    completer.completeError(e);
  }

  return completer.future;
}

Future<List<WheelSegment>> loadSegmentImages(List<WheelSegment> segments,
    {double? width, double? height}) async {
  // Convert dimensions to integers for ResizeImage
  // If only one dimension is provided, ResizeImage handles aspect ratio automatically
  final int? cacheWidth = width?.toInt();
  final int? cacheHeight = height?.toInt();

  // Use Future.wait to load all images in parallel
  final List<WheelSegment> processedSegments = await Future.wait(
    segments.map((segment) async {
      if ((segment.path ?? '').isNotEmpty) {
        try {
          final image = await loadImage(segment.path!,
              width: cacheWidth, height: cacheHeight);
          return WheelSegment(
            label: segment.label,
            color: segment.color,
            value: segment.value,
            path: segment.path,
            image: image,
          );
        } catch (e) {
          // If image loading fails, return the original segment without image
          log('Error loading image for segment ${segment.label}: $e');
          return segment;
        }
      } else {
        return segment;
      }
    }),
  );

  return processedSegments;
}
