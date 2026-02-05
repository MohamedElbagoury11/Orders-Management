import 'package:flutter/material.dart';
import 'package:projectmange/core/constants/app_strings.dart';
import 'package:projectmange/core/utils/phone_helper.dart';
import 'package:projectmange/domain/entities/order.dart';
import 'package:uuid/uuid.dart';

class AddClientDialog extends StatefulWidget {
  final Function(OrderClient) onClientAdded;
  final String? initialName;
  final String? initialPhone;
  final String? initialAddress;
  final String? clientId;
  final bool hideIdentityFields;

  const AddClientDialog({
    super.key,
    required this.onClientAdded,
    this.initialName,
    this.initialPhone,
    this.initialAddress,
    this.clientId,
    this.hideIdentityFields = false,
  });

  @override
  State<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final _piecesController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _depositController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _addressController = TextEditingController(
      text: widget.initialAddress ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.addClient),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.hideIdentityFields) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: AppStrings.name),
                  validator:
                      (v) => v == null || v.isEmpty ? AppStrings.name : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: AppStrings.phone),
                  validator:
                      (v) => v == null || v.isEmpty ? AppStrings.phone : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: AppStrings.address),
                  maxLines: 2,
                  validator:
                      (v) => v == null || v.isEmpty ? AppStrings.address : null,
                ),
                const SizedBox(height: 10),
              ] else ...[
                // Show read-only info for selected client
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppStrings.clients}: ${_nameController.text}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('${AppStrings.phone}: ${_phoneController.text}'),
                      const SizedBox(height: 4),
                      Text('${AppStrings.address}: ${_addressController.text}'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              TextFormField(
                controller: _piecesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${AppStrings.piecesNumber} ',
                ),
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? AppStrings.pleaseEnterPiecesNumber
                            : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _purchasePriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.purchasePrice,
                ),
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? AppStrings.pleaseEnterPurchasePrice
                            : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _salePriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppStrings.salePrice),
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? AppStrings.pleaseEnterSalePrice
                            : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _depositController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppStrings.deposit),
                validator:
                    (v) =>
                        v == null || v.isEmpty
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
        ElevatedButton(onPressed: _submit, child: Text(AppStrings.add)),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final client = OrderClient(
      id: widget.clientId ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      phoneNumber: PhoneNumberHelper.normalize(_phoneController.text.trim()),
      address: _addressController.text.trim(),
      piecesNumber: int.parse(_piecesController.text),
      purchasePrice: double.parse(_purchasePriceController.text),
      salePrice: double.parse(_salePriceController.text),
      deposit: double.tryParse(_depositController.text) ?? 0.0,
      createdAt: DateTime.now(),
      images: const [],
      isReceived: false,
    );

    widget.onClientAdded(client);
    Navigator.pop(context);
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
}
