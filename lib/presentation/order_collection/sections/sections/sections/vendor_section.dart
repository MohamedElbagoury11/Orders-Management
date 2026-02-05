import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmange/core/constants/app_strings.dart';
import 'package:projectmange/domain/entities/vendor.dart';
import 'package:projectmange/presentation/blocs/vendor/vendor_bloc.dart';
import 'package:projectmange/presentation/order_collection/sections/sections/dialogs/create_vendor_dialog.dart';

class VendorSection extends StatelessWidget {
  final Vendor? selectedVendor;
  final ValueChanged<Vendor> onVendorSelected;

  const VendorSection({super.key, required this.selectedVendor, required this.onVendorSelected});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(AppStrings.vendorInformation, style: Theme.of(context).textTheme.titleLarge)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.selectVendor, style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(onPressed: () => _showCreateVendorDialog(context), icon: const Icon(Icons.add), label: Text(AppStrings.addVendor)),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<VendorBloc, VendorState>(
              builder: (context, vState) {
                if (vState is VendorLoading) return const LinearProgressIndicator();
                final vendors = (vState is VendorsLoaded) ? vState.vendors : <Vendor>[];
                return DropdownButtonFormField<String>(
                  value: selectedVendor?.id,
                  isExpanded: true,
                  decoration: InputDecoration(border: const OutlineInputBorder(), labelText: AppStrings.chooseAnExistingVendor),
                  items: vendors.map((v) => DropdownMenuItem(value: v.id, child: Text('${v.name} — ${v.phoneNumber}'))).toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    try {
                      final v = vendors.firstWhere((e) => e.id == id);
                      onVendorSelected(v);
                    } catch (_) {}
                  },
                );
              },
            ),
            if (selectedVendor != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () => onVendorSelected.call(Vendor.empty()), child: Text(AppStrings.cancel)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateVendorDialog(BuildContext context) => showDialog(context: context, builder: (_) => const CreateVendorDialog());
}
