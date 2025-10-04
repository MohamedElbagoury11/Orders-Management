import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  Future<List<Order>> call() async {
    return await repository.getOrders();
  }
}

class GetOrdersByStatusUseCase {
  final OrderRepository repository;

  GetOrdersByStatusUseCase(this.repository);

  Future<List<Order>> call(OrderStatus status) async {
    return await repository.getOrdersByStatus(status);
  }
}

class GetOrderUseCase {
  final OrderRepository repository;

  GetOrderUseCase(this.repository);

  Future<Order?> call(String id) async {
    return await repository.getOrder(id);
  }
}

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Order> call({
    required String vendorId,
    required String vendorName,
    required String vendorPhone,
    required List<OrderClient> clients,
    required double charge,
    required DateTime orderDate,
  }) async {
    return await repository.createOrder(
      vendorId: vendorId,
      vendorName: vendorName,
      vendorPhone: vendorPhone,
      clients: clients,
      charge: charge,
      orderDate: orderDate, 
    );
  }
}

class UpdateOrderUseCase {
  final OrderRepository repository;

  UpdateOrderUseCase(this.repository);

  Future<Order> call(String id, {
    String? vendorName,
    String? vendorPhone,
    List<OrderClient>? clients,
    double? charge,
    OrderStatus? status,
    DateTime? orderDate,
  }) async {
    return await repository.updateOrder(id,
      vendorName: vendorName,
      vendorPhone: vendorPhone,
      clients: clients,
      charge: charge,
      status: status,
      orderDate: orderDate,
    );
  }
}

class UpdateClientReceivedUseCase {
  final OrderRepository repository;

  UpdateClientReceivedUseCase(this.repository);

  Future<Order> call(String orderId, String clientId, bool isReceived) async {
    return await repository.updateClientReceived(orderId, clientId, isReceived);
  }
}

class DeleteOrderUseCase {
  final OrderRepository repository;

  DeleteOrderUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteOrder(id);
  }
}

class DeleteCompletedOrdersUseCase {
  final OrderRepository repository;

  DeleteCompletedOrdersUseCase(this.repository);

  Future<void> call() async {
    return await repository.deleteCompletedOrders();
  }
}

class UploadImagesForClientUseCase {
  final OrderRepository repository;

  UploadImagesForClientUseCase(this.repository);

  Future<Order> call(String orderId, String clientId, List<String> imageUrls) async {
    return await repository.uploadImagesForClient(orderId, clientId, imageUrls);
  }
}

class DeleteOrderImagesUseCase {
  final OrderRepository repository;

  DeleteOrderImagesUseCase(this.repository);

  Future<void> call(String orderId) async {
    return await repository.deleteOrderImages(orderId);
  }
} 