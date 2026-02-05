import 'package:equatable/equatable.dart';

enum OrderStatus { pending, working, complete }

class Order extends Equatable {
  final String id;
  final String vendorId; // Reference to vendor
  final String vendorName;
  final String vendorPhone;
  final List<OrderClient> clients;
  final double charge;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId; // To filter by user

  const Order({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.vendorPhone,
    required this.clients,
    required this.charge,
    required this.status,
    required this.orderDate,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  double get totalPurchasePrice =>
      clients.fold(0, (sum, client) => sum + client.purchasePrice);
  double get totalSalesPrice =>
      clients.fold(0, (sum, client) => sum + client.salePrice);
  double get netProfit => totalSalesPrice - totalPurchasePrice - charge;

  bool get allClientsReceived => clients.every((client) => client.isReceived);
  int get receivedClientsCount =>
      clients.where((client) => client.isReceived).length;

  @override
  List<Object?> get props => [
    id,
    vendorId,
    vendorName,
    vendorPhone,
    clients,
    charge,
    status,
    orderDate,
    createdAt,
    updatedAt,
    userId,
  ];
}

class OrderClient extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String address;
  final int piecesNumber;
  final double purchasePrice;
  final double salePrice;
  final bool isReceived;
  final DateTime createdAt;
  final List<String> images; // Add images field
  final double deposit;

  const OrderClient({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.piecesNumber,
    required this.purchasePrice,
    required this.salePrice,
    this.isReceived = false,
    required this.createdAt,
    this.images = const [], // Initialize with empty list
    required this.deposit,
  });

  OrderClient copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? address,
    int? piecesNumber,
    double? purchasePrice,
    double? salePrice,
    bool? isReceived,
    DateTime? createdAt,
    List<String>? images,
    double? deposit,
  }) {
    return OrderClient(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      piecesNumber: piecesNumber ?? this.piecesNumber,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      isReceived: isReceived ?? this.isReceived,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
      deposit: deposit ?? this.deposit,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    address,
    piecesNumber,
    purchasePrice,
    salePrice,
    isReceived,
    createdAt,
    images,
    deposit,
  ];
}
