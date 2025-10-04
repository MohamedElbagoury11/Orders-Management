import '../../domain/entities/vendor.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/firestore_datasource.dart';

class VendorRepositoryImpl implements VendorRepository {
  final FirestoreDataSource _firestoreDataSource;

  VendorRepositoryImpl({required FirestoreDataSource firestoreDataSource})
      : _firestoreDataSource = firestoreDataSource;

  @override
  Future<List<Vendor>> getVendors() async {
    return await _firestoreDataSource.getVendors();
  }

  @override
  Future<Vendor?> getVendor(String id) async {
    return await _firestoreDataSource.getVendor(id);
  }

  @override
  Future<Vendor> createVendor({
    required String name,
    required String phoneNumber,
  }) async {
    return await _firestoreDataSource.createVendor(
      name: name,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<Vendor> updateVendor(String id, {
    String? name,
    String? phoneNumber,
  }) async {
    return await _firestoreDataSource.updateVendor(id,
      name: name,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<void> deleteVendor(String id) async {
    return await _firestoreDataSource.deleteVendor(id);
  }
} 