import 'dart:async';

/// Simple in-memory cache with TTL (Time To Live)
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final Map<String, _CacheEntry> _cache = {};

  /// Get cached data if it exists and hasn't expired
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// Set cache data with optional TTL (default: 5 minutes)
  void set<T>(String key, T data, {Duration? ttl}) {
    _cache[key] = _CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(ttl ?? const Duration(minutes: 5)),
    );
  }

  /// Check if cache has non-expired data
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Remove specific cache entry
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
  }

  /// Clear expired entries
  void clearExpired() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// Get cache size
  int get size => _cache.length;
}

class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  _CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Mixin to add caching capabilities to providers
mixin CacheMixin {
  final _cache = CacheManager();

  /// Get or fetch data with caching
  Future<T> getCached<T>({
    required String key,
    required Future<T> Function() fetcher,
    Duration? ttl,
  }) async {
    // Try to get from cache
    final cached = _cache.get<T>(key);
    if (cached != null) {
      return cached;
    }

    // Fetch fresh data
    final data = await fetcher();

    // Cache it
    _cache.set(key, data, ttl: ttl);

    return data;
  }

  /// Invalidate cache for a key
  void invalidateCache(String key) {
    _cache.remove(key);
  }

  /// Invalidate all cache
  void invalidateAllCache() {
    _cache.clear();
  }
}
