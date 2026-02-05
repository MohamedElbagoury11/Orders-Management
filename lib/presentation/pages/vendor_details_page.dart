import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme_helper.dart';
import '../../domain/entities/order.dart';
import '../blocs/order/order_bloc.dart';
import '../widgets/auth_wrapper.dart';
import 'order_details_page.dart';
import 'vendor_view_model.dart';

class VendorDetailsPage extends StatefulWidget {
  final VendorInfo vendor;

  const VendorDetailsPage({super.key, required this.vendor});

  @override
  State<VendorDetailsPage> createState() => _VendorDetailsPageState();
}

class _VendorDetailsPageState extends State<VendorDetailsPage> {
  late VendorInfo _vendor;

  @override
  void initState() {
    super.initState();
    _vendor = widget.vendor;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrdersLoaded) {
          // Update local vendor info if orders were updated
          setState(() {
            final updatedOrders =
                state.orders
                    .where(
                      (o) =>
                          o.vendorName == _vendor.name &&
                          o.vendorPhone == _vendor.phone,
                    )
                    .toList();
            _vendor = VendorInfo(
              name: _vendor.name,
              phone: _vendor.phone,
              orders: updatedOrders,
            );
          });
        }
      },
      child: AuthWrapper(
        child: Scaffold(
          appBar: AppBar(title: Text(_vendor.name)),
          body: Container(
            decoration: AppThemeHelper.getBackgroundGradientDecoration(context),
            child: Column(
              children: [
                // Vendor Header Stats
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          AppStrings.totalOrders,
                          '${_vendor.orders.length}',
                          Icons.shopping_bag,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          AppStrings.netProfit,
                          'EGP ${_vendor.totalNetProfit.toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Orders List
                Expanded(
                  child:
                      _vendor.orders.isEmpty
                          ? Center(child: Text(AppStrings.noOrdersFound))
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _vendor.orders.length,
                            itemBuilder: (context, index) {
                              final order = _vendor.orders[index];
                              return _buildOrderCard(order);
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppThemeHelper.getCardDecoration(context),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppThemeHelper.getCardDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final changed = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage(order: order),
              ),
            );
            if (changed == true) {
              context.read<OrderBloc>().add(LoadOrders());
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(order.status),
                    color: _getStatusColor(order.status),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(order.orderDate),
                        style: AppThemeHelper.getTitleStyle(context),
                      ),
                      Text(
                        '${order.clients.length} ${AppStrings.clients} • EGP ${order.netProfit.toStringAsFixed(2)} profit',
                        style: AppThemeHelper.getBodyStyle(context),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
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
