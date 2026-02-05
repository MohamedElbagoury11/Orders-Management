import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:projectmange/core/constants/app_strings.dart';
import 'package:projectmange/core/utils/phone_helper.dart';
import 'package:projectmange/presentation/blocs/client/client_bloc.dart';

class CreateClientDialog extends StatefulWidget {
  const CreateClientDialog({super.key});

  @override
  State<CreateClientDialog> createState() => _CreateClientDialogState();
}

class _CreateClientDialogState extends State<CreateClientDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
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
            _phoneController.text = PhoneNumberHelper.normalize(
              fullContact!.phones.first.number,
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.addClient),
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
                label: Text(AppStrings.importFromContacts),
              ),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppStrings.clientName,
                border: const OutlineInputBorder(),
              ),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? AppStrings.pleaseEnterName
                          : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: AppStrings.phoneNumber,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? AppStrings.pleaseEnterPhoneNumber
                          : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: AppStrings.address,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? AppStrings.pleaseEnterAddress
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
              context.read<ClientBloc>().add(
                CreateClient(
                  name: _nameController.text.trim(),
                  phoneNumber: PhoneNumberHelper.normalize(
                    _phoneController.text.trim(),
                  ),
                  address: _addressController.text.trim(),
                ),
              );
              Navigator.pop(context);
            }
          },
          child: Text(AppStrings.addClient),
        ),
      ],
    );
  }
}
