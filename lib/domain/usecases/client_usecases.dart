import '../entities/client.dart';
import '../repositories/client_repository.dart';

class GetClientsUseCase {
  final ClientRepository repository;

  GetClientsUseCase(this.repository);

  Future<List<Client>> call() async {
    return await repository.getClients();
  }
}

class GetClientUseCase {
  final ClientRepository repository;

  GetClientUseCase(this.repository);

  Future<Client?> call(String id) async {
    return await repository.getClient(id);
  }
}

class GetClientByNameAndPhoneUseCase {
  final ClientRepository repository;

  GetClientByNameAndPhoneUseCase(this.repository);

  Future<Client?> call(String name, String phoneNumber) async {
    return await repository.getClientByNameAndPhone(name, phoneNumber);
  }
}

class CreateClientUseCase {
  final ClientRepository repository;

  CreateClientUseCase(this.repository);

  Future<Client> call({
    required String name,
    required String phoneNumber,
    required String address,
  }) async {
    return await repository.createClient(
      name: name,
      phoneNumber: phoneNumber,
      address: address,
    );
  }
}

class UpdateClientUseCase {
  final ClientRepository repository;

  UpdateClientUseCase(this.repository);

  Future<Client> call(String id, {
    String? name,
    String? phoneNumber,
    String? address,
  }) async {
    return await repository.updateClient(id,
      name: name,
      phoneNumber: phoneNumber,
      address: address,
    );
  }
}

class DeleteClientUseCase {
  final ClientRepository repository;

  DeleteClientUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteClient(id);
  }
}

class DeleteClientsByNameAndPhoneUseCase {
  final ClientRepository repository;

  DeleteClientsByNameAndPhoneUseCase(this.repository);

  Future<void> call(List<Map<String, String>> clients) async {
    return await repository.deleteClientsByNameAndPhone(clients);
  }
} 