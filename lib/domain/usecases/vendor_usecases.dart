import '../entities/vendor.dart';
import '../repositories/vendor_repository.dart';

class GetVendorsUseCase {
  final VendorRepository repository;

  GetVendorsUseCase(this.repository);

  Future<List<Vendor>> call() async {
    return await repository.getVendors();
  }
}

class GetVendorUseCase {
  final VendorRepository repository;

  GetVendorUseCase(this.repository);

  Future<Vendor?> call(String id) async {
    return await repository.getVendor(id);
  }
}

class CreateVendorUseCase {
  final VendorRepository repository;

  CreateVendorUseCase(this.repository);

  Future<Vendor> call({
    required String name,
    required String phoneNumber,
  }) async {
    return await repository.createVendor(
      name: name,
      phoneNumber: phoneNumber,
    );
  }
}

class UpdateVendorUseCase {
  final VendorRepository repository;

  UpdateVendorUseCase(this.repository);

  Future<Vendor> call(String id, {
    String? name,
    String? phoneNumber,
  }) async {
    return await repository.updateVendor(id,
      name: name,
      phoneNumber: phoneNumber,
    );
  }
}

class DeleteVendorUseCase {
  final VendorRepository repository;

  DeleteVendorUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteVendor(id);
  }
} 