// FILE: lib/presentation/order_collection/order_collection_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmange/core/constants/app_strings.dart';
import 'package:projectmange/domain/entities/order.dart';
import 'package:projectmange/domain/entities/vendor.dart';
import 'package:projectmange/domain/usecases/client_usecases.dart';
import 'package:projectmange/main.dart';
import 'package:projectmange/presentation/blocs/client/client_bloc.dart';
import 'package:projectmange/presentation/blocs/order/order_bloc.dart';
import 'package:projectmange/presentation/blocs/vendor/vendor_bloc.dart';
import 'package:projectmange/presentation/order_collection/sections/sections/dialogs/add_client_dialog.dart'
    show AddClientDialog;
import 'package:projectmange/presentation/order_collection/sections/sections/sections/client_list_section.dart';
import 'package:projectmange/presentation/pages/home_page.dart';
import 'package:projectmange/presentation/widgets/auth_wrapper.dart';
import 'package:uuid/uuid.dart';

import '../../../pages/subscription/subscription_page.dart';
import 'sections/client_section.dart';
import 'sections/order_summary_section.dart';
// Replace these imports with your actual project imports

import 'sections/vendor_section.dart';
import 'widgets/loading_button.dart';

class OrderCollectionPage extends StatefulWidget {
  final Order? orderToEdit;
  const OrderCollectionPage({super.key, this.orderToEdit});

  @override
  State<OrderCollectionPage> createState() => _OrderCollectionPageState();
}

class _OrderCollectionPageState extends State<OrderCollectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _chargeController = TextEditingController();

  final List<OrderClient> _clients = [];
  bool _isEditing = false;
  bool _isPending = true;
  bool _isSubmitting = false;
  String? _orderId;

  Vendor? _selectedVendor;

  late OrderBloc _orderBloc;
  late ScaffoldMessengerState _scaffoldMessenger;
  bool _dependenciesInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.orderToEdit != null) {
      _isEditing = true;
      _orderId = widget.orderToEdit!.id;
      _chargeController.text = widget.orderToEdit!.charge.toString();
      _clients.addAll(widget.orderToEdit!.clients);
      _isPending = widget.orderToEdit!.status == OrderStatus.pending;
      _selectedVendor = Vendor(
        id: widget.orderToEdit!.vendorId,
        name: widget.orderToEdit!.vendorName,
        phoneNumber: widget.orderToEdit!.vendorPhone,
        createdAt: DateTime.now(), // Not needed for editing logic
        updatedAt: DateTime.now(), // Not needed for editing logic
      );
    }

    // Fire load events if blocs are available
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<VendorBloc>().add(LoadVendors());
        context.read<ClientBloc>().add(LoadClients());
      });
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dependenciesInitialized) {
      _orderBloc = context.read<OrderBloc>();
      _scaffoldMessenger = ScaffoldMessenger.of(context);
      _dependenciesInitialized = true;
    }
  }

  @override
  void dispose() {
    _chargeController.dispose();
    super.dispose();
  }

  void _onVendorSelected(Vendor vendor) {
    setState(() {
      _selectedVendor = vendor;
    });
  }

  void _onClientAdded(OrderClient client) {
    setState(() => _clients.add(client));
  }

  void _onClientEdited(int index, OrderClient client) {
    setState(() => _clients[index] = client);
  }

  Future<void> _onClientDeleted(int index) async {
    if (!_isPending || _isSubmitting) return;
    final client = _clients[index];
    try {
      await context.read<DeleteClientUseCase>()(client.id);
      setState(() => _clients.removeAt(index));
      _scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(AppStrings.clientDeletedSuccessfully)),
      );
    } catch (e) {
      _scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error deleting client: $e')),
      );
    }
  }

  void _submitOrder() {
    if (_selectedVendor == null) {
      _scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(AppStrings.selectVendor)),
      );
      return;
    }

    if (_formKey.currentState != null &&
        _formKey.currentState!.validate() &&
        _clients.isNotEmpty &&
        !_isSubmitting) {
      setState(() => _isSubmitting = true);
      final charge = double.tryParse(_chargeController.text) ?? 0.0;

      if (_isEditing) {
        _orderBloc.add(
          UpdateOrder(
            id: _orderId!,
            vendorName: _selectedVendor!.name,
            vendorPhone: _selectedVendor!.phoneNumber,
            clients: _clients,
            charge: charge,
          ),
        );
      } else {
        final orderId = const Uuid().v4();
        _orderBloc.add(
          CreateOrder(
            vendorId: _selectedVendor!.id,
            vendorName: _selectedVendor!.name,
            vendorPhone: _selectedVendor!.phoneNumber,
            clients: _clients,
            charge: charge,
            orderDate: DateTime.now(),
          ),
        );

        for (final client in _clients) {
          if (client.images.isNotEmpty) {
            _orderBloc.add(
              UploadImagesForClient(
                orderId: orderId,
                clientId: client.id,
                imageUrls: client.images,
              ),
            );
          }
        }
      }
    } else if (_clients.isEmpty) {
      _scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseAddAtLeastOneClient)),
      );
    }
  }

  void _showSuccessDialogAndNavigateBack() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(AppStrings.great),
            content: Text(AppStrings.yourChangesUpdated),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted)
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: languageNotifier,
      builder: (context, locale, _) {
        AppStrings.setLocale(locale);

        return AuthWrapper(
          child: WillPopScope(
            onWillPop: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  _isEditing
                      ? AppStrings.editOrder
                      : AppStrings.collectOrderTitle,
                ),
              ),
              body: MultiBlocListener(
                listeners: [
                  BlocListener<OrderBloc, OrderState>(
                    listener: (context, state) {
                      if (state is OrderCreated || state is OrderUpdated) {
                        setState(() => _isSubmitting = false);

                        if (_isEditing) {
                          _showSuccessDialogAndNavigateBack();
                        } else {
                          _scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                AppStrings.orderCreatedSuccessfully,
                              ),
                            ),
                          );
                          Future.delayed(const Duration(milliseconds: 500), () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          });

                          _chargeController.clear();
                          setState(() {
                            _clients.clear();
                            _selectedVendor = null;
                          });
                        }
                      } else if (state is OrderError) {
                        setState(() => _isSubmitting = false);

                        if (state.message == AppStrings.freePlanLimitReached) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text(AppStrings.subscriptionRequired),
                                  content: Text(state.message),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(AppStrings.cancel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const SubscriptionPage(),
                                          ),
                                        );
                                      },
                                      child: Text(AppStrings.subscribeNow),
                                    ),
                                  ],
                                ),
                          );
                        } else {
                          _scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text('Error: ${state.message}')),
                          );
                        }
                      }
                    },
                  ),
                  BlocListener<VendorBloc, VendorState>(
                    listener: (context, vState) {
                      if (vState is VendorCreated) {
                        setState(() {
                          _selectedVendor = vState.vendor;
                        });
                      }
                    },
                  ),
                  BlocListener<ClientBloc, ClientState>(
                    listener: (context, cState) {
                      if (cState is ClientCreated) {
                        // Open add client dialog prefilled
                        showDialog(
                          context: context,
                          builder:
                              (context) => AddClientDialog(
                                clientId: cState.client.id,
                                initialName: cState.client.name,
                                initialPhone: cState.client.phoneNumber,
                                initialAddress: cState.client.address,
                                hideIdentityFields: true,
                                onClientAdded: _onClientAdded,
                              ),
                        );
                      }
                    },
                  ),
                ],
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        VendorSection(
                          selectedVendor: _selectedVendor,
                          onVendorSelected: _onVendorSelected,
                        ),
                        const SizedBox(height: 16),
                        ClientSection(onClientAdded: _onClientAdded),
                        const SizedBox(height: 16),
                        ClientListSection(
                          clients: _clients,
                          isPending: _isPending,
                          onEdit: _onClientEdited,
                          onDelete: _onClientDeleted,
                        ),
                        const SizedBox(height: 16),
                        if (_clients.isNotEmpty)
                          OrderSummarySection(
                            clients: _clients,
                            chargeController: _chargeController,
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: LoadingButton(
                                isLoading: _isSubmitting,
                                onPressed:
                                    (!_isPending || _isSubmitting)
                                        ? null
                                        : _submitOrder,
                                text:
                                    _isEditing
                                        ? AppStrings.saveChanges
                                        : AppStrings.createOrder,
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
}
