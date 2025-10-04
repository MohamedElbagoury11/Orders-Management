import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/client.dart';
import '../../../domain/usecases/client_usecases.dart';

// Events
abstract class ClientEvent extends Equatable {
  const ClientEvent();

  @override
  List<Object?> get props => [];
}

class LoadClients extends ClientEvent {}

class CreateClient extends ClientEvent {
  final String name;
  final String phoneNumber;
  final String address;

  const CreateClient({
    required this.name,
    required this.phoneNumber,
    required this.address,
  });

  @override
  List<Object?> get props => [name, phoneNumber, address];
}

class UpdateClient extends ClientEvent {
  final String id;
  final String? name;
  final String? phoneNumber;
  final String? address;

  const UpdateClient({
    required this.id,
    this.name,
    this.phoneNumber,
    this.address,
  });

  @override
  List<Object?> get props => [id, name, phoneNumber, address];
}

class DeleteClient extends ClientEvent {
  final String id;

  const DeleteClient(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteClientsByNameAndPhone extends ClientEvent {
  final List<Map<String, String>> clients;

  const DeleteClientsByNameAndPhone(this.clients);

  @override
  List<Object?> get props => [clients];
}

// States
abstract class ClientState extends Equatable {
  const ClientState();

  @override
  List<Object?> get props => [];
}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {}

class ClientsLoaded extends ClientState {
  final List<Client> clients;

  const ClientsLoaded(this.clients);

  @override
  List<Object?> get props => [clients];
}

class ClientCreated extends ClientState {
  final Client client;

  const ClientCreated(this.client);

  @override
  List<Object?> get props => [client];
}

class ClientUpdated extends ClientState {
  final Client client;

  const ClientUpdated(this.client);

  @override
  List<Object?> get props => [client];
}

class ClientDeleted extends ClientState {}

class ClientError extends ClientState {
  final String message;

  const ClientError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final GetClientsUseCase getClients;
  final GetClientUseCase getClient;
  final CreateClientUseCase createClient;
  final UpdateClientUseCase updateClient;
  final DeleteClientUseCase deleteClient;
  final DeleteClientsByNameAndPhoneUseCase deleteClientsByNameAndPhone;

  ClientBloc({
    required this.getClients,
    required this.getClient,
    required this.createClient,
    required this.updateClient,
    required this.deleteClient,
    required this.deleteClientsByNameAndPhone,
  }) : super(ClientInitial()) {
    on<LoadClients>(_onLoadClients);
    on<CreateClient>(_onCreateClient);
    on<UpdateClient>(_onUpdateClient);
    on<DeleteClient>(_onDeleteClient);
    on<DeleteClientsByNameAndPhone>(_onDeleteClientsByNameAndPhone);
  }

  Future<void> _onLoadClients(LoadClients event, Emitter<ClientState> emit) async {
    emit(ClientLoading());
    try {
      final clients = await getClients();
      emit(ClientsLoaded(clients));
    } catch (e) {
      emit(ClientError(e.toString()));
    }
  }

  Future<void> _onCreateClient(CreateClient event, Emitter<ClientState> emit) async {
    emit(ClientLoading());
    try {
      final client = await createClient(
        name: event.name,
        phoneNumber: event.phoneNumber,
        address: event.address,
      );
      emit(ClientCreated(client));
      final clients = await getClients();
      emit(ClientsLoaded(clients));
    } catch (e) {
      emit(ClientError(e.toString()));
    }
  }

  Future<void> _onUpdateClient(UpdateClient event, Emitter<ClientState> emit) async {
    emit(ClientLoading());
    try {
      final client = await updateClient(
        event.id,
        name: event.name,
        phoneNumber: event.phoneNumber,
        address: event.address,
      );
      emit(ClientUpdated(client));
      final clients = await getClients();
      emit(ClientsLoaded(clients));
    } catch (e) {
      emit(ClientError(e.toString()));
    }
  }

  Future<void> _onDeleteClient(DeleteClient event, Emitter<ClientState> emit) async {
    emit(ClientLoading());
    try {
      await deleteClient(event.id);
      emit(ClientDeleted());
      final clients = await getClients();
      emit(ClientsLoaded(clients));
    } catch (e) {
      emit(ClientError(e.toString()));
    }
  }

  Future<void> _onDeleteClientsByNameAndPhone(DeleteClientsByNameAndPhone event, Emitter<ClientState> emit) async {
    emit(ClientLoading());
    try {
      await deleteClientsByNameAndPhone(event.clients);
      emit(ClientDeleted());
      final clients = await getClients();
      emit(ClientsLoaded(clients));
    } catch (e) {
      emit(ClientError(e.toString()));
    }
  }
} 