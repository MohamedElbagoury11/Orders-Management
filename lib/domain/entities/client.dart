import 'package:equatable/equatable.dart';

class Client extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Client({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, phoneNumber, address, createdAt, updatedAt];
} 