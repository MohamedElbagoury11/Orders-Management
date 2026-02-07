import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../config/cache_config.dart';

/// Generic cache service for managing in-memory and persistent caching
class CacheService {
  static Box? _cacheBox;
  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, int> _cacheTimestamps = {};

  /// Initialize Hive and open cache box
  static Future<void> init() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox('app_cache');
  }

  /// Close the cache box
  static Future<void> close() async {
    await _cacheBox?.close();
  }

  /// Clear all caches
  static Future<void> clearAll() async {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    await _cacheBox?.clear();
  }

  /// Clear specific cache by key
  static Future<void> clearCache(String key) async {
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
    await _cacheBox?.delete(key);
    await _cacheBox?.delete('${key}_timestamp');
  }

  /// Check if cache is valid based on TTL
  static bool isCacheValid(String key, int ttl) {
    if (!CacheConfig.enableCache) return false;

    final timestamp =
        _cacheTimestamps[key] ?? _cacheBox?.get('${key}_timestamp') as int?;

    if (timestamp == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final age = now - timestamp;

    return age < ttl;
  }

  /// Get data from cache (memory first, then persistent)
  static T? get<T>(String key, T Function(dynamic) fromJson) {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key] as T;
    }

    // Check persistent cache
    final cachedData = _cacheBox?.get(key);
    if (cachedData != null) {
      try {
        final data = fromJson(cachedData);
        // Update memory cache
        _memoryCache[key] = data;
        return data;
      } catch (e) {
        print('Error deserializing cache for $key: $e');
        return null;
      }
    }

    return null;
  }

  /// Get list data from cache
  static List<T>? getList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key] as List<T>;
    }

    // Check persistent cache
    final cachedData = _cacheBox?.get(key);
    if (cachedData != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        final List<T> data =
            jsonList
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList();

        // Update memory cache
        _memoryCache[key] = data;
        return data;
      } catch (e) {
        print('Error deserializing list cache for $key: $e');
        return null;
      }
    }

    return null;
  }

  /// Save data to cache (both memory and persistent)
  static Future<void> set<T>(
    String key,
    T data,
    dynamic Function(T) toJson,
  ) async {
    // Save to memory cache
    _memoryCache[key] = data;

    // Save timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _cacheTimestamps[key] = timestamp;

    // Save to persistent cache
    try {
      final jsonData = toJson(data);
      await _cacheBox?.put(key, jsonData);
      await _cacheBox?.put('${key}_timestamp', timestamp);
    } catch (e) {
      print('Error saving cache for $key: $e');
    }
  }

  /// Save list data to cache
  static Future<void> setList<T>(
    String key,
    List<T> data,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    // Save to memory cache
    _memoryCache[key] = data;

    // Save timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _cacheTimestamps[key] = timestamp;

    // Save to persistent cache
    try {
      final jsonList = data.map((item) => toJson(item)).toList();
      final jsonString = jsonEncode(jsonList);
      await _cacheBox?.put(key, jsonString);
      await _cacheBox?.put('${key}_timestamp', timestamp);
    } catch (e) {
      print('Error saving list cache for $key: $e');
    }
  }

  /// Get cached data with TTL check
  static T? getCached<T>(String key, int ttl, T Function(dynamic) fromJson) {
    if (!isCacheValid(key, ttl)) {
      return null;
    }
    return get<T>(key, fromJson);
  }

  /// Get cached list with TTL check
  static List<T>? getCachedList<T>(
    String key,
    int ttl,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (!isCacheValid(key, ttl)) {
      return null;
    }
    return getList<T>(key, fromJson);
  }

  /// Get cache age in milliseconds
  static int? getCacheAge(String key) {
    final timestamp =
        _cacheTimestamps[key] ?? _cacheBox?.get('${key}_timestamp') as int?;

    if (timestamp == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp;
  }

  /// Check if cache exists
  static bool hasCache(String key) {
    return _memoryCache.containsKey(key) || _cacheBox?.containsKey(key) == true;
  }
}
