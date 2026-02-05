import 'package:equatable/equatable.dart';

class Vendor extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vendor({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ✅ Used to represent an unselected / placeholder vendor
  factory Vendor.empty() => Vendor(
        id: '',
        name: '',
        phoneNumber: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Optional helper getter (nice for UI checks)
  bool get isEmpty => id.isEmpty && name.isEmpty && phoneNumber.isEmpty;

  @override
  List<Object?> get props => [id, name, phoneNumber, createdAt, updatedAt];
}
