import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Optimized image loading configuration
class ImageCacheConfig {
  /// Maximum cache duration (7 days)
  static const Duration maxCacheDuration = Duration(days: 7);

  /// Maximum cache size (100 MB)
  static const int maxCacheSize = 100 * 1024 * 1024;

  /// Maximum number of cached objects
  static const int maxCacheObjects = 1000;

  /// Configure global image cache settings
  static void configure() {
    // Configure CachedNetworkImage global settings
    CachedNetworkImage.logLevel = CacheManagerLogLevel.warning;
  }
}

/// Optimized cached network image widget
class OptimizedCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Color? placeholderColor;

  const OptimizedCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            color: placeholderColor ?? Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 48,
            ),
          ),
      maxHeightDiskCache: height != null ? (height! * 2).toInt() : 1000,
      maxWidthDiskCache: width != null ? (width! * 2).toInt() : 1000,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}

/// Optimized avatar with cached image
class OptimizedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const OptimizedAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return OptimizedCachedImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(size / 2),
        placeholderColor: backgroundColor ?? _getColorFromName(name),
        errorWidget: _buildFallback(context),
      );
    }

    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? _getColorFromName(name),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }

  Color _getColorFromName(String name) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.orange,
      Colors.deepOrange,
    ];

    final index = name.codeUnits.fold(0, (sum, unit) => sum + unit) % colors.length;
    return colors[index];
  }
}

/// Preload images for better performance
class ImagePreloader {
  static Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    final futures = imageUrls.map((url) {
      return CachedNetworkImageProvider(url).resolve(
        const ImageConfiguration(),
      );
    }).toList();

    await Future.wait(futures.map((stream) {
      final completer = Completer<void>();
      stream.addListener(
        ImageStreamListener(
          (info, syncCall) => completer.complete(),
          onError: (error, stackTrace) => completer.completeError(error),
        ),
      );
      return completer.future;
    }));
  }

  /// Clear all cached images
  static Future<void> clearCache() async {
    await CachedNetworkImage.evictFromCache('');
  }

  /// Clear specific image from cache
  static Future<void> clearImageCache(String imageUrl) async {
    await CachedNetworkImage.evictFromCache(imageUrl);
  }
}
