import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.photoUrl,
    required super.createdAt,
    super.subscriptionType,
    super.subscriptionExpiry,
    super.isPro,
    super.orderCount,
    super.deviceId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      subscriptionType: json['subscriptionType'] as String? ?? 'free',
      subscriptionExpiry:
          json['subscriptionExpiry'] != null
              ? DateTime.parse(json['subscriptionExpiry'] as String)
              : null,
      isPro: json['isPro'] as bool? ?? false,
      orderCount: json['orderCount'] as int? ?? 0,
      deviceId: json['deviceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'subscriptionType': subscriptionType,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'isPro': isPro,
      'orderCount': orderCount,
      'deviceId': deviceId,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    String? subscriptionType,
    DateTime? subscriptionExpiry,
    bool? isPro,
    int? orderCount,
    String? deviceId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      isPro: isPro ?? this.isPro,
      orderCount: orderCount ?? this.orderCount,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
