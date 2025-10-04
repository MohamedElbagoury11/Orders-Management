import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/vendor.dart';
import '../../../domain/usecases/vendor_usecases.dart';

// Events
abstract class VendorEvent extends Equatable {
  const VendorEvent();

  @override
  List<Object?> get props => [];
}

class LoadVendors extends VendorEvent {}

class CreateVendor extends VendorEvent {
  final String name;
  final String phoneNumber;

  const CreateVendor({
    required this.name,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [name, phoneNumber];
}

class UpdateVendor extends VendorEvent {
  final String id;
  final String? name;
  final String? phoneNumber;

  const UpdateVendor({
    required this.id,
    this.name,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, name, phoneNumber];
}

class DeleteVendor extends VendorEvent {
  final String id;

  const DeleteVendor(this.id);

  @override
  List<Object?> get props => [id];
}

// States
abstract class VendorState extends Equatable {
  const VendorState();

  @override
  List<Object?> get props => [];
}

class VendorInitial extends VendorState {}

class VendorLoading extends VendorState {}

class VendorsLoaded extends VendorState {
  final List<Vendor> vendors;

  const VendorsLoaded(this.vendors);

  @override
  List<Object?> get props => [vendors];
}

class VendorCreated extends VendorState {
  final Vendor vendor;

  const VendorCreated(this.vendor);

  @override
  List<Object?> get props => [vendor];
}

class VendorUpdated extends VendorState {
  final Vendor vendor;

  const VendorUpdated(this.vendor);

  @override
  List<Object?> get props => [vendor];
}

class VendorDeleted extends VendorState {}

class VendorError extends VendorState {
  final String message;

  const VendorError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final GetVendorsUseCase getVendors;
  final GetVendorUseCase getVendor;
  final CreateVendorUseCase createVendor;
  final UpdateVendorUseCase updateVendor;
  final DeleteVendorUseCase deleteVendor;

  VendorBloc({
    required this.getVendors,
    required this.getVendor,
    required this.createVendor,
    required this.updateVendor,
    required this.deleteVendor,
  }) : super(VendorInitial()) {
    on<LoadVendors>(_onLoadVendors);
    on<CreateVendor>(_onCreateVendor);
    on<UpdateVendor>(_onUpdateVendor);
    on<DeleteVendor>(_onDeleteVendor);
  }

  Future<void> _onLoadVendors(LoadVendors event, Emitter<VendorState> emit) async {
    emit(VendorLoading());
    try {
      final vendors = await getVendors();
      emit(VendorsLoaded(vendors));
    } catch (e) {
      emit(VendorError(e.toString()));
    }
  }

  Future<void> _onCreateVendor(CreateVendor event, Emitter<VendorState> emit) async {
    emit(VendorLoading());
    try {
      final vendor = await createVendor(
        name: event.name,
        phoneNumber: event.phoneNumber,
      );
      emit(VendorCreated(vendor));
      final vendors = await getVendors();
      emit(VendorsLoaded(vendors));
    } catch (e) {
      emit(VendorError(e.toString()));
    }
  }

  Future<void> _onUpdateVendor(UpdateVendor event, Emitter<VendorState> emit) async {
    emit(VendorLoading());
    try {
      final vendor = await updateVendor(
        event.id,
        name: event.name,
        phoneNumber: event.phoneNumber,
      );
      emit(VendorUpdated(vendor));
      final vendors = await getVendors();
      emit(VendorsLoaded(vendors));
    } catch (e) {
      emit(VendorError(e.toString()));
    }
  }

  Future<void> _onDeleteVendor(DeleteVendor event, Emitter<VendorState> emit) async {
    emit(VendorLoading());
    try {
      await deleteVendor(event.id);
      emit(VendorDeleted());
      final vendors = await getVendors();
      emit(VendorsLoaded(vendors));
    } catch (e) {
      emit(VendorError(e.toString()));
    }
  }
} 