import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:projectmange/core/utils/phone_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme_helper.dart';
import '../../domain/entities/order.dart';
import '../blocs/order/order_bloc.dart';
import '../widgets/auth_wrapper.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Order _currentOrder;
  bool _hasChanges = false;
  bool _showSuccessAnimation = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  Future<void> _launchWhatsApp(String phone, String message) async {
    final formattedPhone = PhoneNumberHelper.normalize(phone);
    final encodedMessage = Uri.encodeComponent(message);

    // Try several common WhatsApp schemes
    final whatsappUrl =
        "whatsapp://send?phone=$formattedPhone&text=$encodedMessage";
    final webUrl = "https://wa.me/$formattedPhone?text=$encodedMessage";

    final whatsappUri = Uri.parse(whatsappUrl);
    final webUri = Uri.parse(webUrl);

    try {
      // First attempt: Primary WhatsApp app scheme
      bool launched = false;

      // We try canLaunchUrl, but if it fails we might still try to launch
      // because canLaunchUrl can be unreliable on some devices even with queries.
      if (await canLaunchUrl(whatsappUri)) {
        launched = await launchUrl(whatsappUri);
      }

      if (!launched && await canLaunchUrl(webUri)) {
        launched = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // If both canLaunchUrl checks failed OR they didn't actually launch,
      // try a "blind" launch as a last resort before giving up.
      if (!launched) {
        try {
          launched = await launchUrl(
            webUri,
            mode: LaunchMode.externalApplication,
          );
        } catch (_) {}
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open WhatsApp. Please make sure it is installed.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSendMessageDialog(OrderClient client) {
    final result = client.salePrice - client.deposit;
    final message = AppStrings.orderMessageTemplate
        .replaceAll('{sales}', client.salePrice.toStringAsFixed(0))
        .replaceAll('{deposit}', client.deposit.toStringAsFixed(0))
        .replaceAll('{result}', result.toStringAsFixed(0));
    final TextEditingController controller = TextEditingController(
      text: message,
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${AppStrings.whatsappMessageTo} ${client.name}'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: AppStrings.enterMessage),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Navigator.pop(context);
                    _launchWhatsApp(client.phoneNumber, controller.text);
                  }
                },
                child: Text(AppStrings.submit),
              ),
            ],
          ),
    );
  }

  void _onClientReceivedChanged(OrderClient client, bool isReceived) {
    if (isReceived) {
      final allOthersReceived = _currentOrder.clients
          .where((c) => c.id != client.id)
          .every((c) => c.isReceived);

      if (allOthersReceived) {
        _showCompletionWarning(client);
        return;
      }
    }

    _processStatusChange(client, isReceived);
  }

  void _showCompletionWarning(OrderClient client) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Warning'),
            content: const Text(
              'You accept this order is complete. If you choose OK you can\'t return it again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.pop(context);
                    _processStatusChange(client, true);
                    setState(() {
                      _showSuccessAnimation = true;
                    });
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _processStatusChange(OrderClient client, bool isReceived) {
    setState(() {
      _hasChanges = true;
      final updatedClients =
          _currentOrder.clients.map((c) {
            if (c.id == client.id) {
              return OrderClient(
                id: c.id,
                name: c.name,
                phoneNumber: c.phoneNumber,
                address: c.address,
                piecesNumber: c.piecesNumber,
                purchasePrice: c.purchasePrice,
                salePrice: c.salePrice,
                isReceived: isReceived,
                createdAt: c.createdAt,
                deposit: c.deposit,
                images: c.images,
              );
            }
            return c;
          }).toList();

      final allReceived = updatedClients.every((c) => c.isReceived);
      final newStatus =
          allReceived ? OrderStatus.complete : OrderStatus.working;

      _currentOrder = Order(
        id: _currentOrder.id,
        vendorId: _currentOrder.vendorId,
        vendorName: _currentOrder.vendorName,
        vendorPhone: _currentOrder.vendorPhone,
        clients: updatedClients,
        charge: _currentOrder.charge,
        status: newStatus,
        orderDate: _currentOrder.orderDate,
        createdAt: _currentOrder.createdAt,
        updatedAt: _currentOrder.updatedAt,
        userId: _currentOrder.userId,
      );
    });

    // We can either update immediately or on back
    context.read<OrderBloc>().add(
      UpdateClientReceived(
        orderId: _currentOrder.id,
        clientId: client.id,
        isReceived: isReceived,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPositiveProfit = _currentOrder.netProfit >= 0;

    return AuthWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.orderDetails),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushNamed(context, '/home'),
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: AppThemeHelper.getBackgroundGradientDecoration(
                context,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Status Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppThemeHelper.getCardDecoration(
                        context,
                      ).copyWith(
                        color: _getStatusColor(
                          _currentOrder.status,
                        ).withOpacity(0.1),
                        border: Border.all(
                          color: _getStatusColor(
                            _currentOrder.status,
                          ).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(_currentOrder.status),
                            color: _getStatusColor(_currentOrder.status),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${AppStrings.status}: ${_getStatusText(_currentOrder.status)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(
                                      _currentOrder.status,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${AppStrings.date}: ${DateFormat('MMM dd, yyyy').format(_currentOrder.orderDate)}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Vendor Section
                    Text(
                      AppStrings.vendorInformation,
                      style: AppThemeHelper.getHeadlineStyle(context),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppThemeHelper.getCardDecoration(context),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.business,
                            AppStrings.vendorName,
                            _currentOrder.vendorName,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.phone,
                            AppStrings.phone,
                            _currentOrder.vendorPhone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Financial Section
                    Text(
                      AppStrings.financialSummary,
                      style: AppThemeHelper.getHeadlineStyle(context),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppThemeHelper.getCardDecoration(context),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.payments,
                            AppStrings.charge,
                            'EGP ${_currentOrder.charge.toStringAsFixed(2)} ',
                          ),
                          _buildInfoRow(
                            Icons.shopping_cart,
                            AppStrings.totalPurchasePrice,
                            'EGP ${_currentOrder.totalPurchasePrice.toStringAsFixed(2)}',
                          ),
                          _buildInfoRow(
                            Icons.sell,
                            AppStrings.totalSalesPrice,
                            'EGP ${_currentOrder.totalSalesPrice.toStringAsFixed(2)} ',
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.netProfit,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'EGP ${_currentOrder.netProfit.toStringAsFixed(2)} ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color:
                                      isPositiveProfit
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Clients Section
                    Text(
                      '${AppStrings.clients} (${_currentOrder.clients.length})',
                      style: AppThemeHelper.getHeadlineStyle(context),
                    ),
                    const SizedBox(height: 12),
                    ..._currentOrder.clients.map(
                      (client) => _buildClientCard(client),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            if (_showSuccessAnimation)
              Positioned.fill(
                child: _SuccessAnimation(
                  onAnimationComplete: () {
                    if (mounted) {
                      setState(() {
                        _showSuccessAnimation = false;
                      });
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(OrderClient client) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppThemeHelper.getCardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  child: Text(client.name[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: AppThemeHelper.getTitleStyle(context),
                      ),
                      Text(
                        client.phoneNumber,
                        style: AppThemeHelper.getBodyStyle(context),
                      ),
                    ],
                  ),
                ),
                if (_currentOrder.status == OrderStatus.working ||
                    _currentOrder.status == OrderStatus.pending)
                  IconButton(
                    icon: const Icon(Icons.chat_bubble, color: Colors.green),
                    onPressed: () => _showSendMessageDialog(client),
                  ),
                _currentOrder.status == OrderStatus.working
                    ? Checkbox(
                      value: client.isReceived,
                      activeColor: Colors.green,
                      onChanged: (val) {
                        if (val != null) _onClientReceivedChanged(client, val);
                      },
                    )
                    : const SizedBox.shrink(),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat(AppStrings.pieces, '${client.piecesNumber}'),
                _buildMiniStat(
                  AppStrings.purchase,
                  'EGP ${client.purchasePrice}',
                ),
                _buildMiniStat(AppStrings.sale, 'EGP ${client.salePrice}'),
                _buildMiniStat(AppStrings.deposit, 'EGP ${client.deposit}'),
              ],
            ),
            if (client.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: client.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(client.images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
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
}

class _SuccessAnimation extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const _SuccessAnimation({required this.onAnimationComplete});

  @override
  State<_SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<_SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      // Wait a bit before closing
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onAnimationComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings
                        .great, // Assuming 'Great!' key exists or generic 'Success'
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings
                        .orderCompleted, // Using 'Order Completed' key if available or generic
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
