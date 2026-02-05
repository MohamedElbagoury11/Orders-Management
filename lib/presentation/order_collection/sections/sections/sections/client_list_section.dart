import 'package:flutter/material.dart';
import 'package:projectmange/core/constants/app_strings.dart';
import 'package:projectmange/domain/entities/order.dart';
import 'package:projectmange/presentation/order_collection/sections/sections/dialogs/edit_client_dialog.dart';

class ClientListSection extends StatelessWidget {
  final List<OrderClient> clients;
  final bool isPending;
  final void Function(int, OrderClient) onEdit;
  final Future<void> Function(int) onDelete;

  const ClientListSection({
    super.key,
    required this.clients,
    required this.isPending,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Create a list of original indices and sort them by client name
    

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
                  '${AppStrings.clientsSectionTitle} (${clients.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (clients.isEmpty)
              Center(
                child: Text(
                  AppStrings.noClientsAddedYet,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: clients.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                //  final originalIndex = sortedIndices[index];
                  final client = clients[index];
                  return Card(
                    child: ListTile(
                      
                      title: Row(
                        children: [
                          Expanded(child: Text(client.name)),
                          if (client.images.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                              child: Text(
                                '${client.images.length}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        
                        children: [
                          Text(
                            '${AppStrings.phoneNumber}: ${client.phoneNumber}',
                          ),
                          Text('${AppStrings.address}: ${client.address}'),
                          Text('${AppStrings.pieces}: ${client.piecesNumber}'),
                          Text(
                            maxLines: 1,
                            
                            '${AppStrings.purchase}: EGP ${client.purchasePrice}',
                          ),
                          Text('${AppStrings.sale}: EGP ${client.salePrice}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPending)
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed:
                                  () => _openEditDialog(
                                    context,
                                    index,
                                    client,
                                  ),
                            ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () => onDelete(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _openEditDialog(BuildContext context, int index, OrderClient client) {
    showDialog(
      context: context,
      builder:
          (_) => EditClientDialog(
            initialClient: client,
            orderId: null,
            onClientEdited: (edited) => onEdit(index, edited),
          ),
    );
  }
}
