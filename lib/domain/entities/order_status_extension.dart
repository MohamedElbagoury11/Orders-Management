import '../entities/order.dart';

extension OrderStatusExtension on OrderStatus {
  /// Convert OrderStatus to Firestore-compatible string
  String toFirestore() => toString().split('.').last;

  /// Parse OrderStatus from Firestore string
  static OrderStatus fromFirestore(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.toString().split('.').last == value,
      orElse: () => OrderStatus.pending,
    );
  }

  /// Get display name for order status
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.working:
        return 'In Progress';
      case OrderStatus.complete:
        return 'Completed';
    }
  }
}
