import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/client.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../domain/usecases/client_usecases.dart';
import '../../../domain/usecases/order_usecases.dart';

// Events
abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {}

class LoadOrdersByStatus extends OrderEvent {
  final OrderStatus status;

  const LoadOrdersByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class CreateOrder extends OrderEvent {
  final String vendorId;
  final String vendorName;
  final String vendorPhone;
  final List<OrderClient> clients;
  final double charge;
  final DateTime orderDate;

  const CreateOrder({
    required this.vendorId,
    required this.vendorName,
    required this.vendorPhone,
    required this.clients,
    required this.charge,
    required this.orderDate,
  });

  @override
  List<Object?> get props => [
    vendorId,
    vendorName,
    vendorPhone,
    clients,
    charge,
    orderDate,
  ];
}

class UpdateOrder extends OrderEvent {
  final String id;
  final String? vendorName;
  final String? vendorPhone;
  final List<OrderClient>? clients;
  final double? charge;
  final OrderStatus? status;
  final DateTime? orderDate;

  const UpdateOrder({
    required this.id,
    this.vendorName,
    this.vendorPhone,
    this.clients,
    this.charge,
    this.status,
    this.orderDate,
  });

  @override
  List<Object?> get props => [
    id,
    vendorName,
    vendorPhone,
    clients,
    charge,
    status,
    orderDate,
  ];
}

class UpdateClientReceived extends OrderEvent {
  final String orderId;
  final String clientId;
  final bool isReceived;

  const UpdateClientReceived({
    required this.orderId,
    required this.clientId,
    required this.isReceived,
  });

  @override
  List<Object?> get props => [orderId, clientId, isReceived];
}

class DeleteOrder extends OrderEvent {
  final String id;

  const DeleteOrder(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteCompletedOrders extends OrderEvent {}

class DeleteCompletedClients extends OrderEvent {
  final List<Client> clientsToDelete;

  const DeleteCompletedClients(this.clientsToDelete);

  @override
  List<Object?> get props => [clientsToDelete];
}

class UploadImagesForClient extends OrderEvent {
  final String orderId;
  final String clientId;
  final List<String> imageUrls;

  const UploadImagesForClient({
    required this.orderId,
    required this.clientId,
    required this.imageUrls,
  });

  @override
  List<Object?> get props => [orderId, clientId, imageUrls];
}

// States
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<Order> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderCreated extends OrderState {
  final Order order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderUpdated extends OrderState {
  final Order order;

  const OrderUpdated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderDeleted extends OrderState {}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrdersUseCase getOrders;
  final GetOrdersByStatusUseCase getOrdersByStatus;
  final GetOrderUseCase getOrder;
  final CreateOrderUseCase createOrder;
  final UpdateOrderUseCase updateOrder;
  final UpdateClientReceivedUseCase updateClientReceived;
  final UploadImagesForClientUseCase uploadImagesForClient;
  final DeleteOrderUseCase deleteOrder;
  final DeleteCompletedOrdersUseCase deleteCompletedOrders;
  final DeleteClientsByNameAndPhoneUseCase deleteClientsByNameAndPhone;
  final GetCurrentUserUseCase getCurrentUser;
  final IncrementUserOrderCountUseCase incrementUserOrderCount;

  OrderBloc({
    required this.getOrders,
    required this.getOrdersByStatus,
    required this.getOrder,
    required this.createOrder,
    required this.updateOrder,
    required this.updateClientReceived,
    required this.uploadImagesForClient,
    required this.deleteOrder,
    required this.deleteCompletedOrders,
    required this.deleteClientsByNameAndPhone,
    required this.getCurrentUser,
    required this.incrementUserOrderCount,
  }) : super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadOrdersByStatus>(_onLoadOrdersByStatus);
    on<CreateOrder>(_onCreateOrder);
    on<UpdateOrder>(_onUpdateOrder);
    on<UpdateClientReceived>(_onUpdateClientReceived);
    on<UploadImagesForClient>(_onUploadImagesForClient);
    on<DeleteOrder>(_onDeleteOrder);
    on<DeleteCompletedOrders>(_onDeleteCompletedOrders);
    on<DeleteCompletedClients>(_onDeleteCompletedClients);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await getOrders();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onLoadOrdersByStatus(
    LoadOrdersByStatus event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await getOrdersByStatus(event.status);
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      // Check subscription limits at device level
      final currentUser = await getCurrentUser();
      if (currentUser != null && currentUser.subscriptionType == 'free') {
        final deviceId = currentUser.deviceId;

        if (deviceId != null &&
            deviceId.isNotEmpty &&
            deviceId != 'unknown-device') {
          // Get the latest device order count from free_plan_devices collection
          final deviceQuery =
              await firestore.FirebaseFirestore.instance
                  .collection('free_plan_devices')
                  .where('deviceId', isEqualTo: deviceId)
                  .limit(1)
                  .get();

          if (deviceQuery.docs.isNotEmpty) {
            final deviceOrderCount =
                deviceQuery.docs.first.data()['orderCount'] as int? ?? 0;

            if (deviceOrderCount >= 5) {
              emit(OrderError(AppStrings.freePlanLimitReached));
              return;
            }
          }
        } else {
          // Fallback to user order count if no device ID
          if (currentUser.orderCount >= 5) {
            emit(OrderError(AppStrings.freePlanLimitReached));
            return;
          }
        }
      }

      final order = await createOrder(
        vendorId: event.vendorId,
        vendorName: event.vendorName,
        vendorPhone: event.vendorPhone,
        clients: event.clients,
        charge: event.charge,
        orderDate: event.orderDate,
      );

      // Increment user order count
      if (currentUser != null) {
        await incrementUserOrderCount(currentUser.id);
      }

      emit(OrderCreated(order));
      // Reload to get latest data
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdateOrder(
    UpdateOrder event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final order = await updateOrder(
        event.id,
        vendorName: event.vendorName,
        vendorPhone: event.vendorPhone,
        clients: event.clients,
        charge: event.charge,
        status: event.status,
        orderDate: event.orderDate,
      );
      emit(OrderUpdated(order));
      // Reload to get latest data
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdateClientReceived(
    UpdateClientReceived event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final updatedOrder = await updateClientReceived(
        event.orderId,
        event.clientId,
        event.isReceived,
      );

      emit(OrderUpdated(updatedOrder));
      // Reload to get latest data
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUploadImagesForClient(
    UploadImagesForClient event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      await uploadImagesForClient(
        event.orderId,
        event.clientId,
        event.imageUrls,
      );
      // Reload to get latest data
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onDeleteOrder(
    DeleteOrder event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      await deleteOrder(event.id);
      emit(OrderDeleted());
      // Reload to get latest data
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onDeleteCompletedOrders(
    DeleteCompletedOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      await deleteCompletedOrders();
      emit(OrderDeleted());
      // Reload to get latest data
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onDeleteCompletedClients(
    DeleteCompletedClients event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      // Delete clients from the clients collection only, not from orders
      // Orders should remain intact with their client information
      final clientsToDelete =
          event.clientsToDelete
              .map(
                (client) => {'name': client.name, 'phone': client.phoneNumber},
              )
              .toList();

      await deleteClientsByNameAndPhone(clientsToDelete);

      emit(OrderDeleted());
      // Reload to get latest data
      add(LoadOrders());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
