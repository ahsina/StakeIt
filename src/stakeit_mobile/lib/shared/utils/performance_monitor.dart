import 'package:flutter/foundation.dart';
import 'dart:async';

/// Performance monitoring utility for tracking app performance
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, _PerformanceMetric> _metrics = {};

  /// Start tracking a performance metric
  void startTracking(String key) {
    _metrics[key] = _PerformanceMetric(
      key: key,
      startTime: DateTime.now(),
    );
  }

  /// Stop tracking and log the metric
  void stopTracking(String key, {Map<String, dynamic>? metadata}) {
    final metric = _metrics[key];
    if (metric == null) {
      debugPrint('⚠️ Performance: Metric "$key" was never started');
      return;
    }

    final duration = DateTime.now().difference(metric.startTime);
    metric.duration = duration;
    metric.metadata = metadata;

    _logMetric(metric);
    _metrics.remove(key);
  }

  /// Track a future execution time
  Future<T> trackFuture<T>(
    String key,
    Future<T> Function() future, {
    Map<String, dynamic>? metadata,
  }) async {
    startTracking(key);
    try {
      final result = await future();
      stopTracking(key, metadata: metadata);
      return result;
    } catch (e) {
      stopTracking(key, metadata: {...?metadata, 'error': e.toString()});
      rethrow;
    }
  }

  /// Track a synchronous function execution time
  T track<T>(
    String key,
    T Function() function, {
    Map<String, dynamic>? metadata,
  }) {
    startTracking(key);
    try {
      final result = function();
      stopTracking(key, metadata: metadata);
      return result;
    } catch (e) {
      stopTracking(key, metadata: {...?metadata, 'error': e.toString()});
      rethrow;
    }
  }

  void _logMetric(_PerformanceMetric metric) {
    final durationMs = metric.duration?.inMilliseconds ?? 0;
    final icon = _getPerformanceIcon(durationMs);

    if (kDebugMode) {
      final metadataStr = metric.metadata != null
          ? ' | ${metric.metadata}'
          : '';

      debugPrint(
        '$icon Performance: ${metric.key} took ${durationMs}ms$metadataStr',
      );
    }

    // In production, you would send this to analytics
    // Analytics.logPerformance(metric.key, durationMs, metric.metadata);
  }

  String _getPerformanceIcon(int milliseconds) {
    if (milliseconds < 100) return '✅'; // Excellent
    if (milliseconds < 300) return '⚡'; // Good
    if (milliseconds < 1000) return '⚠️'; // Acceptable
    return '🐌'; // Slow
  }

  /// Get all current tracking metrics (for debugging)
  Map<String, _PerformanceMetric> getCurrentMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// Clear all metrics
  void clear() {
    _metrics.clear();
  }
}

class _PerformanceMetric {
  final String key;
  final DateTime startTime;
  Duration? duration;
  Map<String, dynamic>? metadata;

  _PerformanceMetric({
    required this.key,
    required this.startTime,
    this.duration,
    this.metadata,
  });
}

/// Mixin to add performance tracking to widgets
mixin PerformanceTrackingMixin {
  final _monitor = PerformanceMonitor();

  Future<T> trackPerformance<T>(
    String key,
    Future<T> Function() future, {
    Map<String, dynamic>? metadata,
  }) {
    return _monitor.trackFuture(key, future, metadata: metadata);
  }

  T trackSync<T>(
    String key,
    T Function() function, {
    Map<String, dynamic>? metadata,
  }) {
    return _monitor.track(key, function, metadata: metadata);
  }
}

/// Widget to track build performance
class PerformanceTracker extends StatelessWidget {
  final String name;
  final Widget child;

  const PerformanceTracker({
    super.key,
    required this.name,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      return _PerformanceTrackerWidget(name: name, child: child);
    }
    return child;
  }
}

class _PerformanceTrackerWidget extends StatefulWidget {
  final String name;
  final Widget child;

  const _PerformanceTrackerWidget({
    required this.name,
    required this.child,
  });

  @override
  State<_PerformanceTrackerWidget> createState() =>
      _PerformanceTrackerWidgetState();
}

class _PerformanceTrackerWidgetState extends State<_PerformanceTrackerWidget> {
  final _monitor = PerformanceMonitor();

  @override
  void initState() {
    super.initState();
    _monitor.startTracking('build_${widget.name}');
  }

  @override
  void dispose() {
    _monitor.stopTracking('build_${widget.name}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
