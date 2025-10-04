import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:projectmange/main.dart';

import '../../core/constants/app_strings.dart';
import '../../domain/entities/order.dart';
import '../blocs/order/order_bloc.dart';
import '../widgets/auth_wrapper.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Order> _filteredOrders = [];
  bool _isLoading = false;

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
      _filteredOrders = allOrders.where((order) {
        final orderDate = order.orderDate;
        if (_startDate != null && _endDate != null) {
          return orderDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                 orderDate.isBefore(_endDate!.add(const Duration(days: 1)));
        } else if (_startDate != null) {
          return orderDate.isAfter(_startDate!.subtract(const Duration(days: 1)));
        } else if (_endDate != null) {
          return orderDate.isBefore(_endDate!.add(const Duration(days: 1)));
        }
        return true;
      }).toList();
    }
  }

  double get _totalPurchasePrice {
    return _filteredOrders.fold(0, (sum, order) => sum + order.totalPurchasePrice);
  }

  double get _totalSalesPrice {
    return _filteredOrders.fold(0, (sum, order) => sum + order.totalSalesPrice);
  }

  double get _totalCharges {
    return _filteredOrders.fold(0, (sum, order) => sum + order.charge);
  }

  double get _netProfit {
    return _totalSalesPrice - _totalPurchasePrice - _totalCharges;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      
      // Reload orders to apply filter
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
    return ValueListenableBuilder<Locale>(
      valueListenable: languageNotifier,
      builder: (context, locale, _) {
        // Update AppStrings locale
        AppStrings.setLocale(locale);
        
        return AuthWrapper(
          child: Scaffold(
            appBar: AppBar(
              title: Text(AppStrings.viewBills),
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
            ),
            body: BlocConsumer<OrderBloc, OrderState>(
              listener: (context, state) {
                if (state is OrdersLoaded) {
                  final completedOrders = state.orders.where((order) => order.status == OrderStatus.complete).toList();
                  _filterOrdersByDateRange(completedOrders);
                  setState(() {
                    _isLoading = false;
                  });
                } else if (state is OrderLoading) {
                  setState(() {
                    _isLoading = true;
                  });
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Date Range Filter Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.dateRangeFilter,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child:                                   Text(
                                        _startDate != null && _endDate != null
                                            ? '${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                                            : AppStrings.allCompletedOrders,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _selectDateRange,
                                    icon: const Icon(Icons.date_range),
                                    label: Text(AppStrings.selectRange),
                                  ),
                                  if (_startDate != null || _endDate != null)
                                    TextButton.icon(
                                      onPressed: _clearDateFilter,
                                      icon: const Icon(Icons.clear),
                                      label: Text(AppStrings.cancel),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Financial Summary Cards
                      if (_isLoading)
                        Container(
                          height: 200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else ...[
                        // Total Purchase Price
                        _buildSummaryCard(
                          AppStrings.totalPurchasePrice,
                          _totalPurchasePrice,
                          Icons.shopping_bag,
                          Colors.red,
                          'Total amount spent on purchases',
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Total Sales Price
                        _buildSummaryCard(
                          AppStrings.totalSalesPrice,
                          _totalSalesPrice,
                          Icons.attach_money,
                          Colors.green,
                          'Total revenue from sales',
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Total Charges
                        _buildSummaryCard(
                          AppStrings.totalCharges,
                          _totalCharges,
                          Icons.receipt,
                          Colors.orange,
                          'Total charges/fees',
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Net Profit
                        _buildSummaryCard(
                          AppStrings.netProfit,
                          _netProfit,
                          Icons.trending_up,
                          _netProfit >= 0 ? Colors.green : Colors.red,
                          'Total profit after all expenses',
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Orders Count
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.list_alt,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.completedOrders,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${_filteredOrders.length} ${AppStrings.orders}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Orders List
                        if (_filteredOrders.isEmpty)
                          Container(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppStrings.noCompletedOrdersFound,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppStrings.completeSomeOrders,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.completedOrders,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 200, // Fixed height for horizontal scroll
                                child: ListView.builder(
                                  
                                  itemCount: _filteredOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = _filteredOrders[index];
                                    return SizedBox(
                                      width: 300, // Fixed width for each card
                                      child: Card(
                                        margin: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: ListTile(
                                          title: Text(
                                            '${AppStrings.orderNumber}${order.id.substring(0, 8)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${AppStrings.vendor}: ${order.vendorName}'),
                                              Text('${AppStrings.date}: ${DateFormat('MMM dd, yyyy').format(order.orderDate)}'),
                                              Text('${AppStrings.clients}: ${order.clients.length}'),
                                            ],
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${AppStrings.profit}: \$${order.netProfit.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: order.netProfit >= 0 ? Colors.green : Colors.red,
                                                ),
                                              ),
                                              Text(
                                                '${AppStrings.sales}: \$${order.totalSalesPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon, Color color, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 