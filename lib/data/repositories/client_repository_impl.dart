import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/firestore_datasource.dart';

class ClientRepositoryImpl implements ClientRepository {
  final FirestoreDataSource _firestoreDataSource;

  ClientRepositoryImpl({required FirestoreDataSource firestoreDataSource})
      : _firestoreDataSource = firestoreDataSource;

  @override
  Future<List<Client>> getClients() async {
    return await _firestoreDataSource.getClients();
  }

  @override
  Future<Client?> getClient(String id) async {
    return await _firestoreDataSource.getClient(id);
  }

  @override
  Future<Client?> getClientByNameAndPhone(String name, String phoneNumber) async {
    return await _firestoreDataSource.getClientByNameAndPhone(name, phoneNumber);
  }

  @override
  Future<Client> createClient({
    required String name,
    required String phoneNumber,
    required String address,
  }) async {
    return await _firestoreDataSource.createClient(
      name: name,
      phoneNumber: phoneNumber,
      address: address,
    );
  }

  @override
  Future<Client> updateClient(String id, {
    String? name,
    String? phoneNumber,
    String? address,
  }) async {
    return await _firestoreDataSource.updateClient(id,
      name: name,
      phoneNumber: phoneNumber,
      address: address,
    );
  }

  @override
  Future<void> deleteClient(String id) async {
    await _firestoreDataSource.deleteClient(id);
  }

  @override
  Future<void> deleteClientsByNameAndPhone(List<Map<String, String>> clients) async {
    await _firestoreDataSource.deleteClientsByNameAndPhone(clients);
  }
} 