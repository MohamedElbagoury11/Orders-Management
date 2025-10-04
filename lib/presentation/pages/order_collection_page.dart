import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projectmange/data/models/order_model.dart';
import 'package:projectmange/main.dart';
import 'package:projectmange/presentation/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_strings.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/client_usecases.dart';
import '../blocs/order/order_bloc.dart';
import '../widgets/auth_wrapper.dart';

class OrderCollectionPage1 extends StatefulWidget {
  final Order? orderToEdit;
  const OrderCollectionPage1({super.key, this.orderToEdit});

  @override
  State<OrderCollectionPage1> createState() => _OrderCollectionPage1State();
}

class _OrderCollectionPage1State extends State<OrderCollectionPage1> {
  final _formKey = GlobalKey<FormState>();
  final _vendorNameController = TextEditingController();
  final _vendorPhoneController = TextEditingController();
  final _chargeController = TextEditingController();
  
  final List<OrderClient> _clients = [];
  bool _isEditing = false;
  bool _isPending = true;
  bool _isSubmitting = false;
  String? _orderId;
  
  // Context dependencies
  late OrderBloc _orderBloc;
  late ScaffoldMessengerState _scaffoldMessenger;
  bool _dependenciesInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.orderToEdit != null) {
      _isEditing = true;
      _orderId = widget.orderToEdit!.id;
      _vendorNameController.text = widget.orderToEdit!.vendorName;
      _vendorPhoneController.text = widget.orderToEdit!.vendorPhone;
      _chargeController.text = widget.orderToEdit!.charge.toString();
      _clients.addAll(widget.orderToEdit!.clients);
      _isPending = widget.orderToEdit!.status == OrderStatus.pending;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dependenciesInitialized) {
      // Save references to context-dependent objects
      _orderBloc = context.read<OrderBloc>();
      _scaffoldMessenger = ScaffoldMessenger.of(context);
      _dependenciesInitialized = true;
    }
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _vendorPhoneController.dispose();
    _chargeController.dispose();
    super.dispose();
  }

  // Helper method to safely execute operations
  

  void _addClient() {
    if (!_isPending || _isSubmitting) return;
    showDialog(
      context: context,
      builder: (context) => _AddClientDialog(
        orderId: _orderId,
        onClientAdded: (client) {
          if (mounted) {
            setState(() {
              _clients.add(client);
            });
          }
        },
      ),
    );
  }

  void _removeClient(int index) async {
    if (!_isPending || _isSubmitting) return;
    
    final client = _clients[index];
    
    try {
      // Delete client from database
      await context.read<DeleteClientUseCase>()(client.id);
      
      // Remove from local list
      setState(() {
        _clients.removeAt(index);
      });
      
      // Show success message
      _scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.clientDeletedSuccessfully),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    } catch (e) {
      // Show error message
      _scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error deleting client: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _editClient(int index) {
    if (!_isPending || _isSubmitting) return;
    final client = _clients[index];
    showDialog(
      context: context,
      builder: (context) => _EditClientDialog(
        initialClient: client,
        orderId: _orderId,
        onClientEdited: (editedClient) {
          if (mounted) {
            setState(() {
              _clients[index] = editedClient;
            });
            
            // If the client has new images, we need to update the order in the database
            if (editedClient.images.isNotEmpty && editedClient.images != client.images) {
              // For editing existing orders, we need to update the order with new images
              if (_isEditing && _orderId != null) {
                _orderBloc.add(UpdateOrder(
                  id: _orderId!,
                  vendorName: _vendorNameController.text.trim(),
                  vendorPhone: _vendorPhoneController.text.trim(),
                  clients: _clients,
                  charge: double.tryParse(_chargeController.text) ?? 0.0,
                ));
              }
            }
          }
        },
      ),
    );
  }

  void _submitOrder() {
    if (_formKey.currentState != null && _formKey.currentState!.validate() && _clients.isNotEmpty && !_isSubmitting) {
      setState(() {
        _isSubmitting = true;
      });
      
      final charge = double.tryParse(_chargeController.text) ?? 0.0;
      if (_isEditing) {
        _orderBloc.add(UpdateOrder(
          id: _orderId!,
          vendorName: _vendorNameController.text.trim(),
          vendorPhone: _vendorPhoneController.text.trim(),
          clients: _clients,
          charge: charge,
        ));
      } else {
        final orderId = const Uuid().v4();
        _orderBloc.add(CreateOrder(
          vendorId: orderId,
          vendorName: _vendorNameController.text.trim(),
          vendorPhone: _vendorPhoneController.text.trim(),
          clients: _clients,
          charge: charge,
          orderDate: DateTime.now(),
        ));
        
        // After creating the order, upload images for each client
        for (final client in _clients) {
          if (client.images.isNotEmpty) {
            _orderBloc.add(UploadImagesForClient(
              orderId: orderId,
              clientId: client.id,
              imageUrls: client.images,
            ));
          }
        }
      }
    } else if (_clients.isEmpty) {
      _scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseAddAtLeastOneClient)),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.great),
        content: Text(AppStrings.yourChangesUpdated),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog only
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: languageNotifier,
      builder: (context, locale, _) {
        // Update AppStrings locale
        AppStrings.setLocale(locale);
        
        return AuthWrapper(
          child: WillPopScope(
            onWillPop: () async {
              // Navigate to home page instead of just popping
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              return false; // Prevent default back behavior
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(_isEditing ? AppStrings.editOrder : AppStrings.collectOrderTitle),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              body: BlocListener<OrderBloc, OrderState>(
                listener: (context, state) {
                  if (state is OrderCreated || state is OrderUpdated) {
                    setState(() {
                      _isSubmitting = false;
                    });
                    
                    if (_isEditing) {
                      // Show success dialog for Save Changes
                      _showSuccessDialog();
                      // Navigate back after showing dialog
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => HomePage()),
                            );
                          }
                        });
                      });
                    } else {
                      // Show SnackBar for Create Order
                      _scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text(AppStrings.orderCreatedSuccessfully)),
                      );
                      
                      // Navigate back after a short delay
                      Future.delayed(const Duration(milliseconds: 500), () {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (context) => HomePage())
                        );
                      });
                      
                      // Clear form for new orders
                      _vendorNameController.clear();
                      _vendorPhoneController.clear();
                      _chargeController.clear();
                      setState(() {
                        _clients.clear();
                      });
                    }
                  } else if (state is OrderError) {
                    setState(() {
                      _isSubmitting = false;
                    });
                    
                    _scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Error: ${state.message}')),
                    );
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Vendor Information
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.vendorInformation,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _vendorNameController,
                                  decoration: InputDecoration(
                                    labelText: AppStrings.vendorName,
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppStrings.pleaseEnterVendorName;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _vendorPhoneController,
                                  decoration: InputDecoration(
                                    labelText: AppStrings.vendorPhoneNumber,
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppStrings.pleaseEnterVendorPhone;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _chargeController,
                                  decoration: InputDecoration(
                                    labelText: AppStrings.charge,
                                    border: OutlineInputBorder(),
                                    prefixText: '\$',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppStrings.pleaseEnterChargeAmount;
                                    }
                                    if (double.tryParse(value) == null) {
                                      return AppStrings.pleaseEnterValidNumber;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Clients Section
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${AppStrings.clientsSectionTitle} (${_clients.length})',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _addClient,
                                      icon: const Icon(Icons.add),
                                      label: Text(AppStrings.addClient),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_clients.isEmpty)
                                  Center(
                                    child: Text(
                                      AppStrings.noClientsAddedYet,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _clients.length,
                                    itemBuilder: (context, index) {
                                      final client = _clients[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          leading: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: client.images.isNotEmpty ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.surface,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              client.images.isNotEmpty ? Icons.photo_library : Icons.person,
                                              color: client.images.isNotEmpty ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.onSurface,
                                              size: 20,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Expanded(child: Text(client.name)),
                                              if (client.images.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.secondaryContainer,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: Theme.of(context).colorScheme.onSecondary),
                                                  ),
                                                  child: Text(
                                                    '${client.images.length}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).colorScheme.onSecondary,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Phone: ${client.phoneNumber}'),
                                              Text('Address: ${client.address}'),
                                              Text('Pieces: ${client.piecesNumber}'),
                                              Text('Purchase: \$${client.purchasePrice}'),
                                              Text('Sale: \$${client.salePrice}'),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (_isPending)
                                                IconButton(
                                                  icon: Icon(Icons.edit, color: Colors.blue),
                                                  onPressed: () => _editClient(index),
                                                ),
                                              IconButton(
                                                icon:  Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                                onPressed: () => _removeClient(index),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Summary
                        if (_clients.isNotEmpty) ...[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.orderSummary,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSummaryRow('Total Purchase Price', _clients.fold(0.0, (sum, client) => sum + client.purchasePrice)),
                                  _buildSummaryRow('Total Sale Price', _clients.fold(0.0, (sum, client) => sum + client.salePrice)),
                                  _buildSummaryRow('Charge', double.tryParse(_chargeController.text) ?? 0.0),
                                  const Divider(),
                                  _buildSummaryRow('Net Profit', _calculateNetProfit(), isTotal: true),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Submit and Collect/Done Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: (!_isPending || _isSubmitting) ? null : _submitOrder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isSubmitting 
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                                      ),
                                    )
                                  : Text(_isEditing ? AppStrings.saveChanges : AppStrings.createOrder),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateNetProfit() {
    final totalSale = _clients.fold(0.0, (sum, client) => sum + client.salePrice);
    final totalPurchase = _clients.fold(0.0, (sum, client) => sum + client.purchasePrice);
    final charge = double.tryParse(_chargeController.text) ?? 0.0;
    return totalSale - totalPurchase - charge;
  }
}

class _AddClientDialog extends StatefulWidget {
  final Function(OrderClient) onClientAdded;
  final String? orderId;

  const _AddClientDialog({
    required this.onClientAdded,
    this.orderId,
  });

  @override
  State<_AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<_AddClientDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _depositController = TextEditingController();
  final _piecesController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final Uuid _uuid = const Uuid();
  List<String> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _piecesController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        final piecesNumber = int.tryParse(_piecesController.text) ?? 0;
        final maxImages = piecesNumber > 0 ? piecesNumber : 10; // Default to 10 if pieces not set
        final remainingSlots = maxImages - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).map((xFile) => File(xFile.path)).toList();
        
        // Show loading message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploading images to Supabase...'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        
        // Upload images to Supabase
        final supabase = Supabase.instance.client;
        List<String> uploadedUrls = [];
        
        // Generate a temporary order ID for new orders or use existing order ID
        final tempOrderId = widget.orderId ?? const Uuid().v4();
        final tempClientId = const Uuid().v4(); // Temporary client ID for new clients
        
        for (int i = 0; i < imagesToAdd.length; i++) {
          final file = imagesToAdd[i];
          final fileName = '${tempOrderId}_${tempClientId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final filePath = 'order_images/$fileName';
          
          try {
            // Upload file to Supabase Storage
            await supabase.storage
                .from('order-images')
                .upload(filePath, file);
            
            // Get public URL
            final imageUrl = supabase.storage
                .from('order-images')
                .getPublicUrl(filePath);
            
            uploadedUrls.add(imageUrl);
          } catch (uploadError) {
            print('❌ Error uploading image $i: $uploadError');
            
            // Show specific error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Upload failed: $uploadError'),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 3),
              ),
            );
            // Continue with other images even if one fails
          }
        }
        
        if (uploadedUrls.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(uploadedUrls);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${uploadedUrls.length} images uploaded successfully!'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload images. Please check Supabase bucket setup.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Test method to verify Supabase connection
  Future<void> _testSupabaseConnection() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Test 1: Check if bucket exists
      try {
        final files = await supabase.storage
            .from('order-images')
            .list();
        
        print('✅ Bucket exists. Files in bucket: ${files.length}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Supabase bucket working! Files: ${files.length}'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (bucketError) {
        print('❌ Bucket error: $bucketError');
        
        // Test 2: Check if Supabase connection works at all
        try {
          final response = await supabase.from('dummy_table').select('*').limit(1);
          print('✅ Supabase connection works, but bucket issue');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Supabase connected but bucket "order-images" not found. Please create it.'),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 5),
            ),
          );
        } catch (connectionError) {
          print('❌ Supabase connection error: $connectionError');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Supabase connection failed. Check URL and API key in main.dart'),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ General error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _addClient() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();
      final deposit = double.parse(_depositController.text);
      
      // Check if client already exists
      final existingClient = await context.read<GetClientByNameAndPhoneUseCase>()(name, phone);
      
      String clientId;
      if (existingClient != null) {
        // Reuse existing client's ID
        clientId = existingClient.id;
      } else {
        // Create new client ID
        clientId = _uuid.v4();
      }
      
      final client = OrderClientModel(
        id: clientId,
        deposit: deposit,
        name: name,
        phoneNumber: phone,
        address: address,
        piecesNumber: int.parse(_piecesController.text),
        purchasePrice: double.parse(_purchasePriceController.text),
        salePrice: double.parse(_salePriceController.text),
        createdAt: DateTime.now(),
        images: _selectedImages,
      );
      
      widget.onClientAdded(client);
      Navigator.of(context).pop();
    }    
  }

  @override
  Widget build(BuildContext context) {
    
    return AlertDialog(
      title: const Text('Add Client'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: AppStrings.name),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration:  InputDecoration(labelText: AppStrings.phone),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration:  InputDecoration(labelText: AppStrings.address),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _piecesController,
                decoration:  InputDecoration(labelText: AppStrings.piecesNumber),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter pieces number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _purchasePriceController,
                decoration:  InputDecoration(
                  labelText: AppStrings.purchasePrice,
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter purchase price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _salePriceController,
                decoration:  InputDecoration(
                  labelText:AppStrings.salePrice,
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter sale price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _depositController,
                decoration:  InputDecoration(
                  labelText: AppStrings.deposit,
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter deposit';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Image upload section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Images (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can add images for this client (up to pieces number)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedImages.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.onSecondary),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_selectedImages.length} images selected',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: Text(_selectedImages.isEmpty ? 'Add Images' : 'Add More Images'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _testSupabaseConnection,
                          icon: const Icon(Icons.bug_report),
                          tooltip: 'Test Supabase Connection',
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.errorContainer,
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:  Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _addClient,
          child:  Text(AppStrings.addClient),
        ),
      ],
    );
  }
}

class _EditClientDialog extends StatefulWidget {
  final OrderClient initialClient;
  final Function(OrderClient) onClientEdited;
  final String? orderId;

  const _EditClientDialog({
    required this.initialClient, 
    required this.onClientEdited,
    this.orderId,
  });

  @override
  State<_EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends State<_EditClientDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _piecesController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _depositController;
  List<String> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialClient.name);
    _phoneController = TextEditingController(text: widget.initialClient.phoneNumber);
    _addressController = TextEditingController(text: widget.initialClient.address);
    _piecesController = TextEditingController(text: widget.initialClient.piecesNumber.toString());
    _purchasePriceController = TextEditingController(text: widget.initialClient.purchasePrice.toString());
    _salePriceController = TextEditingController(text: widget.initialClient.salePrice.toString());
    _selectedImages = List.from(widget.initialClient.images);
    _depositController=TextEditingController(text: widget.initialClient.deposit.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _piecesController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  void _editClient() {
    if (_formKey.currentState!.validate()) {
      final editedClient = OrderClientModel(
        id: widget.initialClient.id,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        piecesNumber: int.parse(_piecesController.text),
        purchasePrice: double.parse(_purchasePriceController.text),
        salePrice: double.parse(_salePriceController.text),
        isReceived: widget.initialClient.isReceived,
        createdAt: widget.initialClient.createdAt,
        images: _selectedImages,
        deposit: double.parse(_depositController.text),
      );
      widget.onClientEdited(editedClient);
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        setState(() {
          // Show loading state
        });
        
        List<String> uploadedUrls = [];
        
        // Use proper order and client IDs for filenames
        final orderId = widget.orderId ?? const Uuid().v4();
        final clientId = widget.initialClient.id;
        
        for (int i = 0; i < images.length; i++) {
          try {
            final file = File(images[i].path);
            final fileName = '${orderId}_${clientId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
            final filePath = 'order_images/$fileName';
            
            final response = await Supabase.instance.client.storage
                .from('order-images')
                .upload(filePath, file);
            
            if (response.isNotEmpty) {
              final publicUrl = Supabase.instance.client.storage
                  .from('order-images')
                  .getPublicUrl(filePath);
              
              uploadedUrls.add(publicUrl);
            }
          } catch (e) {
            print('Error uploading image $i: $e');
            // Continue with other images even if one fails
          }
        }
        
        setState(() {
          _selectedImages.addAll(uploadedUrls);
        });
        
        if (uploadedUrls.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${uploadedUrls.length} images uploaded successfully'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _testSupabaseConnection() async {
    try {
      // Test bucket access
      final response = await Supabase.instance.client.storage
          .from('order-images')
          .list(path: 'temp_images');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Supabase connection successful! Found ${response.length} files in temp_images'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Supabase connection failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Client'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _piecesController,
                decoration: const InputDecoration(labelText: 'Pieces Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter pieces number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(
                  labelText: 'Purchase Price',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter purchase price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _salePriceController,
                decoration: const InputDecoration(
                  labelText: 'Sale Price',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter sale price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _depositController,
                decoration:  InputDecoration(
                  labelText: AppStrings.deposit,
                  prefixText: '\$',
                ),
              ),
              const SizedBox(height: 16),
              // Image section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedImages.isNotEmpty ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedImages.isNotEmpty ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.onError,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library,
                          color: _selectedImages.isNotEmpty ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.onError,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Images',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _selectedImages.isNotEmpty ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.onError,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_selectedImages.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedImages.isNotEmpty) ...[
                      Container(
                        height: 80,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _selectedImages.asMap().entries.map((entry) {
                              final index = entry.key;
                              final imageUrl = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 80,
                                            height: 80,
                                            color: Theme.of(context).colorScheme.surfaceVariant,
                                            child: const Icon(
                                              Icons.error_outline,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.error,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            color: Theme.of(context).colorScheme.onError,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImages,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            icon: const Icon(Icons.add_photo_alternate, size: 18),
                            label: Text(_selectedImages.isEmpty ? 'Add Images' : 'Add More Images'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _testSupabaseConnection(),
                          icon: const Icon(Icons.bug_report, size: 18),
                          tooltip: 'Test Supabase Connection',
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.errorContainer,
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Images will be uploaded to Supabase storage',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _editClient,
          child: const Text('Save'),
        ),
      ],
    );
  }
} 