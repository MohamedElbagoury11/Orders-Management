import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:projectmange/core/constants/app_strings.dart';
import 'package:projectmange/main.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/order.dart';
import '../blocs/order/order_bloc.dart';
import '../widgets/auth_wrapper.dart';

class ClientOrdersPage extends StatefulWidget {
  final Client client;

  const ClientOrdersPage({super.key, required this.client});

  @override
  State<ClientOrdersPage> createState() => _ClientOrdersPageState();
}

class _ClientOrdersPageState extends State<ClientOrdersPage> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    if (mounted) {
      context.read<OrderBloc>().add(LoadOrders());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 900;
    
    return ValueListenableBuilder<Locale>(
      valueListenable: languageNotifier,
      builder: (context, locale, _) {
        AppStrings.setLocale(locale);
        
        return AuthWrapper(
          child: Scaffold(
            appBar: _buildAppBar(),
            body: _buildBody(isTablet, isDesktop),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        '${widget.client.name}\'s ${AppStrings.orders}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? AppColors.primaryGreen,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
      elevation: 2,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadOrders,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildBody(bool isTablet, bool isDesktop) {
    return Container(
      decoration: _buildBackgroundDecoration(),
      child: BlocListener<OrderBloc, OrderState>(
        listener: _handleOrderStateChanges,
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) => _buildOrderContent(state, isTablet, isDesktop),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey.shade50,
          Colors.white,
        ],
      ),
    );
  }

  void _handleOrderStateChanges(BuildContext context, OrderState state) {
    if (state is OrderUpdated) {
      _showSuccessMessage('Order updated successfully');
    } else if (state is OrderError) {
      _showErrorMessage('Error: ${state.message}');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildOrderContent(OrderState state, bool isTablet, bool isDesktop) {
    if (state is OrderLoading) {
      return _buildLoadingState();
    } else if (state is OrdersLoaded) {
      return _buildOrdersContent(state, isTablet, isDesktop);
    } else if (state is OrderError) {
      return _buildErrorState(state, isTablet);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
          SizedBox(height: 16),
          Text(
            'Loading orders...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersContent(OrdersLoaded state, bool isTablet, bool isDesktop) {
    final clientOrders = _getClientOrders(state.orders);
    
    if (clientOrders.isEmpty) {
      return _buildEmptyOrdersState(isTablet);
    }
    
    return Padding(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: isDesktop
          ? _buildDesktopLayout(clientOrders)
          : _buildMobileLayout(clientOrders, isTablet),
    );
  }

  Widget _buildEmptyOrdersState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: _buildCardDecoration(),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: isTablet ? 80 : 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.noOrdersFound,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.client.name} hasn\'t placed any orders yet',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(OrderError state, bool isTablet) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: _buildCardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: isTablet ? 80 : 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Orders',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: _loadOrders,
      icon: const Icon(Icons.refresh),
      label: const Text('Retry'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildMobileLayout(List<ClientOrderInfo> clientOrders, bool isTablet) {
    return ListView.builder(
      itemCount: clientOrders.length,
      itemBuilder: (context, index) {
        final orderInfo = clientOrders[index];
        return _buildOrderCard(orderInfo, isTablet);
      },
    );
  }

  Widget _buildDesktopLayout(List<ClientOrderInfo> clientOrders) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: clientOrders.length,
      itemBuilder: (context, index) {
        final orderInfo = clientOrders[index];
        return _buildOrderCard(orderInfo, true);
      },
    );
  }

  Widget _buildOrderCard(ClientOrderInfo orderInfo, bool isTablet) {
    final profit = orderInfo.client.salePrice - orderInfo.client.purchasePrice;
    final isPositiveProfit = profit >= 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _buildCardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOrderDetails(orderInfo),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(orderInfo, isTablet),
                const SizedBox(height: 12),
                _buildOrderDate(orderInfo, isTablet),
                const SizedBox(height: 12),
                _buildOrderDetails(orderInfo),
                const SizedBox(height: 12),
                _buildProfitSection(profit, isPositiveProfit, isTablet),
                const SizedBox(height: 8),
                _buildDepositInfo(orderInfo.client, isTablet),
                const SizedBox(height: 12),
                _buildReceivedStatusCheckbox(orderInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildOrderHeader(ClientOrderInfo orderInfo, bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              orderInfo.order.vendorName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey.shade800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusChip(orderInfo),
      ],
    );
  }

  Widget _buildOrderDate(ClientOrderInfo orderInfo, bool isTablet) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: isTablet ? 16 : 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          DateFormat('MMM dd, yyyy').format(orderInfo.order.orderDate),
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(ClientOrderInfo orderInfo) {
    return Column(
      children: [
        _buildDetailRow(AppStrings.pieces, '${orderInfo.client.piecesNumber}', Icons.inventory),
        const SizedBox(height: 8),
        _buildDetailRow(AppStrings.purchase, '\$${orderInfo.client.purchasePrice}', Icons.shopping_cart),
        const SizedBox(height: 8),
        _buildDetailRow(AppStrings.sale, '\$${orderInfo.client.salePrice}', Icons.attach_money),
      ],
    );
  }

  Widget _buildProfitSection(double profit, bool isPositiveProfit, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isPositiveProfit ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPositiveProfit ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPositiveProfit ? Icons.trending_up : Icons.trending_down,
            size: isTablet ? 16 : 14,
            color: isPositiveProfit ? Colors.green.shade600 : Colors.red.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            '${AppStrings.profit}: \$${profit.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: isPositiveProfit ? Colors.green.shade600 : Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedStatusCheckbox(ClientOrderInfo orderInfo) {
    if (orderInfo.order.status == OrderStatus.pending) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Checkbox(
          value: orderInfo.client.isReceived,
          onChanged: (value) => _updateClientReceivedStatus(orderInfo, value),
          activeColor: AppColors.primaryGreen,
        ),
        Text(
          orderInfo.client.isReceived ? AppStrings.received : AppStrings.notReceived,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: orderInfo.client.isReceived ? Colors.green.shade600 : Colors.red.shade600,
          ),
        ),
      ],
    );
  }

  void _updateClientReceivedStatus(ClientOrderInfo orderInfo, bool? value) {
    if (value != null && mounted) {
      context.read<OrderBloc>().add(UpdateClientReceived(
        orderId: orderInfo.order.id,
        clientId: orderInfo.client.id,
        isReceived: value,
      ));
    }
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ClientOrderInfo orderInfo) {
    final statusConfig = _getStatusConfig(orderInfo.order.status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusConfig.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusConfig.color.withOpacity(0.3)),
      ),
      child: Text(
        statusConfig.text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: statusConfig.color,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return _StatusConfig(Colors.orange, AppStrings.pending);
      case OrderStatus.working:
        return _StatusConfig(Colors.blue, AppStrings.working);
      case OrderStatus.complete:
        return _StatusConfig(Colors.green, AppStrings.complete);
    }
  }

  List<ClientOrderInfo> _getClientOrders(List<Order> orders) {
    final List<ClientOrderInfo> clientOrders = [];
    
    for (final order in orders) {
      for (final client in order.clients) {
        if (_isMatchingClient(client)) {
          clientOrders.add(ClientOrderInfo(client: client, order: order));
        }
      }
    }
    
    _sortClientOrdersByDate(clientOrders);
    return clientOrders;
  }

  bool _isMatchingClient(OrderClient client) {
    return client.name == widget.client.name && 
           client.phoneNumber == widget.client.phoneNumber;
  }

  void _sortClientOrdersByDate(List<ClientOrderInfo> clientOrders) {
    clientOrders.sort((a, b) => b.order.orderDate.compareTo(a.order.orderDate));
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.working:
        return 'Working';
      case OrderStatus.complete:
        return 'Complete';
    }
  }

  void _showOrderDetails(ClientOrderInfo orderInfo) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    showDialog(
      context: context,
      builder: (context) => _buildOrderDetailsDialog(orderInfo, isTablet),
    );
  }

  AlertDialog _buildOrderDetailsDialog(ClientOrderInfo orderInfo, bool isTablet) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: _buildDialogTitle(isTablet),
      content: _buildDialogContent(orderInfo, isTablet),
      actions: _buildDialogActions(),
    );
  }

  Widget _buildDialogTitle(bool isTablet) {
    return Row(
      children: [
        Icon(
          Icons.receipt_long,
          color: AppColors.primaryGreen,
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
    );
  }

  Widget _buildDialogContent(ClientOrderInfo orderInfo, bool isTablet) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDetailSection(
            AppStrings.clientInformation,
            _buildClientInformationItems(orderInfo),
          ),
          const Divider(height: 24),
          _buildDetailSection(
            AppStrings.orderInformation,
            _buildOrderInformationItems(orderInfo),
          ),
          const Divider(height: 24),
          _buildDetailSection(
            AppStrings.financialSummary,
            _buildFinancialSummaryItems(orderInfo),
          ),
          const Divider(height: 24),
          _buildDetailSection(
            AppStrings.paymentDetails,
            _buildPaymentDetailsItems(orderInfo),
          ),
          const Divider(height: 24),
          _buildImagesSection(orderInfo),
        ],
      ),
    );
  }

  List<Widget> _buildClientInformationItems(ClientOrderInfo orderInfo) {
    return [
      _buildDetailItem(AppStrings.name, orderInfo.client.name, Icons.person),
      _buildDetailItem(AppStrings.phone, orderInfo.client.phoneNumber, Icons.phone),
      _buildDetailItem(AppStrings.address, orderInfo.client.address, Icons.location_on),
    ];
  }

  List<Widget> _buildOrderInformationItems(ClientOrderInfo orderInfo) {
    return [
      _buildDetailItem(AppStrings.vendor, orderInfo.order.vendorName, Icons.business),
      _buildDetailItem(AppStrings.vendorPhone, orderInfo.order.vendorPhone, Icons.phone),
      _buildDetailItem(AppStrings.orderDate, DateFormat('MMM dd, yyyy').format(orderInfo.order.orderDate), Icons.calendar_today),
      _buildDetailItem(AppStrings.status, _getStatusText(orderInfo.order.status), Icons.info),
      _buildDetailItem(AppStrings.received, orderInfo.client.isReceived ? 'Yes' : 'No', Icons.check_circle),
    ];
  }

  List<Widget> _buildFinancialSummaryItems(ClientOrderInfo orderInfo) {
    return [
      _buildDetailItem(AppStrings.pieces, '${orderInfo.client.piecesNumber}', Icons.inventory),
      _buildDetailItem(AppStrings.purchasePrice, '\$${orderInfo.client.purchasePrice}', Icons.shopping_cart),
      _buildDetailItem(AppStrings.salePrice, '\$${orderInfo.client.salePrice}', Icons.attach_money),
      _buildDetailItem(AppStrings.profit, '\$${(orderInfo.client.salePrice - orderInfo.client.purchasePrice).toStringAsFixed(2)}', Icons.trending_up),
    ];
  }

  List<Widget> _buildPaymentDetailsItems(ClientOrderInfo orderInfo) {
    return [
      _buildDetailItem(AppStrings.deposit, '\$${orderInfo.client.deposit}', Icons.account_balance_wallet),
      _buildDetailItem(AppStrings.remaining, '\$${(orderInfo.client.salePrice - orderInfo.client.deposit).toStringAsFixed(2)}', Icons.pending_actions),
    ];
  }

  List<Widget> _buildDialogActions() {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Close'),
      ),
    ];
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

  Widget _buildDepositInfo(OrderClient client, bool isTablet) {
    final remainingAmount = client.salePrice - client.deposit;
    final isFullyPaid = remainingAmount <= 0;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDepositRow(client, isTablet),
          const SizedBox(height: 4),
          _buildRemainingRow(remainingAmount, isFullyPaid, isTablet),
        ],
      ),
    );
  }

  Widget _buildDepositRow(OrderClient client, bool isTablet) {
    return Row(
      children: [
        Icon(
          Icons.account_balance_wallet,
          size: isTablet ? 16 : 14,
          color: Colors.blue.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          'Deposit: \$${client.deposit.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingRow(double remainingAmount, bool isFullyPaid, bool isTablet) {
    return Row(
      children: [
        Icon(
          isFullyPaid ? Icons.check_circle : Icons.pending_actions,
          size: isTablet ? 16 : 14,
          color: isFullyPaid ? Colors.green.shade600 : Colors.orange.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          'Remaining: \$${remainingAmount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: isFullyPaid ? Colors.green.shade600 : Colors.orange.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection(ClientOrderInfo orderInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImagesHeader(orderInfo),
        const SizedBox(height: 8),
        if (orderInfo.client.images.isNotEmpty) ...[
          _buildImagesGallery(orderInfo),
          const SizedBox(height: 8),
          _buildImagesHint(),
        ] else ...[
          _buildNoImagesPlaceholder(),
        ],
      ],
    );
  }

  Widget _buildImagesHeader(ClientOrderInfo orderInfo) {
    return Row(
      children: [
        Icon(
          Icons.photo_library,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          'Images',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${orderInfo.client.images.length}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesGallery(ClientOrderInfo orderInfo) {
    return Container(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: orderInfo.client.images.asMap().entries.map((entry) {
            final index = entry.key;
            final imageUrl = entry.value;
            return _buildImageThumbnail(imageUrl, index, orderInfo.client.images);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String imageUrl, int index, List<String> images) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _showImageGallery(context, images, index),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildImageErrorPlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _buildImageErrorPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesHint() {
    return Text(
      'Tap on images to view in full screen',
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey.shade500,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildNoImagesPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.photo_library_outlined,
            color: Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'No images uploaded yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageGallery(BuildContext context, List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageGalleryScreen(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _ImageGalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImageGalleryScreen({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<_ImageGalleryScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Text(
        'Image ${_currentIndex + 1} of ${widget.images.length}',
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: _buildPageView(),
        ),
        _buildBottomIndicator(),
      ],
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: widget.images.length,
      itemBuilder: (context, index) => _buildImagePage(index),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildImagePage(int index) {
    return InteractiveViewer(
      child: Center(
        child: Image.network(
          widget.images[index],
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildImageErrorIcon(),
        ),
      ),
    );
  }

  Widget _buildImageErrorIcon() {
    return const Center(
      child: Icon(
        Icons.error_outline,
        color: Colors.white,
        size: 48,
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.images.length,
          (index) => _buildIndicatorDot(index),
        ),
      ),
    );
  }

  Widget _buildIndicatorDot(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == _currentIndex ? Colors.white : Colors.white.withOpacity(0.5),
      ),
    );
  }
}

class ClientOrderInfo {
  final OrderClient client;
  final Order order;

  ClientOrderInfo({required this.client, required this.order});
}

class _StatusConfig {
  final Color color;
  final String text;

  const _StatusConfig(this.color, this.text);
}
