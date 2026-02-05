import '../../domain/entities/order.dart';

class VendorInfo {
  final String name;
  final String phone;
  final List<Order> orders;

  VendorInfo({required this.name, required this.phone, required this.orders});

  double get totalNetProfit =>
      orders.fold(0.0, (sum, order) => sum + order.netProfit);

  OrderStatus get status {
    if (orders.isEmpty) return OrderStatus.pending;
    if (orders.any((order) => order.status == OrderStatus.working)) {
      return OrderStatus.working;
    }
    if (orders.every((order) => order.status == OrderStatus.complete)) {
      return OrderStatus.complete;
    }
    return OrderStatus.pending;
  }
}
