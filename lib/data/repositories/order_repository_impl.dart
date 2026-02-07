import '../../core/config/cache_config.dart';
import '../../core/services/cache_service.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/firestore_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirestoreDataSource _firestoreDataSource;

  OrderRepositoryImpl({required FirestoreDataSource firestoreDataSource})
    : _firestoreDataSource = firestoreDataSource;

  @override
  Future<List<Order>> getOrders() async {
    // Try to get from cache first
    if (CacheConfig.enableCache) {
      final cachedOrders = CacheService.getCachedList<Order>(
        CacheConfig.ordersCacheKey,
        CacheConfig.ordersTTL,
        (json) => OrderModel.fromJson(json),
      );

      if (cachedOrders != null) {
        print('✅ Loaded ${cachedOrders.length} orders from cache');
        return cachedOrders;
      }
    }

    // Cache miss or expired - fetch from Firestore
    print('📡 Fetching orders from Firestore...');
    final orders = await _firestoreDataSource.getOrders();

    // Update cache
    if (CacheConfig.enableCache) {
      await CacheService.setList<Order>(
        CacheConfig.ordersCacheKey,
        orders,
        (order) => (order as OrderModel).toJson(),
      );
      print('💾 Cached ${orders.length} orders');
    }

    return orders;
  }

  @override
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    // Try to get all orders from cache first and filter locally
    if (CacheConfig.enableCache) {
      final cachedOrders = CacheService.getCachedList<Order>(
        CacheConfig.ordersCacheKey,
        CacheConfig.ordersTTL,
        (json) => OrderModel.fromJson(json),
      );

      if (cachedOrders != null) {
        // Filter cached orders by status
        final filteredOrders =
            cachedOrders.where((order) => order.status == status).toList();
        print(
          '✅ Loaded ${filteredOrders.length} ${status.toString().split('.').last} orders from cache',
        );

        // Try to fetch fresh data in background but return cached immediately
        _fetchOrdersInBackground();

        return filteredOrders;
      }
    }

    // Cache miss - fetch from Firestore
    try {
      print(
        '📡 Fetching ${status.toString().split('.').last} orders from Firestore...',
      );
      final orders = await _firestoreDataSource.getOrdersByStatus(status);

      // Also fetch and cache all orders for future offline use
      _fetchAndCacheAllOrders();

      return orders;
    } catch (e) {
      print('❌ Error fetching orders: $e');
      // If offline, return empty list (cache was already checked)
      return [];
    }
  }

  // Helper method to fetch all orders in background
  void _fetchOrdersInBackground() async {
    try {
      final orders = await _firestoreDataSource.getOrders();
      if (CacheConfig.enableCache) {
        await CacheService.setList<Order>(
          CacheConfig.ordersCacheKey,
          orders,
          (order) => (order as OrderModel).toJson(),
        );
        print(
          '🔄 Background: Updated orders cache with ${orders.length} orders',
        );
      }
    } catch (e) {
      // Silently fail - we're already showing cached data
      print('🔄 Background sync failed (likely offline): $e');
    }
  }

  // Helper method to fetch and cache all orders
  void _fetchAndCacheAllOrders() async {
    try {
      final orders = await _firestoreDataSource.getOrders();
      if (CacheConfig.enableCache) {
        await CacheService.setList<Order>(
          CacheConfig.ordersCacheKey,
          orders,
          (order) => (order as OrderModel).toJson(),
        );
        print('💾 Cached all ${orders.length} orders for offline use');
      }
    } catch (e) {
      print('⚠️ Could not cache all orders: $e');
    }
  }

  @override
  Future<Order?> getOrder(String id) async {
    return await _firestoreDataSource.getOrder(id);
  }

  @override
  Future<Order> createOrder({
    required String vendorId,
    required String vendorName,
    required String vendorPhone,
    required List<OrderClient> clients,
    required double charge,
    required DateTime orderDate,
  }) async {
    final order = await _firestoreDataSource.createOrder(
      vendorId: vendorId,
      vendorName: vendorName,
      vendorPhone: vendorPhone,
      clients: clients,
      charge: charge,
      orderDate: orderDate,
    );

    // Invalidate cache after creating
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.ordersCacheKey);
      print('🗑️ Cleared orders cache after creation');
    }

    return order;
  }

  @override
  Future<Order> updateOrder(
    String id, {
    String? vendorName,
    String? vendorPhone,
    List<OrderClient>? clients,
    double? charge,
    OrderStatus? status,
    DateTime? orderDate,
  }) async {
    final order = await _firestoreDataSource.updateOrder(
      id,
      vendorName: vendorName,
      vendorPhone: vendorPhone,
      clients: clients,
      charge: charge,
      status: status,
      orderDate: orderDate,
    );

    // Invalidate cache after updating
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.ordersCacheKey);
      print('🗑️ Cleared orders cache after update');
    }

    return order;
  }

  @override
  Future<Order> updateClientReceived(
    String orderId,
    String clientId,
    bool isReceived,
  ) async {
    final order = await _firestoreDataSource.updateClientReceived(
      orderId,
      clientId,
      isReceived,
    );

    // Invalidate cache after updating
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.ordersCacheKey);
      print('🗑️ Cleared orders cache after client received update');
    }

    return order;
  }

  @override
  Future<Order> uploadImagesForClient(
    String orderId,
    String clientId,
    List<String> imageUrls,
  ) async {
    final order = await _firestoreDataSource.uploadImagesForClient(
      orderId,
      clientId,
      imageUrls,
    );

    // Invalidate cache after updating
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.ordersCacheKey);
      print('🗑️ Cleared orders cache after image upload');
    }

    return order;
  }

  @override
  Future<void> deleteOrderImages(String orderId) async {
    await _firestoreDataSource.deleteOrderImages(orderId);

    // Invalidate cache after deleting images
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.ordersCacheKey);
      print('🗑️ Cleared orders cache after image deletion');
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _firestoreDataSource.deleteOrder(id);

    // Invalidate cache after deleting
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.ordersCacheKey);
      print('🗑️ Cleared orders cache after deletion');
    }
  }

  @override
  Future<void> deleteCompletedOrders() async {
    await _firestoreDataSource.deleteCompletedOrders();

    // Invalidate cache after bulk delete
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.ordersCacheKey);
      print('🗑️ Cleared orders cache after completed orders deletion');
    }
  }
}
