import '../../core/config/cache_config.dart';
import '../../core/services/cache_service.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/firestore_datasource.dart';
import '../models/client_model.dart';

class ClientRepositoryImpl implements ClientRepository {
  final FirestoreDataSource _firestoreDataSource;

  ClientRepositoryImpl({required FirestoreDataSource firestoreDataSource})
    : _firestoreDataSource = firestoreDataSource;

  @override
  Future<List<Client>> getClients() async {
    // Try to get from cache first
    if (CacheConfig.enableCache) {
      final cachedClients = CacheService.getCachedList<Client>(
        CacheConfig.clientsCacheKey,
        CacheConfig.clientsTTL,
        (json) => ClientModel.fromJson(json),
      );

      if (cachedClients != null) {
        print('✅ Loaded ${cachedClients.length} clients from cache');
        return cachedClients;
      }
    }

    // Cache miss or expired - fetch from Firestore
    print('📡 Fetching clients from Firestore...');
    final clients = await _firestoreDataSource.getClients();

    // Update cache
    if (CacheConfig.enableCache) {
      await CacheService.setList<Client>(
        CacheConfig.clientsCacheKey,
        clients,
        (client) => (client as ClientModel).toJson(),
      );
      print('💾 Cached ${clients.length} clients');
    }

    return clients;
  }

  @override
  Future<Client?> getClient(String id) async {
    return await _firestoreDataSource.getClient(id);
  }

  @override
  Future<Client?> getClientByNameAndPhone(
    String name,
    String phoneNumber,
  ) async {
    return await _firestoreDataSource.getClientByNameAndPhone(
      name,
      phoneNumber,
    );
  }

  @override
  Future<Client> createClient({
    required String name,
    required String phoneNumber,
    required String address,
  }) async {
    final client = await _firestoreDataSource.createClient(
      name: name,
      phoneNumber: phoneNumber,
      address: address,
    );

    // Invalidate cache after creating
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.clientsCacheKey);
      print('🗑️ Cleared clients cache after creation');
    }

    return client;
  }

  @override
  Future<Client> updateClient(
    String id, {
    String? name,
    String? phoneNumber,
    String? address,
  }) async {
    final client = await _firestoreDataSource.updateClient(
      id,
      name: name,
      phoneNumber: phoneNumber,
      address: address,
    );

    // Invalidate cache after updating
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.clientsCacheKey);
      print('🗑️ Cleared clients cache after update');
    }

    return client;
  }

  @override
  Future<void> deleteClient(String id) async {
    await _firestoreDataSource.deleteClient(id);

    // Invalidate cache after deleting
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.clientsCacheKey);
      print('🗑️ Cleared clients cache after deletion');
    }
  }

  @override
  Future<void> deleteClientsByNameAndPhone(
    List<Map<String, String>> clients,
  ) async {
    await _firestoreDataSource.deleteClientsByNameAndPhone(clients);

    // Invalidate cache after bulk delete
    if (CacheConfig.enableCache) {
      await CacheService.clearCache(CacheConfig.clientsCacheKey);
      print('🗑️ Cleared clients cache after bulk deletion');
    }
  }
}
