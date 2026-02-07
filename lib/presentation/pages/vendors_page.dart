import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/config/cache_config.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/cache_service.dart';
import '../../core/theme/app_theme_helper.dart';
import '../../domain/entities/order.dart';
import '../blocs/order/order_bloc.dart';
import '../widgets/auth_wrapper.dart';
import 'vendor_details_page.dart';
import 'vendor_view_model.dart';

class VendorsPage extends StatefulWidget {
  const VendorsPage({super.key});

  @override
  State<VendorsPage> createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<VendorInfo> _allVendors = [];
  List<VendorInfo> _filteredVendors = [];

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadOrders());
    _searchController.addListener(_filterVendors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterVendors() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredVendors = _allVendors;
      } else {
        _filteredVendors =
            _allVendors
                .where(
                  (v) =>
                      v.name.toLowerCase().contains(query) ||
                      v.phone.contains(query),
                )
                .toList();
      }
    });
  }

  Future<void> _refreshData() async {
    // Clear cache and reload
    await CacheService.clearCache(CacheConfig.ordersCacheKey);
    print('🔄 Refreshing vendors data...');

    if (mounted) {
      context.read<OrderBloc>().add(LoadOrders());
    }
  }

  List<VendorInfo> _getVendorsFromOrders(List<Order> orders) {
    final Map<String, List<Order>> vendorsMap = {};
    for (final order in orders) {
      final key = '${order.vendorName}_${order.vendorPhone}';
      vendorsMap.putIfAbsent(key, () => []).add(order);
    }

    return vendorsMap.entries.map((e) {
        final firstOrder = e.value.first;
        return VendorInfo(
          name: firstOrder.vendorName,
          phone: firstOrder.vendorPhone,
          orders: e.value,
        );
      }).toList()
      ..sort((a, b) => b.totalNetProfit.compareTo(a.totalNetProfit));
  }

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.vendors),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh data',
              onPressed: _refreshData,
            ),
          ],
        ),
        body: Container(
          decoration: AppThemeHelper.getBackgroundGradientDecoration(context),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchVendors,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Vendor List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: BlocListener<OrderBloc, OrderState>(
                    listener: (context, state) {
                      if (state is OrdersLoaded) {
                        _allVendors = _getVendorsFromOrders(state.orders);
                        _filterVendors(); // Now safe outside build phase
                      }
                    },
                    child: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        if (state is OrderLoading && _allVendors.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is OrdersLoaded ||
                            _allVendors.isNotEmpty) {
                          if (_filteredVendors.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.business_outlined,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppStrings.noVendorsFound,
                                    style: AppThemeHelper.getHeadlineStyle(
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredVendors.length,
                            itemBuilder: (context, index) {
                              final vendor = _filteredVendors[index];
                              return _buildVendorCard(vendor);
                            },
                          );
                        } else if (state is OrderError) {
                          return Center(child: Text('Error: ${state.message}'));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVendorCard(VendorInfo vendor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppThemeHelper.getCardDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorDetailsPage(vendor: vendor),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient:
                        AppThemeHelper.getCustomTheme(context).primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name,
                        style: AppThemeHelper.getTitleStyle(context),
                      ),
                      Text(
                        vendor.phone,
                        style: AppThemeHelper.getBodyStyle(context),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'EGP ${vendor.totalNetProfit.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '${vendor.orders.length} ${AppStrings.orders}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
