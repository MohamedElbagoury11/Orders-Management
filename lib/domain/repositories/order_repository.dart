import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<List<Order>> getOrdersByStatus(OrderStatus status);
  Future<Order?> getOrder(String id);
  Future<Order> createOrder({
    required String vendorId,
    required String vendorName,
    required String vendorPhone,
    required List<OrderClient> clients,
    required double charge,
    required DateTime orderDate,
  });
  Future<Order> updateOrder(String id, {
    String? vendorName,
    String? vendorPhone,
    List<OrderClient>? clients,
    double? charge,
    OrderStatus? status,
    DateTime? orderDate,
  });
  Future<Order> updateClientReceived(String orderId, String clientId, bool isReceived);
  Future<Order> uploadImagesForClient(String orderId, String clientId, List<String> imageUrls);
  Future<void> deleteOrderImages(String orderId);
  Future<void> deleteOrder(String id);
  Future<void> deleteCompletedOrders();
} 