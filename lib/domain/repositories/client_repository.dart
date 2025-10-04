import '../entities/client.dart';

abstract class ClientRepository {
  Future<List<Client>> getClients();
  Future<Client?> getClient(String id);
  Future<Client?> getClientByNameAndPhone(String name, String phoneNumber);
  Future<Client> createClient({
    required String name,
    required String phoneNumber,
    required String address,
  });
  Future<Client> updateClient(String id, {
    String? name,
    String? phoneNumber,
    String? address,
  });
  Future<void> deleteClient(String id);
  Future<void> deleteClientsByNameAndPhone(List<Map<String, String>> clients);
} 