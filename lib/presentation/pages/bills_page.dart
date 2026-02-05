import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme_helper.dart';
import '../../domain/entities/order.dart';
import '../blocs/order/order_bloc.dart';
import '../widgets/auth_wrapper.dart';
import 'order_details_page.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Order> _filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedOrders();
  }

  void _loadCompletedOrders() {
    context.read<OrderBloc>().add(LoadOrdersByStatus(OrderStatus.complete));
  }

  void _filterOrdersByDateRange(List<Order> allOrders) {
    if (_startDate == null && _endDate == null) {
      _filteredOrders = allOrders;
    } else {
      _filteredOrders =
          allOrders.where((order) {
            final orderDate = order.orderDate;
            if (_startDate != null && _endDate != null) {
              return orderDate.isAfter(
                    _startDate!.subtract(const Duration(days: 1)),
                  ) &&
                  orderDate.isBefore(_endDate!.add(const Duration(days: 1)));
            } else if (_startDate != null) {
              return orderDate.isAfter(
                _startDate!.subtract(const Duration(days: 1)),
              );
            } else if (_endDate != null) {
              return orderDate.isBefore(_endDate!.add(const Duration(days: 1)));
            }
            return true;
          }).toList();
    }
  }

  double get _totalPurchasePrice =>
      _filteredOrders.fold(0, (sum, order) => sum + order.totalPurchasePrice);
  double get _totalSalesPrice =>
      _filteredOrders.fold(0, (sum, order) => sum + order.totalSalesPrice);
  double get _totalCharges =>
      _filteredOrders.fold(0, (sum, order) => sum + order.charge);
  double get _netProfit =>
      _totalSalesPrice - _totalPurchasePrice - _totalCharges;

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadCompletedOrders();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadCompletedOrders();
  }

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.viewBills),
          actions: [
            if (_startDate != null || _endDate != null)
              IconButton(
                icon: const Icon(Icons.filter_list_off),
                onPressed: _clearDateFilter,
              ),
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: _selectDateRange,
            ),
          ],
        ),
        body: Container(
          decoration: AppThemeHelper.getBackgroundGradientDecoration(context),
          child: BlocListener<OrderBloc, OrderState>(
            listener: (context, state) {
              if (state is OrdersLoaded) {
                final completedOrders =
                    state.orders
                        .where((order) => order.status == OrderStatus.complete)
                        .toList();
                setState(() {
                  _filterOrdersByDateRange(completedOrders);
                });
              } else if (state is OrderLoading) {
                setState(() {
                  _filteredOrders = [];
                });
              }
            },
            child: BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                if (state is OrderLoading && _filteredOrders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Filter Status Card
                    if (_startDate != null && _endDate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: AppThemeHelper.getCardDecoration(
                            context,
                          ).copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.date_range, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _clearDateFilter,
                                child: const Icon(Icons.close, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Summary Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildSummaryStat(
                          AppStrings.totalPurchase,
                          _totalPurchasePrice,
                          Icons.shopping_bag,
                          Colors.red,
                        ),
                        _buildSummaryStat(
                          AppStrings.totalSale,
                          _totalSalesPrice,
                          Icons.attach_money,
                          Colors.green,
                        ),
                        _buildSummaryStat(
                          AppStrings.totalCharges,
                          _totalCharges,
                          Icons.receipt,
                          Colors.orange,
                        ),
                        _buildSummaryStat(
                          AppStrings.netProfit,
                          _netProfit,
                          Icons.trending_up,
                          _netProfit >= 0 ? Colors.green : Colors.red,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Text(
                      '${AppStrings.completedOrders} (${_filteredOrders.length})',
                      style: AppThemeHelper.getHeadlineStyle(context),
                    ),
                    const SizedBox(height: 12),

                    if (_filteredOrders.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.noCompletedOrdersFound,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._filteredOrders.map(
                        (order) => _buildOrderBillCard(order),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStat(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppThemeHelper.getCardDecoration(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBillCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppThemeHelper.getCardDecoration(context),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          '${order.vendorName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(DateFormat('MMM dd, yyyy').format(order.orderDate)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${order.netProfit.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: order.netProfit >= 0 ? Colors.green : Colors.red,
              ),
            ),
            Text(
              '${order.clients.length} ${AppStrings.clients}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(order: order),
            ),
          );
        },
      ),
    );
  }
}
