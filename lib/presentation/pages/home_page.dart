import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:projectmange/core/utils/whatsapp.dart';
import 'package:projectmange/main.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme_helper.dart';
import '../../core/utils/subscription_helper.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/user.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/client/client_bloc.dart';
import '../blocs/order/order_bloc.dart';
import '../blocs/vendor/vendor_bloc.dart';
import '../order_collection/sections/sections/order_collection_page.dart';
import '../widgets/auth_wrapper.dart';
import './subscription/subscription_page.dart';
import './vendors_page.dart';
import 'bills_page.dart';
import 'clients_page.dart';
import 'order_details_page.dart';
import 'orders_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data for stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderBloc>().add(LoadOrders());
      context.read<ClientBloc>().add(LoadClients());
      context.read<VendorBloc>().add(LoadVendors());
    });
  }

  final List<Widget> _pages = [
    const _DashboardView(),
    const OrdersPage(),
    const ClientsPage(),
    const VendorsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final bool canCreateOrder =
              state is Authenticated &&
              SubscriptionHelper.canCreateOrder(state.user);

          return Scaffold(
            drawer: _buildDrawer(context),
            body: Container(
              decoration: AppThemeHelper.getBackgroundGradientDecoration(
                context,
              ),
              child: IndexedStack(index: _currentIndex, children: _pages),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (!canCreateOrder) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Free plan limit reached. Please subscribe to add new orders.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPage(),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderCollectionPage(),
                  ),
                ).then((_) {
                  // Refresh data after adding order
                  context.read<OrderBloc>().add(LoadOrders());
                  context.read<ClientBloc>().add(LoadClients());
                  context.read<VendorBloc>().add(LoadVendors());
                  // Refresh user data to update order count in drawer
                  context.read<AuthBloc>().add(RefreshUserEvent());
                });
              },
              backgroundColor:
                  canCreateOrder
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
              child: const Icon(Icons.add_shopping_cart, color: Colors.white),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: AppThemeHelper.getPrimaryGradientDecoration(context),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_checkout,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(state.user.name ?? 'User'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.user.email,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              SubscriptionHelper.isPaidPlan(state.user)
                                  ? Colors.green.withOpacity(0.1)
                                  : (SubscriptionHelper.hasReachedFreeLimit(
                                        state.user,
                                      )
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          SubscriptionHelper.getSubscriptionStatus(state.user),
                          style: TextStyle(
                            color:
                                SubscriptionHelper.isPaidPlan(state.user)
                                    ? Colors.green
                                    : (SubscriptionHelper.hasReachedFreeLimit(
                                          state.user,
                                        )
                                        ? Colors.red
                                        : Colors.orange),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: Text(AppStrings.dashboard),
            selected: _currentIndex == 0,
            onTap: () {
              setState(() => _currentIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: Text(AppStrings.viewBills),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BillsPage()),
              );
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated &&
                  state.user.subscriptionType == 'free') {
                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.orange),
                  title: Text(
                    AppStrings.subscribeNow,
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionPage(),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Divider(),
          // Theme Switcher Tile
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return ListTile(
                leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                title: Text(
                  isDark ? AppStrings.lightMode : AppStrings.darkMode,
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) => themeNotifier.toggleTheme(),
                ),
              );
            },
          ),
          // Language Switcher Tile
          ValueListenableBuilder<Locale>(
            valueListenable: languageNotifier,
            builder: (context, locale, _) {
              final isArabic = locale.languageCode == 'ar';
              return ListTile(
                leading: const Icon(Icons.language),
                title: Text(isArabic ? 'العربية' : 'English'),
                trailing: TextButton(
                  onPressed: () {
                    if (isArabic) {
                      languageNotifier.setLanguage(const Locale('en', 'US'));
                    } else {
                      languageNotifier.setLanguage(const Locale('ar', 'SA'));
                    }
                  },
                  child: Text(isArabic ? 'English' : 'العربية'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_center_rounded),
            title: Text(AppStrings.help),
            onTap: () {
              Navigator.pop(context);
              WhatsApp().launchWhatsApp(
                '201020074013',
                AppStrings.haveAProblem,
              );
            },
          ),
          const Spacer(),

          const Divider(),
          // Logout Tile
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(AppStrings.logout, style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(SignOutEvent());
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                0,
                Icons.dashboard_outlined,
                Icons.dashboard,
                AppStrings.dashboard,
              ),
              _buildNavItem(
                1,
                Icons.list_alt_outlined,
                Icons.list_alt,
                AppStrings.orders,
              ),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(
                2,
                Icons.people_outline,
                Icons.people,
                AppStrings.clients,
              ),
              _buildNavItem(
                3,
                Icons.business_outlined,
                Icons.business,
                AppStrings.vendors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final color =
        isSelected ? Theme.of(context).colorScheme.primary : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  Widget _buildSubscriptionBanner(BuildContext context, User user) {
    final expiryAlert = SubscriptionHelper.getExpiryAlert(user);
    final shouldShowWarning = SubscriptionHelper.shouldShowWarning(user);

    if (expiryAlert == null && !shouldShowWarning)
      return const SizedBox.shrink();

    final remainingOrders = SubscriptionHelper.getRemainingOrders(user);
    final isLimitReached = SubscriptionHelper.hasReachedFreeLimit(user);

    // If there's an expiry alert, it takes precedence or is shown alongside
    final bgColor =
        (isLimitReached ||
                (expiryAlert != null && expiryAlert.contains('expire')))
            ? Colors.red.withOpacity(0.9)
            : Colors.orange.withOpacity(0.9);

    final icon =
        (isLimitReached || expiryAlert != null)
            ? Icons.error_outline
            : Icons.warning_amber_rounded;

    final title =
        expiryAlert ??
        (isLimitReached
            ? 'Free Plan Limit Reached'
            : 'Only $remainingOrders order${remainingOrders == 1 ? '' : 's'} remaining');

    final subtitle =
        expiryAlert != null
            ? 'Renew your subscription to keep enjoying premium features.'
            : (isLimitReached
                ? 'You have used all 5 free orders. Subscribe to continue creating orders.'
                : 'Subscribe now to get unlimited orders and premium features.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionPage(),
                      ),
                    ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  expiryAlert != null ? 'Renew Now' : 'Subscribe Now',
                  style: TextStyle(
                    color:
                        bgColor.withOpacity(1.0) == Colors.red.withOpacity(1.0)
                            ? Colors.red
                            : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;

          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubscriptionBanner(context, user),
                        _buildWelcomeSection(context),
                        const SizedBox(height: 24),
                        _buildQuickStats(context),
                        const SizedBox(height: 24),
                        _buildExtraActions(context),
                        const SizedBox(height: 24),
                        _buildRecentOrders(context),
                        const SizedBox(height: 100), // Space for FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: AppThemeHelper.getAppBarDecoration(context),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: AppThemeHelper.getTitleStyle(context),
                ),
                Text(
                  AppStrings.manageBusinessEfficiently,
                  style: AppThemeHelper.getBodyStyle(
                    context,
                  ).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppThemeHelper.getWelcomeSectionDecoration(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppThemeHelper.getPrimaryGradientDecoration(context),
            child: const Icon(Icons.auto_graph, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.welcomeBack,
                  style: AppThemeHelper.getTitleStyle(
                    context,
                  ).copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.readyToManageOrders,
                  style: AppThemeHelper.getBodyStyle(
                    context,
                  ).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, orderState) {
        return BlocBuilder<ClientBloc, ClientState>(
          builder: (context, clientState) {
            return BlocBuilder<VendorBloc, VendorState>(
              builder: (context, vendorState) {
                int totalOrders = 0;
                int totalClients = 0;
                int totalVendors = 0;
                double totalSales = 0;
                double totalProfit = 0;

                if (orderState is OrdersLoaded) {
                  totalOrders = orderState.orders.length;
                  for (var order in orderState.orders) {
                    totalSales += order.totalSalesPrice;
                    totalProfit += order.netProfit;
                  }
                }
                if (clientState is ClientsLoaded) {
                  totalClients =
                      clientState.clients
                          .map((c) => '${c.name}_${c.phoneNumber}')
                          .toSet()
                          .length;
                }
                if (vendorState is VendorsLoaded) {
                  totalVendors =
                      vendorState.vendors
                          .map((v) => '${v.name}_${v.phoneNumber}')
                          .toSet()
                          .length;
                }

                return Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.6,
                      children: [
                        _buildStatCard(
                          context,
                          AppStrings.totalOrders,
                          totalOrders.toString(),
                          Icons.shopping_bag,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          AppStrings.activeClients,
                          totalClients.toString(),
                          Icons.people,
                          Colors.green,
                        ),
                        _buildStatCard(
                          context,
                          AppStrings.vendors,
                          totalVendors.toString(),
                          Icons.business,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          context,
                          AppStrings.profit,
                          '${totalProfit.toStringAsFixed(0)}',
                          Icons.trending_up,
                          Colors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildWideStatCard(
                      context,
                      AppStrings.totalSale,
                      '${totalSales.toStringAsFixed(2)}',
                      Icons.monetization_on,
                      Colors.purple,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppThemeHelper.getCardDecoration(
        context,
      ).copyWith(border: Border.all(color: color.withOpacity(0.1))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: AppThemeHelper.getHeadlineStyle(
                context,
              ).copyWith(color: color, fontSize: 18),
            ),
          ),
          Text(
            title,
            style: AppThemeHelper.getBodyStyle(context).copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWideStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppThemeHelper.getCardDecoration(
        context,
      ).copyWith(border: Border.all(color: color.withOpacity(0.1))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppThemeHelper.getIconContainerDecoration(
              context,
              color,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppThemeHelper.getBodyStyle(context)),
                Text(
                  value,
                  style: AppThemeHelper.getHeadlineStyle(
                    context,
                  ).copyWith(color: color, fontSize: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.quickActions,
          style: AppThemeHelper.getTitleStyle(context),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                AppStrings.viewBills,
                Icons.receipt_long,
                Colors.teal,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BillsPage()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                AppStrings.analytics,
                Icons.analytics,
                Colors.indigo,
                () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.analyticsComingSoon)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: AppThemeHelper.getNavigationCardDecoration(
            context,
            color,
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppThemeHelper.getTitleStyle(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrdersLoaded && state.orders.isNotEmpty) {
          final recentOrders = state.orders.take(3).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.ordersHistory,
                    style: AppThemeHelper.getTitleStyle(context),
                  ),
                  TextButton(
                    onPressed: () {
                      final homeState =
                          context.findAncestorStateOfType<State<HomePage>>();
                      if (homeState != null) {
                        (homeState as dynamic).setState(() {
                          (homeState as dynamic)._currentIndex = 1;
                        });
                      }
                    },
                    child: Text(
                      AppStrings.viewAllOrders,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...recentOrders.map(
                (order) => _buildRecentOrderCard(context, order),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecentOrderCard(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppThemeHelper.getCardDecoration(context),
      child: ListTile(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage(order: order),
              ),
            ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: AppThemeHelper.getIconContainerDecoration(
            context,
            _getStatusColor(order.status),
          ),
          child: Icon(
            _getStatusIcon(order.status),
            color: _getStatusColor(order.status),
            size: 20,
          ),
        ),
        title: Text(
          order.vendorName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy').format(order.orderDate),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${order.totalSalesPrice.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${order.clients.length} ${AppStrings.clients}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
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
        return Icons.timer;
      case OrderStatus.working:
        return Icons.work;
      case OrderStatus.complete:
        return Icons.check_circle;
    }
  }
}
