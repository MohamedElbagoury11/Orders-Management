import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:projectmange/core/constants/app_strings.dart';
import 'package:projectmange/presentation/blocs/vendor/vendor_bloc.dart';

class CreateVendorDialog extends StatefulWidget {
  const CreateVendorDialog({super.key});

  @override
  State<CreateVendorDialog> createState() => _CreateVendorDialogState();
}

class _CreateVendorDialogState extends State<CreateVendorDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        final fullContact = await FlutterContacts.getContact(contact.id);
        setState(() {
          _nameController.text =
              fullContact?.displayName ?? contact.displayName;
          if ((fullContact?.phones.isNotEmpty ?? false)) {
            _phoneController.text = fullContact!.phones.first.number;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.addVendor),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _pickContact,
                icon: const Icon(Icons.contacts),
                label:  Text(AppStrings.importFromContacts),
              ),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppStrings.vendorName,
                border: const OutlineInputBorder(),
              ),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? AppStrings.pleaseEnterVendorName
                          : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: AppStrings.vendorPhoneNumber,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? AppStrings.pleaseEnterVendorPhone
                          : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<VendorBloc>().add(
                CreateVendor(
                  name: _nameController.text.trim(),
                  phoneNumber: _phoneController.text.trim(),
                ),
              );
              Navigator.pop(context);
            }
          },
          child: Text(AppStrings.addVendor),
        ),
      ],
    );
  }
}
