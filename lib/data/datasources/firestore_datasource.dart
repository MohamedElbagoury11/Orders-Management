import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:uuid/uuid.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/user.dart';
import '../models/client_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/vendor_model.dart';

abstract class FirestoreDataSource {
  // Users
  Future<void> createUser(User user);
  Future<UserModel?> getUser(String id);
  Future<void> incrementUserOrderCount(String userId);

  // Orders
  Future<List<OrderModel>> getOrders();
  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status);
  Future<OrderModel?> getOrder(String id);
  Future<OrderModel> createOrder({
    required String vendorId,
    required String vendorName,
    required String vendorPhone,
    required List<OrderClient> clients,
    required double charge,
    required DateTime orderDate,
  });
  Future<OrderModel> updateOrder(
    String id, {
    String? vendorName,
    String? vendorPhone,
    List<OrderClient>? clients,
    double? charge,
    OrderStatus? status,
    DateTime? orderDate,
  });
  Future<OrderModel> updateClientReceived(
    String orderId,
    String clientId,
    bool isReceived,
  );
  Future<OrderModel> uploadImagesForClient(
    String orderId,
    String clientId,
    List<String> imageUrls,
  );
  Future<void> deleteOrderImages(String orderId);
  Future<void> deleteOrder(String id);
  Future<void> deleteCompletedOrders();

  // Vendors
  Future<List<VendorModel>> getVendors();
  Future<VendorModel?> getVendor(String id);
  Future<VendorModel?> getVendorByNameAndPhone(String name, String phoneNumber);
  Future<VendorModel> createVendor({
    required String name,
    required String phoneNumber,
  });
  Future<VendorModel> updateVendor(
    String id, {
    String? name,
    String? phoneNumber,
  });
  Future<void> deleteVendor(String id);

  // Clients
  Future<List<ClientModel>> getClients();
  Future<ClientModel?> getClient(String id);
  Future<ClientModel?> getClientByNameAndPhone(String name, String phoneNumber);
  Future<ClientModel> createClient({
    required String name,
    required String phoneNumber,
    required String address,
  });
  Future<ClientModel> updateClient(
    String id, {
    String? name,
    String? phoneNumber,
    String? address,
  });
  Future<void> deleteClient(String id);
  Future<void> deleteClientsByNameAndPhone(List<Map<String, String>> clients);
}

class FirestoreDataSourceImpl implements FirestoreDataSource {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;
  final Uuid _uuid;

  FirestoreDataSourceImpl({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
    Uuid? uuid,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _uuid = uuid ?? const Uuid();

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Users
  @override
  Future<void> createUser(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.id).get();

      // Get device ID - should always be available from DeviceHelper
      String? deviceId = user.deviceId;
      int deviceOrderCount = 0;

      // Always sync with device if we have a valid device ID
      if (deviceId != null &&
          deviceId.isNotEmpty &&
          deviceId != 'unknown-device') {
        // Check if this device has been used before in free_plan_devices collection
        final deviceQuery =
            await _firestore
                .collection('free_plan_devices')
                .where('deviceId', isEqualTo: deviceId)
                .limit(1)
                .get();

        if (deviceQuery.docs.isNotEmpty) {
          // Device exists - get the order count
          final deviceData = deviceQuery.docs.first.data();
          deviceOrderCount = deviceData['orderCount'] as int? ?? 0;

          // Update last used info
          await _firestore
              .collection('free_plan_devices')
              .doc(deviceQuery.docs.first.id)
              .update({
                'lastUserId': user.id,
                'lastSignInAt': DateTime.now().toIso8601String(),
              });
        } else {
          // New device - create device record
          await _firestore.collection('free_plan_devices').add({
            'deviceId': deviceId,
            'orderCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
            'lastUserId': user.id,
            'lastSignInAt': DateTime.now().toIso8601String(),
          });
        }
      }

      if (doc.exists) {
        // Existing user - always sync device order count
        await _firestore.collection('users').doc(user.id).update({
          'email': user.email,
          'name': user.name,
          'photoUrl': user.photoUrl,
          'deviceId': deviceId,
          'orderCount': deviceOrderCount, // Always sync from device
        });
      } else {
        // New user - create with device order count
        final userModel = UserModel(
          id: user.id,
          email: user.email,
          name: user.name,
          photoUrl: user.photoUrl,
          createdAt: user.createdAt,
          subscriptionType: 'free',
          subscriptionExpiry: user.createdAt.add(const Duration(days: 7)),
          isPro: false,
          orderCount: deviceOrderCount, // Use device's order count
          deviceId: deviceId,
        );

        await _firestore.collection('users').doc(user.id).set({
          ...userModel.toJson(),
          'userId': user.id,
        });
      }
    } catch (e) {
      throw Exception('Failed to create/update user: $e');
    }
  }

  @override
  Future<UserModel?> getUser(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<void> incrementUserOrderCount(String userId) async {
    try {
      // Increment user's order count
      await _firestore.collection('users').doc(userId).update({
        'orderCount': FieldValue.increment(1),
      });

      // Also increment device order count if device ID exists
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final deviceId = userData?['deviceId'] as String?;

        if (deviceId != null &&
            deviceId.isNotEmpty &&
            deviceId != 'unknown-device') {
          // Update device order count in free_plan_devices collection
          final deviceQuery =
              await _firestore
                  .collection('free_plan_devices')
                  .where('deviceId', isEqualTo: deviceId)
                  .limit(1)
                  .get();

          if (deviceQuery.docs.isNotEmpty) {
            await _firestore
                .collection('free_plan_devices')
                .doc(deviceQuery.docs.first.id)
                .update({
                  'orderCount': FieldValue.increment(1),
                  'lastUserId': userId,
                  'updatedAt': DateTime.now().toIso8601String(),
                });
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to increment user order count: $e');
    }
  }

  // Orders
  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final snapshot =
          await _firestore
              .collection('orders')
              .where('userId', isEqualTo: _currentUserId)
              .orderBy('orderDate', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status) async {
    try {
      final snapshot =
          await _firestore
              .collection('orders')
              .where('userId', isEqualTo: _currentUserId)
              .where('status', isEqualTo: status.toString().split('.').last)
              .orderBy('orderDate', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  @override
  Future<OrderModel?> getOrder(String id) async {
    try {
      final doc = await _firestore.collection('orders').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        // Check if order belongs to current user
        if (data['userId'] == _currentUserId) {
          return OrderModel.fromJson({...data, 'id': doc.id});
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  @override
  Future<OrderModel> createOrder({
    required String vendorId,
    required String vendorName,
    required String vendorPhone,
    required List<OrderClient> clients,
    required double charge,
    required DateTime orderDate,
  }) async {
    try {
      final now = DateTime.now();
      // Always start with pending status when creating a new order
      final initialStatus = OrderStatus.pending;

      final order = OrderModel(
        id: _uuid.v4(),
        vendorId: vendorId,
        vendorName: vendorName,
        vendorPhone: vendorPhone,
        clients:
            clients
                .map(
                  (client) => OrderClientModel(
                    id: client.id,
                    name: client.name,
                    phoneNumber: client.phoneNumber,
                    address: client.address,
                    piecesNumber: client.piecesNumber,
                    purchasePrice: client.purchasePrice,
                    salePrice: client.salePrice,
                    isReceived: client.isReceived,
                    createdAt: client.createdAt,
                    images: client.images,
                    deposit: client.deposit,
                  ),
                )
                .toList(),
        charge: charge,
        status: initialStatus,
        orderDate: orderDate,
        createdAt: now,
        updatedAt: now,
        userId: _currentUserId,
      );

      // Create order document
      await _firestore.collection('orders').doc(order.id).set(order.toJson());

      // Store vendor details in vendors collection if not exists
      await _firestore.collection('vendors').doc(vendorId).set({
        'id': vendorId,
        'name': vendorName,
        'phoneNumber': vendorPhone,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'userId': _currentUserId,
      }, SetOptions(merge: true));

      // Store client details in clients collection
      for (final client in clients) {
        await _firestore.collection('clients').doc(client.id).set({
          'id': client.id,
          'name': client.name,
          'phoneNumber': client.phoneNumber,
          'address': client.address,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'userId': _currentUserId,
        }, SetOptions(merge: true));
      }

      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<OrderModel> updateOrder(
    String id, {
    String? vendorName,
    String? vendorPhone,
    List<OrderClient>? clients,
    double? charge,
    OrderStatus? status,
    DateTime? orderDate,
  }) async {
    try {
      final now = DateTime.now();
      final updates = <String, dynamic>{'updatedAt': now.toIso8601String()};

      if (vendorName != null) updates['vendorName'] = vendorName;
      if (vendorPhone != null) updates['vendorPhone'] = vendorPhone;
      if (clients != null) {
        updates['clients'] =
            clients
                .map(
                  (client) =>
                      OrderClientModel(
                        id: client.id,
                        name: client.name,
                        phoneNumber: client.phoneNumber,
                        address: client.address,
                        piecesNumber: client.piecesNumber,
                        purchasePrice: client.purchasePrice,
                        salePrice: client.salePrice,
                        isReceived: client.isReceived,
                        createdAt: client.createdAt,
                        images: client.images,
                        deposit: client.deposit,
                      ).toJson(),
                )
                .toList();

        // Store new clients in clients collection
        for (final client in clients) {
          await _firestore.collection('clients').doc(client.id).set({
            'id': client.id,
            'name': client.name,
            'phoneNumber': client.phoneNumber,
            'address': client.address,
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
            'userId': _currentUserId,
          }, SetOptions(merge: true));
        }
      }
      if (charge != null) updates['charge'] = charge;
      if (status != null) updates['status'] = status.toString().split('.').last;
      if (orderDate != null) updates['orderDate'] = orderDate.toIso8601String();

      await _firestore.collection('orders').doc(id).update(updates);

      // Return updated order
      final updatedOrder = await getOrder(id);
      if (updatedOrder != null) {
        return updatedOrder;
      }
      throw Exception('Failed to get updated order');
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  @override
  Future<OrderModel> updateClientReceived(
    String orderId,
    String clientId,
    bool isReceived,
  ) async {
    try {
      // Use Firestore transaction to prevent race conditions
      return await _firestore.runTransaction<OrderModel>((transaction) async {
        final orderRef = _firestore.collection('orders').doc(orderId);
        final orderDoc = await transaction.get(orderRef);

        if (!orderDoc.exists) {
          throw Exception('Order not found');
        }

        final orderData = orderDoc.data()!;
        if (orderData['userId'] != _currentUserId) {
          throw Exception('Unauthorized access to order');
        }

        final order = OrderModel.fromJson({...orderData, 'id': orderDoc.id});

        // Update the specific client using copyWith
        final updatedClients =
            order.clients.map((client) {
              if (client.id == clientId) {
                return (client as OrderClientModel).copyWith(
                  isReceived: isReceived,
                );
              }
              return client as OrderClientModel;
            }).toList();

        // Check if all clients are received
        final allReceived = updatedClients.every((client) => client.isReceived);
        OrderStatus newStatus;

        if (allReceived && updatedClients.isNotEmpty) {
          newStatus = OrderStatus.complete;
        } else if (updatedClients.any((client) => client.isReceived)) {
          newStatus = OrderStatus.working;
        } else {
          newStatus = OrderStatus.pending;
        }

        // Write update atomically
        transaction.update(orderRef, {
          'clients': updatedClients.map((c) => c.toJson()).toList(),
          'status': newStatus.toString().split('.').last,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Return updated order
        final updatedOrder = OrderModel(
          id: order.id,
          vendorId: order.vendorId,
          vendorName: order.vendorName,
          vendorPhone: order.vendorPhone,
          clients: updatedClients,
          charge: order.charge,
          status: newStatus,
          orderDate: order.orderDate,
          createdAt: order.createdAt,
          updatedAt: DateTime.now(),
          userId: order.userId,
        );

        // Delete images if order is complete (after transaction completes)
        if (allReceived && updatedClients.isNotEmpty) {
          // Schedule image deletion after transaction
          Future.microtask(() async {
            try {
              print('🔄 Order $orderId is now complete. Clearing images...');
              await deleteOrderImages(orderId);
              print('✅ Images cleared for completed order: $orderId');
            } catch (e) {
              print('⚠️ Failed to clear images: $e');
            }
          });
        }

        return updatedOrder;
      });
    } catch (e) {
      throw Exception('Failed to update client received status: $e');
    }
  }

  @override
  Future<OrderModel> uploadImagesForClient(
    String orderId,
    String clientId,
    List<String> imageUrls,
  ) async {
    try {
      final order = await getOrder(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      // Update client images using copyWith
      final updatedClients =
          order.clients.map((client) {
            if (client.id == clientId) {
              final currentImages = List<String>.from(client.images);
              currentImages.addAll(imageUrls);
              return (client as OrderClientModel).copyWith(
                images: currentImages,
              );
            }
            return client as OrderClientModel;
          }).toList();

      return await updateOrder(orderId, clients: updatedClients);
    } catch (e) {
      throw Exception('Failed to upload images for client: $e');
    }
  }

  @override
  Future<void> deleteOrderImages(String orderId) async {
    try {
      final order = await getOrder(orderId);
      if (order == null) {
        print('Order not found for image deletion: $orderId');
        return;
      }

      // Clear all images using copyWith
      final updatedClients =
          order.clients.map((client) {
            return (client as OrderClientModel).copyWith(images: const []);
          }).toList();

      // Update order with cleared images
      await updateOrder(orderId, clients: updatedClients);

      print('Image URLs cleared from order: $orderId');
    } catch (e) {
      print('Error clearing order images: $e');
      // Don't throw exception to avoid breaking the order completion process
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    try {
      // First, get the order to extract vendorId
      final orderDoc = await _firestore.collection('orders').doc(id).get();
      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      final orderData = orderDoc.data()!;
      final vendorId = orderData['vendorId'] as String?;

      // Delete the order
      await _firestore.collection('orders').doc(id).delete();

      // If vendorId exists, check if other orders use this vendor before deleting
      if (vendorId != null && vendorId.isNotEmpty) {
        try {
          // Check if there are other orders using this vendor
          final otherOrdersQuery =
              await _firestore
                  .collection('orders')
                  .where('vendorId', isEqualTo: vendorId)
                  .where('userId', isEqualTo: _currentUserId)
                  .get();

          // If no other orders use this vendor, delete the vendor
          if (otherOrdersQuery.docs.isEmpty) {
            await _firestore.collection('vendors').doc(vendorId).delete();
          }
        } catch (vendorError) {
          // Don't throw exception for vendor deletion to avoid breaking the order deletion
          // Just log the error for debugging
          print(
            'Warning: Failed to check or delete vendor $vendorId: $vendorError',
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  @override
  Future<void> deleteCompletedOrders() async {
    try {
      final completedOrders = await getOrdersByStatus(OrderStatus.complete);
      final batch = _firestore.batch();

      for (final order in completedOrders) {
        batch.delete(_firestore.collection('orders').doc(order.id));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete completed orders: $e');
    }
  }

  // Vendors
  @override
  Future<List<VendorModel>> getVendors() async {
    try {
      final snapshot =
          await _firestore
              .collection('vendors')
              .where('userId', isEqualTo: _currentUserId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return VendorModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get vendors: $e');
    }
  }

  @override
  Future<VendorModel?> getVendor(String id) async {
    try {
      final doc = await _firestore.collection('vendors').doc(id).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['userId'] == _currentUserId) {
          return VendorModel.fromJson({...data, 'id': doc.id});
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get vendor: $e');
    }
  }

  @override
  Future<VendorModel?> getVendorByNameAndPhone(
    String name,
    String phoneNumber,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('vendors')
              .where('userId', isEqualTo: _currentUserId)
              .where('name', isEqualTo: name)
              .where('phoneNumber', isEqualTo: phoneNumber)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return VendorModel.fromJson({
          ...data,
          'id': querySnapshot.docs.first.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get vendor by name and phone: $e');
    }
  }

  @override
  Future<VendorModel> createVendor({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      // Check if vendor already exists
      final existingVendor = await getVendorByNameAndPhone(name, phoneNumber);
      if (existingVendor != null) {
        return existingVendor;
      }

      final now = DateTime.now();
      final vendor = VendorModel(
        id: _uuid.v4(),
        name: name,
        phoneNumber: phoneNumber,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('vendors').doc(vendor.id).set({
        ...vendor.toJson(),
        'userId': _currentUserId,
      });

      return vendor;
    } catch (e) {
      throw Exception('Failed to create vendor: $e');
    }
  }

  @override
  Future<VendorModel> updateVendor(
    String id, {
    String? name,
    String? phoneNumber,
  }) async {
    try {
      final now = DateTime.now();
      final updates = <String, dynamic>{'updatedAt': now.toIso8601String()};

      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;

      await _firestore.collection('vendors').doc(id).update(updates);

      final updatedVendor = await getVendor(id);
      if (updatedVendor != null) {
        return updatedVendor;
      }
      throw Exception('Failed to get updated vendor');
    } catch (e) {
      throw Exception('Failed to update vendor: $e');
    }
  }

  @override
  Future<void> deleteVendor(String id) async {
    try {
      // Only delete from vendors collection, not from orders
      await _firestore.collection('vendors').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete vendor: $e');
    }
  }

  // Clients
  @override
  Future<List<ClientModel>> getClients() async {
    try {
      final snapshot =
          await _firestore
              .collection('clients')
              .where('userId', isEqualTo: _currentUserId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ClientModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get clients: $e');
    }
  }

  @override
  Future<ClientModel?> getClient(String id) async {
    try {
      final doc = await _firestore.collection('clients').doc(id).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['userId'] == _currentUserId) {
          return ClientModel.fromJson({...data, 'id': doc.id});
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get client: $e');
    }
  }

  @override
  Future<ClientModel?> getClientByNameAndPhone(
    String name,
    String phoneNumber,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('clients')
              .where('userId', isEqualTo: _currentUserId)
              .where('name', isEqualTo: name)
              .where('phoneNumber', isEqualTo: phoneNumber)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return ClientModel.fromJson({
          ...data,
          'id': querySnapshot.docs.first.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get client by name and phone: $e');
    }
  }

  @override
  Future<ClientModel> createClient({
    required String name,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      // Check if client already exists
      final existingClient = await getClientByNameAndPhone(name, phoneNumber);
      if (existingClient != null) {
        return existingClient;
      }

      final now = DateTime.now();
      final client = ClientModel(
        id: _uuid.v4(),
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('clients').doc(client.id).set({
        ...client.toJson(),
        'userId': _currentUserId,
      });

      return client;
    } catch (e) {
      throw Exception('Failed to create client: $e');
    }
  }

  @override
  Future<ClientModel> updateClient(
    String id, {
    String? name,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final now = DateTime.now();
      final updates = <String, dynamic>{'updatedAt': now.toIso8601String()};

      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (address != null) updates['address'] = address;

      await _firestore.collection('clients').doc(id).update(updates);

      final updatedClient = await getClient(id);
      if (updatedClient != null) {
        return updatedClient;
      }
      throw Exception('Failed to get updated client');
    } catch (e) {
      throw Exception('Failed to update client: $e');
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      // Only delete from clients collection, not from orders
      await _firestore.collection('clients').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete client: $e');
    }
  }

  Future<void> deleteClientsByNameAndPhone(
    List<Map<String, String>> clients,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final client in clients) {
        final name = client['name']!;
        final phone = client['phoneNumber']!;

        // Find clients by name and phone number
        final querySnapshot =
            await _firestore
                .collection('clients')
                .where('userId', isEqualTo: _currentUserId)
                .where('name', isEqualTo: name)
                .where('phoneNumber', isEqualTo: phone)
                .get();

        for (final doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete clients by name and phone: $e');
    }
  }
}
