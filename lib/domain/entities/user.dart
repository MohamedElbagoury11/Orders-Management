import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final DateTime createdAt;
  final String subscriptionType; // 'free', 'monthly', 'yearly', 'pro'
  final DateTime? subscriptionExpiry;
  final bool isPro;
  final int orderCount; // Total orders created (for free plan limit)
  final String? deviceId; // Device identifier for tracking across accounts

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    required this.createdAt,
    this.subscriptionType = 'free',
    this.subscriptionExpiry,
    this.isPro = false,
    this.orderCount = 0,
    this.deviceId,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    photoUrl,
    createdAt,
    subscriptionType,
    subscriptionExpiry,
    isPro,
    orderCount,
    deviceId,
  ];
}
