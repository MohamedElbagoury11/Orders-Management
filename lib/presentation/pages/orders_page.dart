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
import '../widgets/auth_wrapper.dart';
import 'order_collection_page.dart';

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
            appBar: AppBar(
              title: Text(AppStrings.orders),
            ),
            body: Container(
              decoration: AppThemeHelper.getBackgroundGradientDecoration(context),
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
                            items: OrderStatus.values.map((status) {
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
                                context.read<OrderBloc>().add(LoadOrdersByStatus(status));
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
                          context.read<OrderBloc>().add(LoadOrdersByStatus(_selectedStatus));
                        }
                      },
                      child: BlocBuilder<OrderBloc, OrderState>(
                        builder: (context, state) {
                          if (state is OrderLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is OrdersLoaded) {
                            if (state.orders.isEmpty) {
                              return Center(
                                child: Container(
                                  padding: AppThemeHelper.getCardPadding(context),
                                  decoration: AppThemeHelper.getCardDecoration(context),
                                  margin: AppThemeHelper.getStandardPadding(context),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: AppThemeHelper.smallSpacing),
                                      Text(
                                        AppStrings.noOrdersFound,
                                        style: AppThemeHelper.getHeadlineStyle(context),
                                      ),
                                      const SizedBox(height: AppThemeHelper.tinySpacing),
                                      Text(
                                        'No orders found for the selected status',
                                        style: AppThemeHelper.getBodyStyle(context),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            return ListView.builder(
                              padding: AppThemeHelper.getStandardPadding(context),
                              itemCount: state.orders.length,
                              itemBuilder: (context, index) {
                                final order = state.orders[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: AppThemeHelper.smallSpacing),
                                  decoration: AppThemeHelper.getCardDecoration(context),
                                  child: ListTile(
                                    contentPadding: AppThemeHelper.getCardPadding(context),
                                    title: Text(
                                      order.vendorName,
                                      style: AppThemeHelper.getTitleStyle(context),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: AppThemeHelper.tinySpacing),
                                        Text('${AppStrings.phone}: ${order.vendorPhone}'),
                                        Text('${AppStrings.date}: ${DateFormat('MMM dd, yyyy').format(order.orderDate)}'),
                                        Text('${AppStrings.clients}: ${order.clients.length}'),
                                        Text('${AppStrings.status}: ${_getStatusText(order.status)}'),
                                        Text('${AppStrings.netProfit}: \$${order.netProfit.toStringAsFixed(2)}'),
                                        const SizedBox(height: AppThemeHelper.tinySpacing),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildStatusChip(order.status),
                                            if (order.status == OrderStatus.pending) ...[
                                              const SizedBox(width: AppThemeHelper.tinySpacing),
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
                                                      builder: (context) => OrderCollectionPage1(orderToEdit: order),
                                                    ),
                                                  );
                                                  // Refresh after editing
                                                  context.read<OrderBloc>().add(LoadOrdersByStatus(_selectedStatus));
                                                },
                                              ),
                                            ],
                                            const SizedBox(width: AppThemeHelper.tinySpacing),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              tooltip: AppStrings.deleteOrder,
                                              onPressed: () => _showDeleteConfirmation(order),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () => _showOrderDetails(order),
                                  ),
                                );
                              },
                            );
                          } else if (state is OrderError) {
                            return Center(
                              child: Container(
                                padding: AppThemeHelper.getCardPadding(context),
                                decoration: AppThemeHelper.getCardDecoration(context),
                                margin: AppThemeHelper.getStandardPadding(context),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.red[400],
                                    ),
                                    const SizedBox(height: AppThemeHelper.smallSpacing),
                                    Text(
                                      AppStrings.errorOccurred,
                                      style: AppThemeHelper.getHeadlineStyle(context),
                                    ),
                                    const SizedBox(height: AppThemeHelper.tinySpacing),
                                    Text(
                                      state.message,
                                      style: AppThemeHelper.getBodyStyle(context),
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

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.working:
        color = Colors.blue;
        break;
      case OrderStatus.complete:
        color = Colors.green;
        break;
    }
    
    return Chip(
      label: Text(
        _getStatusText(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  void _showCollectConfirmation(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.collectOrder),
        content: Text('${AppStrings.areYouSureCollect} ${order.vendorName} as "Working"?'),
        actions: [
                      TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<OrderBloc>().add(UpdateOrder(
                  id: order.id,
                  status: OrderStatus.working,
                ));
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
      builder: (context) => AlertDialog(
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
            Text('• Delete vendor "${order.vendorName}" if no other orders exist'),
            Text('• Delete all clients in this order if no other orders exist'),
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
      final vendorOrders = allOrders.where((o) => o.vendorName == order.vendorName).toList();
      
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
        final clientOrders = allOrders.where((o) => 
          o.clients.any((c) => c.name == client.name && c.phoneNumber == client.phoneNumber)
        ).toList();
        
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

  void _showOrderDetails(Order order) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isPositiveProfit = order.netProfit >= 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.receipt_long,
              color: Theme.of(context).colorScheme.primary,
              size: isTablet ? 28 : 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.orderDetails,
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Order Status Chip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(order.status).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(order.status),
                      color: _getStatusColor(order.status),
                      size: isTablet ? 20 : 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(order.status),
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Vendor Information
              _buildDetailSection(
                AppStrings.vendorInformation,
                [
                  _buildDetailItem(AppStrings.name, order.vendorName, Icons.business),
                  _buildDetailItem(AppStrings.phone, order.vendorPhone, Icons.phone),
                  _buildDetailItem(AppStrings.orderDate, DateFormat('MMM dd, yyyy').format(order.orderDate), Icons.calendar_today),
                ],
              ),
              const Divider(height: 24),
              
              // Financial Summary
              _buildDetailSection(
                AppStrings.financialSummary,
                [
                  _buildDetailItem(AppStrings.charge, '\$${order.charge.toStringAsFixed(2)}', Icons.account_balance_wallet),
                  _buildDetailItem(AppStrings.totalPurchase, '\$${order.totalPurchasePrice.toStringAsFixed(2)}', Icons.shopping_cart),
                  _buildDetailItem(AppStrings.totalSale, '\$${order.totalSalesPrice.toStringAsFixed(2)}', Icons.attach_money),
                ],
              ),
              
              // Net Profit Highlight
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPositiveProfit ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPositiveProfit ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositiveProfit ? Icons.trending_up : Icons.trending_down,
                      color: isPositiveProfit ? Colors.green.shade600 : Colors.red.shade600,
                      size: isTablet ? 20 : 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${AppStrings.netProfit}: \$${order.netProfit.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: isPositiveProfit ? Colors.green.shade600 : Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              
              // Clients Section
              _buildDetailSection(
                '${AppStrings.clients} (${order.clients.length})',
                order.clients.map((client) => _buildClientItem(client, isTablet)).toList(),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(AppStrings.close),
              ),
           Spacer(),
                                          order.status == OrderStatus.pending
                                              ? ElevatedButton(
                                                  onPressed: () { context.read<OrderBloc>().add(UpdateOrder(
                  id: order.id,
                  status: OrderStatus.working,
                ));
                                                  Navigator.pop(context);},
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                  ),
                                                  child: Text(AppStrings.collect),
                                                )
                                              : const SizedBox.shrink(),
               
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientItem(OrderClient client, bool isTablet) {
    final profit = client.salePrice - client.purchasePrice;
    final isPositiveProfit = profit >= 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  client.name,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (client.isReceived)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                   AppStrings.received,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.phone,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                client.phoneNumber,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
               // _buildClientDetail(${AppStrings.piecesNumber}, '${client.piecesNumber}', Icons.inventory),
                const SizedBox(width: 16),
                _buildClientDetail('Purchase', '\$${client.purchasePrice}', Icons.shopping_cart),
                const SizedBox(width: 16),
                _buildClientDetail('Sale', '\$${client.salePrice}', Icons.attach_money),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPositiveProfit ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isPositiveProfit ? Colors.green.shade200 : Colors.red.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositiveProfit ? Icons.trending_up : Icons.trending_down,
                  size: 12,
                  color: isPositiveProfit ? Colors.green.shade600 : Colors.red.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Profit: \$${profit.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositiveProfit ? Colors.green.shade600 : Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDetail(String label, String value, IconData icon, ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
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