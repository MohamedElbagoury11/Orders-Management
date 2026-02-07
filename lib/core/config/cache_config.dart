/// Cache configuration constants
class CacheConfig {
  // Cache keys
  static const String clientsCacheKey = 'cached_clients';
  static const String ordersCacheKey = 'cached_orders';
  static const String vendorsCacheKey = 'cached_vendors';

  // Timestamp keys
  static const String clientsTimestampKey = 'clients_cache_timestamp';
  static const String ordersTimestampKey = 'orders_cache_timestamp';
  static const String vendorsTimestampKey = 'vendors_cache_timestamp';

  // Cache TTL (Time To Live) in milliseconds
  // 5 minutes for frequently changing data
  static const int defaultTTL = 5 * 60 * 1000; // 5 minutes

  // 15 minutes for less frequently changing data
  static const int extendedTTL = 15 * 60 * 1000; // 15 minutes

  // 1 hour for rarely changing data
  static const int longTTL = 60 * 60 * 1000; // 1 hour

  // Specific TTLs for different data types
  static const int clientsTTL = extendedTTL;
  static const int ordersTTL = defaultTTL;
  static const int vendorsTTL = longTTL;

  // Cache size limits (number of items)
  static const int maxCacheSize = 1000;

  // Enable/disable caching
  static const bool enableCache = true;

  // Enable/disable offline mode
  static const bool enableOfflineMode = true;
}
