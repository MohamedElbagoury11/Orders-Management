import 'package:flutter/material.dart';
import 'package:projectmange/core/constants/app_strings.dart';
import 'package:projectmange/domain/entities/order.dart';

class EditClientDialog extends StatefulWidget {
  final OrderClient initialClient;
  final String? orderId;
  final ValueChanged<OrderClient> onClientEdited;

  const EditClientDialog({
    super.key,
    required this.initialClient,
    this.orderId,
    required this.onClientEdited,
  });

  @override
  State<EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends State<EditClientDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _piecesController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _depositController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialClient.name);
    _phoneController = TextEditingController(
      text: widget.initialClient.phoneNumber,
    );
    _addressController = TextEditingController(
      text: widget.initialClient.address,
    );
    _piecesController = TextEditingController(
      text: widget.initialClient.piecesNumber.toString(),
    );
    _purchasePriceController = TextEditingController(
      text: widget.initialClient.purchasePrice.toString(),
    );
    _salePriceController = TextEditingController(
      text: widget.initialClient.salePrice.toString(),
    );
    _depositController = TextEditingController(
      text: widget.initialClient.deposit.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _piecesController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final edited = widget.initialClient.copyWith(
        piecesNumber: int.tryParse(_piecesController.text) ?? 0,
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0.0,
        salePrice: double.tryParse(_salePriceController.text) ?? 0.0,
        deposit: double.tryParse(_depositController.text) ?? 0.0,
      );
      widget.onClientEdited(edited);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.editClient),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: AppStrings.clientName,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: AppStrings.phoneNumber,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                enabled: false,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: AppStrings.address,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const Divider(height: 32),
              TextFormField(
                controller: _piecesController,
                decoration: InputDecoration(
                  labelText: AppStrings.pieces,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? AppStrings.pleaseEnterPieces
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _purchasePriceController,
                decoration: InputDecoration(
                  labelText: AppStrings.purchasePrice,
                  border: const OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? AppStrings.pleaseEnterPurchasePrice
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salePriceController,
                decoration: InputDecoration(
                  labelText: AppStrings.salePrice,
                  border: const OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? AppStrings.pleaseEnterSalePrice
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _depositController,
                decoration: InputDecoration(
                  labelText: AppStrings.deposit,
                  border: const OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? AppStrings.pleaseEnterDeposit
                            : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.cancel),
        ),
        ElevatedButton(onPressed: _submit, child: Text(AppStrings.save)),
      ],
    );
  }
}
