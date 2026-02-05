import '../entities/vendor.dart';

abstract class VendorRepository {
  Future<List<Vendor>> getVendors();
  Future<Vendor?> getVendor(String id);
  Future<Vendor?> getVendorByNameAndPhone(String name, String phoneNumber);
  Future<Vendor> createVendor({
    required String name,
    required String phoneNumber,
  });
  Future<Vendor> updateVendor(String id, {String? name, String? phoneNumber});
  Future<void> deleteVendor(String id);
}
