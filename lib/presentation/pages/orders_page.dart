import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:projectmange/main.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme_helper.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/client_usecases.dart';
import '../../domain/usecases/order_usecases.dart';
import '../../domain/usecases/vendor_usecases.dart';
import '../blocs/order/order_bloc.dart';
import '../order_collection/sections/sections/order_collection_page.dart';
import '../widgets/auth_wrapper.dart';
import 'order_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  OrderStatus _selectedStatus = OrderStatus.pending;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      context.read<OrderBloc>().add(LoadOrdersByStatus(_selectedStatus));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: languageNotifier,
      builder: (context, locale, _) {
        // Update AppStrings locale
        AppStrings.setLocale(locale);

        return AuthWrapper(
          child: Scaffold(
            appBar: AppBar(title: Text(AppStrings.orders)),
            body: Container(
              decoration: AppThemeHelper.getBackgroundGradientDecoration(
                context,
              ),
              child: Column(
                children: [
                  // Status Filter
                  Container(
                    padding: AppThemeHelper.getCardPadding(context),
                    decoration: AppThemeHelper.getCardDecoration(context),
                    margin: AppThemeHelper.getStandardPadding(context),
                    child: Row(
                      children: [
                        Text(
                          AppStrings.filterByStatus,
                          style: AppThemeHelper.getTitleStyle(context),
                        ),
                        const SizedBox(width: AppThemeHelper.smallSpacing),
                        Expanded(
                          child: DropdownButton<OrderStatus>(
                            value: _selectedStatus,
                            isExpanded: true,
                            items:
                                OrderStatus.values.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(_getStatusText(status)),
                                  );
                                }).toList(),
                            onChanged: (status) {
                              if (status != null) {
                                setState(() {
                                  _selectedStatus = status;
                                });
                                context.read<OrderBloc>().add(
                                  LoadOrdersByStatus(status),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Orders List
                  Expanded(
                    child: BlocListener<OrderBloc, OrderState>(
                      listener: (context, state) {
                        if (state is OrderUpdated) {
                          // Refresh the orders list when an order is updated
                          context.read<OrderBloc>().add(
                            LoadOrdersByStatus(_selectedStatus),
                          );
                        }
                      },
                      child: BlocBuilder<OrderBloc, OrderState>(
                        builder: (context, state) {
                          if (state is OrderLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is OrdersLoaded) {
                            if (state.orders.isEmpty) {
                              return Center(
                                child: Container(
                                  padding: AppThemeHelper.getCardPadding(
                                    context,
                                  ),
                                  decoration: AppThemeHelper.getCardDecoration(
                                    context,
                                  ),
                                  margin: AppThemeHelper.getStandardPadding(
                                    context,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(
                                        height: AppThemeHelper.smallSpacing,
                                      ),
                                      Text(
                                        AppStrings.noOrdersFound,
                                        style: AppThemeHelper.getHeadlineStyle(
                                          context,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppThemeHelper.tinySpacing,
                                      ),
                                      Text(
                                        'No orders found for the selected status',
                                        style: AppThemeHelper.getBodyStyle(
                                          context,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: AppThemeHelper.getStandardPadding(
                                context,
                              ),
                              itemCount: state.orders.length,
                              itemBuilder: (context, index) {
                                final order = state.orders[index];
                                return Container(
                                  margin: const EdgeInsets.only(
                                    bottom: AppThemeHelper.smallSpacing,
                                  ),
                                  decoration: AppThemeHelper.getCardDecoration(
                                    context,
                                  ),
                                  child: ListTile(
                                    contentPadding:
                                        AppThemeHelper.getCardPadding(context),
                                    title: Text(
                                      order.vendorName,
                                      style: AppThemeHelper.getTitleStyle(
                                        context,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: AppThemeHelper.tinySpacing,
                                        ),
                                        Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          '${AppStrings.phone}: ${order.vendorPhone}',
                                        ),
                                        Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          '${AppStrings.date}: ${DateFormat('MMM dd, yyyy').format(order.orderDate)}',
                                        ),
                                        Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          '${AppStrings.clients}: ${order.clients.length}',
                                        ),
                                        Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          '${AppStrings.status}: ${_getStatusText(order.status)}',
                                        ),
                                        Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          ' ${AppStrings.netProfit}: ${order.netProfit.toStringAsFixed(2)} EGP',
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppThemeHelper.tinySpacing,
                                        ),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildStatusChip(
                                              order.status,
                                              onTap:
                                                  order.status ==
                                                          OrderStatus.pending
                                                      ? () =>
                                                          _showCollectConfirmation(
                                                            order,
                                                          )
                                                      : null,
                                            ),
                                            if (order.status ==
                                                OrderStatus.pending) ...[
                                              const SizedBox(
                                                width:
                                                    AppThemeHelper.tinySpacing,
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.orange,
                                                ),
                                                tooltip: AppStrings.edit,
                                                onPressed: () async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              OrderCollectionPage(
                                                                orderToEdit:
                                                                    order,
                                                              ),
                                                    ),
                                                  );
                                                  // Refresh after editing
                                                  context.read<OrderBloc>().add(
                                                    LoadOrdersByStatus(
                                                      _selectedStatus,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                            const SizedBox(
                                              width: AppThemeHelper.tinySpacing,
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              tooltip: AppStrings.deleteOrder,
                                              onPressed:
                                                  () => _showDeleteConfirmation(
                                                    order,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      final changed = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => OrderDetailsPage(
                                                order: order,
                                              ),
                                        ),
                                      );
                                      if (changed == true) {
                                        context.read<OrderBloc>().add(
                                          LoadOrdersByStatus(_selectedStatus),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            );
                          } else if (state is OrderError) {
                            return Center(
                              child: Container(
                                padding: AppThemeHelper.getCardPadding(context),
                                decoration: AppThemeHelper.getCardDecoration(
                                  context,
                                ),
                                margin: AppThemeHelper.getStandardPadding(
                                  context,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.red[400],
                                    ),
                                    const SizedBox(
                                      height: AppThemeHelper.smallSpacing,
                                    ),
                                    Text(
                                      AppStrings.errorOccurred,
                                      style: AppThemeHelper.getHeadlineStyle(
                                        context,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppThemeHelper.tinySpacing,
                                    ),
                                    Text(
                                      state.message,
                                      style: AppThemeHelper.getBodyStyle(
                                        context,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(OrderStatus status, {VoidCallback? onTap}) {
    if (onTap != null) {
      return ActionChip(
        avatar: Icon(_getStatusIcon(status), size: 14, color: Colors.white),
        label: Text(
          _getStatusText(status),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: _getStatusColor(status),
        onPressed: onTap,
      );
    }
    return Chip(
      avatar: Icon(_getStatusIcon(status), size: 14, color: Colors.white),
      label: Text(
        _getStatusText(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: _getStatusColor(status),
    );
  }

  void _showCollectConfirmation(Order order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppStrings.collectOrder),
            content: Text(
              '${AppStrings.areYouSureCollect} ${order.vendorName} as "Working"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<OrderBloc>().add(
                    UpdateOrder(id: order.id, status: OrderStatus.working),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(AppStrings.collect),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(Order order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text('Delete Order'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to delete this order?'),
                const SizedBox(height: 8),
                Text(
                  'This will also:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('• Delete the order'),
                Text(
                  '• Delete vendor "${order.vendorName}" if no other orders exist',
                ),
                Text(
                  '• Delete all clients in this order if no other orders exist',
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'This action cannot be undone!',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteOrder(order);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _deleteOrder(Order order) async {
    try {
      // Delete the order
      context.read<OrderBloc>().add(DeleteOrder(order.id));

      // Check if vendor has other orders
      final allOrders = await context.read<GetOrdersUseCase>()();
      final vendorOrders =
          allOrders.where((o) => o.vendorName == order.vendorName).toList();

      // If this was the only order for this vendor, delete the vendor
      if (vendorOrders.length == 1) {
        try {
          await context.read<DeleteVendorUseCase>()(order.vendorId);
        } catch (e) {
          print('Error deleting vendor: $e');
        }
      }

      // Check if clients have other orders
      for (final client in order.clients) {
        final clientOrders =
            allOrders
                .where(
                  (o) => o.clients.any(
                    (c) =>
                        c.name == client.name &&
                        c.phoneNumber == client.phoneNumber,
                  ),
                )
                .toList();

        // If this was the only order for this client, delete the client
        if (clientOrders.length == 1) {
          try {
            await context.read<DeleteClientUseCase>()(client.id);
          } catch (e) {
            print('Error deleting client: $e');
          }
        }
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppStrings.pending;
      case OrderStatus.working:
        return AppStrings.working;
      case OrderStatus.complete:
        return AppStrings.complete;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.working:
        return Colors.blue;
      case OrderStatus.complete:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.working:
        return Icons.work;
      case OrderStatus.complete:
        return Icons.check_circle;
    }
  }
}
