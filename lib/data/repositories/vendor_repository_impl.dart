import '../../core/config/cache_config.dart';
import '../../core/services/cache_service.dart';
import '../../domain/entities/vendor.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/firestore_datasource.dart';
import '../models/vendor_model.dart';

class VendorRepositoryImpl implements VendorRepository {
  final FirestoreDataSource _firestoreDataSource;

  VendorRepositoryImpl({required FirestoreDataSource firestoreDataSource})
    : _firestoreDataSource = firestoreDataSource;

  @override
  Future<List<Vendor>> getVendors() async {
    // Try to get from cache first
    if (CacheConfig.enableCache) {
      final cachedVendors = CacheService.getCachedList<Vendor>(
        CacheConfig.vendorsCacheKey,
        CacheConfig.vendorsTTL,
        (json) => VendorModel.fromJson(json),
      );

      if (cachedVendors != null) {
        print('✅ Loaded ${cachedVendors.length} vendors from cache');
        return cachedVendors;
      }
    }

    // Cache miss or expired - fetch from Firestore
    print('📡 Fetching vendors from Firestore...');
    final vendors = await _firestoreDataSource.getVendors();

    // Update cache
    if (CacheConfig.enableCache) {
      await CacheService.setList<Vendor>(
        CacheConfig.vendorsCacheKey,
        vendors,
        (vendor) => (vendor as VendorModel).toJson(),
      );
      print('💾 Cached ${vendors.length} vendors');
    }

    return vendors;
  }

  @override
  Future<Vendor?> getVendor(String id) async {
    return await _firestoreDataSource.getVendor(id);
  }

  @override
  Future<Vendor?> getVendorByNameAndPhone(
    String name,
    String phoneNumber,
  ) async {
    return await _firestoreDataSource.getVendorByNameAndPhone(
      name,
      phoneNumber,
    );
  }

  @override
  Future<Vendor> createVendor({
    required String name,
    required String phoneNumber,
  }) async {
    final vendor = await _firestoreDataSource.createVendor(
      name: name,
      phoneNumber: phoneNumber,
    );

    // Invalidate cache after creating
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.vendorsCacheKey);
      print('🗑️ Cleared vendors cache after creation');
    }

    return vendor;
  }

  @override
  Future<Vendor> updateVendor(
    String id, {
    String? name,
    String? phoneNumber,
  }) async {
    final vendor = await _firestoreDataSource.updateVendor(
      id,
      name: name,
      phoneNumber: phoneNumber,
    );

    // Invalidate cache after updating
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.vendorsCacheKey);
      print('🗑️ Cleared vendors cache after update');
    }

    return vendor;
  }

  @override
  Future<void> deleteVendor(String id) async {
    await _firestoreDataSource.deleteVendor(id);

    // Invalidate cache after deleting
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.vendorsCacheKey);
      print('🗑️ Cleared vendors cache after deletion');
    }
  }
}
