import 'package:flutter/material.dart';
import 'package:projectmange/core/constants/app_strings.dart';
import 'package:projectmange/domain/entities/order.dart';

class OrderSummarySection extends StatefulWidget {
  final List<OrderClient> clients;
  final TextEditingController chargeController;

  const OrderSummarySection({super.key, required this.clients, required this.chargeController});

  // Method to validate the charge field
  static bool validateCharge(TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) return false;
    final charge = double.tryParse(value);
    return charge != null && charge >= 0;
  }

  @override
  State<OrderSummarySection> createState() => _OrderSummarySectionState();
}

class _OrderSummarySectionState extends State<OrderSummarySection> {
  final _formKey = GlobalKey<FormState>();

  double _calculateNetProfit() {
    final totalSale = widget.clients.fold(0.0, (sum, client) => sum + client.salePrice);
    final totalPurchase = widget.clients.fold(0.0, (sum, client) => sum + client.purchasePrice);
    final charge = double.tryParse(widget.chargeController.text) ?? 0.0;
    return totalSale - totalPurchase - charge;
  }

  @override
  Widget build(BuildContext context) {
    final totalPurchase = widget.clients.fold(0.0, (sum, c) => sum + c.purchasePrice);
    final totalSale = widget.clients.fold(0.0, (sum, c) => sum + c.salePrice);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.orderSummary, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildSummaryRow(context, '${AppStrings.totalPurchasePrice}', totalPurchase),
              _buildSummaryRow(context, '${AppStrings.totalSalesPrice}', totalSale),
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.chargeController,
                keyboardType: TextInputType.number,
                decoration:  InputDecoration(
                  labelText: '${AppStrings.charge} (Required)',
                  hintText: AppStrings.pleaseEnterChargeAmount,
                  border: OutlineInputBorder(),
                  prefixText: AppStrings.egp,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Charge is required';
                  }
                  final charge = double.tryParse(value);
                  if (charge == null || charge < 0) {
                    return 'Please enter a valid charge amount';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow(context, '${AppStrings.charge}:', double.tryParse(widget.chargeController.text) ?? 0.0),
              const Divider(),
              _buildSummaryRow(context, '${AppStrings.netProfit}:', _calculateNetProfit(), isTotal: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text('EGP ${value.toStringAsFixed(2)}', style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Theme.of(context).colorScheme.primary : null)),
        ],
      ),
    );
  }
}