import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/firestore_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirestoreDataSource _firestoreDataSource;

  OrderRepositoryImpl({required FirestoreDataSource firestoreDataSource})
      : _firestoreDataSource = firestoreDataSource;

  @override
  Future<List<Order>> getOrders() async {
    return await _firestoreDataSource.getOrders();
  }

  @override
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    return await _firestoreDataSource.getOrdersByStatus(status);
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
    return await _firestoreDataSource.createOrder(
      vendorId: vendorId,
      vendorName: vendorName,
      vendorPhone: vendorPhone,
      clients: clients,
      charge: charge,
      orderDate: orderDate,
    );
  }

  @override
  Future<Order> updateOrder(String id, {
    String? vendorName,
    String? vendorPhone,
    List<OrderClient>? clients,
    double? charge,
    OrderStatus? status,
    DateTime? orderDate,
  }) async {
    return await _firestoreDataSource.updateOrder(id,
      vendorName: vendorName,
      vendorPhone: vendorPhone,
      clients: clients,
      charge: charge,
      status: status,
      orderDate: orderDate,
    );
  }

  @override
  Future<Order> updateClientReceived(String orderId, String clientId, bool isReceived) async {
    return await _firestoreDataSource.updateClientReceived(orderId, clientId, isReceived);
  }

  @override
  Future<Order> uploadImagesForClient(String orderId, String clientId, List<String> imageUrls) async {
    return await _firestoreDataSource.uploadImagesForClient(orderId, clientId, imageUrls);
  }

  @override
  Future<void> deleteOrderImages(String orderId) async {
    return await _firestoreDataSource.deleteOrderImages(orderId);
  }

  @override
  Future<void> deleteOrder(String id) async {
    return await _firestoreDataSource.deleteOrder(id);
  }

  @override
  Future<void> deleteCompletedOrders() async {
    return await _firestoreDataSource.deleteCompletedOrders();
  }
} 