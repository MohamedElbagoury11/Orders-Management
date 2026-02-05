import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.vendorId,
    required super.vendorName,
    required super.vendorPhone,
    required super.clients,
    required super.charge,
    required super.status,
    required super.orderDate,
    required super.createdAt,
    required super.updatedAt,
    required super.userId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      vendorId:
          json['vendorId'] as String? ??
          '', // Handle existing orders without vendorId
      vendorName: json['vendorName'] as String,
      vendorPhone: json['vendorPhone'] as String,
      clients:
          (json['clients'] as List<dynamic>)
              .map(
                (clientJson) => OrderClientModel.fromJson(
                  clientJson as Map<String, dynamic>,
                ),
              )
              .toList(),
      charge: (json['charge'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      orderDate: DateTime.parse(json['orderDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'vendorPhone': vendorPhone,
      'clients':
          clients
              .map((client) => (client as OrderClientModel).toJson())
              .toList(),
      'charge': charge,
      'status': status.toString().split('.').last,
      'orderDate': orderDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
    };
  }
}

class OrderClientModel extends OrderClient {
  const OrderClientModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    required super.address,
    required super.piecesNumber,
    required super.purchasePrice,
    required super.salePrice,
    super.isReceived = false,
    required super.createdAt,
    required super.deposit,
    super.images = const [], // Add images parameter
  });

  factory OrderClientModel.fromJson(Map<String, dynamic> json) {
    return OrderClientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      piecesNumber: json['piecesNumber'] as int,
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num).toDouble(),
      isReceived: json['isReceived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? const [],
      deposit:
          (json['deposit'] as num?)?.toDouble() ??
          0.0, // Handle deposit with default value
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'piecesNumber': piecesNumber,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'isReceived': isReceived,
      'createdAt': createdAt.toIso8601String(),
      'images': images, // Add images to JSON
      'deposit': deposit,
    };
  }

  OrderClientModel copyWith({
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
    return OrderClientModel(
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
}
