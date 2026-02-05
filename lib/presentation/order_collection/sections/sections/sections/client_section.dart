import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmange/core/constants/app_strings.dart';
import 'package:projectmange/domain/entities/client.dart' as DomainClient;
import 'package:projectmange/domain/entities/order.dart';
import 'package:projectmange/presentation/blocs/client/client_bloc.dart';
import 'package:projectmange/presentation/order_collection/sections/sections/dialogs/add_client_dialog.dart';
import 'package:projectmange/presentation/order_collection/sections/sections/dialogs/create_client_dialog.dart';

class ClientSection extends StatelessWidget {
  final ValueChanged<OrderClient> onClientAdded;

  const ClientSection({super.key, required this.onClientAdded});

  @override
  Widget build(BuildContext context) {
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.clients,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showCreateClientDialog(context),
                      icon: const Icon(Icons.person_add),
                      label: Text(AppStrings.addClient),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<ClientBloc, ClientState>(
              builder: (context, cState) {
                if (cState is ClientLoading)
                  return const LinearProgressIndicator();
          
    
                final clients =
                    (cState is ClientsLoaded)
                        ? cState.clients
                        : <DomainClient.Client>[];
                final sortedIndices = List.generate(clients.length, (i) => i)..sort(
      (a, b) => clients[a].name.toLowerCase().compareTo(
        clients[b].name.toLowerCase(),
      ),
    );
                return DropdownButtonFormField<String>(
                  initialValue: null,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: AppStrings.chooseAnExistingClient,
                  ),
                  items:
                      sortedIndices.map(
                            (i) => DropdownMenuItem(
                              value: clients[i].id,
                              child: Text('${clients[i].name} — ${clients[i].phoneNumber}'),
                            ),
                          )
                          .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    try {
                      final c = clients.firstWhere((e) => e.id == id);
                      // Immediately open order details dialog for selected client
                      showDialog(
                        context: context,
                        builder:
                            (_) => AddClientDialog(
                              clientId: c.id,
                              initialName: c.name,
                              initialPhone: c.phoneNumber,
                              initialAddress: c.address,
                              hideIdentityFields: true,
                              onClientAdded: onClientAdded,
                            ),
                      );
                    } catch (_) {}
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateClientDialog(BuildContext context) =>
      showDialog(context: context, builder: (_) => const CreateClientDialog());
}


// -----------------------------
// SECTIONS: client_list_section.dart
// -----------------------------

// FILE: lib/presentation/order_collection/sections/client_list_section.dart

