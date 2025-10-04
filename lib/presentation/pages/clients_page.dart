import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme_helper.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/order.dart'; // Added import for Order
import '../blocs/client/client_bloc.dart';
import '../blocs/order/order_bloc.dart';
import '../widgets/auth_wrapper.dart';
import 'client_orders_page.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  bool _isDeleting = false;
  final TextEditingController _searchController = TextEditingController();
  List<Client> _filteredClients = [];
  List<Client> _allClients = [];

  @override
  void initState() {
    super.initState();
    context.read<ClientBloc>().add(LoadClients());
    context.read<OrderBloc>().add(LoadOrders());
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredClients = _allClients;
      });
    } else {
      setState(() {
        _filteredClients = _allClients.where((client) =>
            client.name.toLowerCase().contains(query)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.clients),
          elevation: 0,
          centerTitle: true,
        ),
        body: Container(
          decoration: AppThemeHelper.getBackgroundGradientDecoration(context),
          child: Column(
            children: [
              // Search Bar
              Container(
                padding: AppThemeHelper.getCardPadding(context),
                decoration: AppThemeHelper.getCardDecoration(context),
                margin: AppThemeHelper.getStandardPadding(context),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchClients,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              
              // Results count
              if (_searchController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${_filteredClients.length} ${_filteredClients.length == 1 ? AppStrings.resultFound : AppStrings.resultsFound}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Clients List
              Expanded(
                child: BlocListener<ClientBloc, ClientState>(
                  listener: (context, state) {
                    if (state is ClientLoading) {
                      setState(() {
                        _isDeleting = true;
                      });
                    } else if (state is ClientCreated) {
                      setState(() {
                        _isDeleting = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Client ${state.client.name} created successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (state is ClientUpdated) {
                      setState(() {
                        _isDeleting = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Client ${state.client.name} updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (state is ClientDeleted) {
                      setState(() {
                        _isDeleting = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.clientsDeletedSuccessfully),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (state is ClientsLoaded) {
                      setState(() {
                        _isDeleting = false;
                        _allClients = state.clients;
                        _filteredClients = state.clients;
                      });
                    } else if (state is ClientError) {
                      setState(() {
                        _isDeleting = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${state.message}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<ClientBloc, ClientState>(
                    builder: (context, state) {
                      if (state is ClientLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading clients...',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      } else if (state is ClientsLoaded) {
                        if (_filteredClients.isEmpty) {
                          return Center(
                            child: Container(
                              padding: AppThemeHelper.getCardPadding(context),
                              decoration: AppThemeHelper.getCardDecoration(context),
                              margin: AppThemeHelper.getStandardPadding(context),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _searchController.text.isNotEmpty 
                                        ? Icons.search_off 
                                        : Icons.people_outline,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isNotEmpty
                                        ? AppStrings.noClientsFound
                                        : AppStrings.noClientsFound,
                                    style: AppThemeHelper.getHeadlineStyle(context),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _searchController.text.isNotEmpty
                                        ? AppStrings.tryAdjustingSearchTerms
                                        : AppStrings.addYourFirstClient,
                                    style: AppThemeHelper.getBodyStyle(context),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        return ListView.builder(
                          padding: AppThemeHelper.getStandardPadding(context),
                          itemCount: _filteredClients.length,
                          itemBuilder: (context, index) {
                            final client = _filteredClients[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: AppThemeHelper.getCardDecoration(context),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClientOrdersPage(client: client),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: AppThemeHelper.getCardPadding(context),
                                    child: Row(
                                      children: [
                                        // Avatar
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: AppThemeHelper.getCustomTheme(context).primaryGradient,
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: Center(
                                            child: Text(
                                              client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                client.name,
                                                style: AppThemeHelper.getTitleStyle(context),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                client.phoneNumber,
                                                style: AppThemeHelper.getBodyStyle(context),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey[400],
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state is ClientError) {
                        return Center(
                          child: Container(
                            padding: AppThemeHelper.getCardPadding(context),
                            decoration: AppThemeHelper.getCardDecoration(context),
                            margin: AppThemeHelper.getStandardPadding(context),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppStrings.errorLoadingClients,
                                  style: AppThemeHelper.getHeadlineStyle(context),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.message,
                                  style: AppThemeHelper.getBodyStyle(context),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<ClientBloc>().add(LoadClients());
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: Text(AppStrings.retry),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: BlocBuilder<ClientBloc, ClientState>(
          builder: (context, clientState) {
            if (clientState is ClientsLoaded) {
              return BlocBuilder<OrderBloc, OrderState>(
                builder: (context, orderState) {
                  if (orderState is OrdersLoaded) {
                    final clientsToDelete = _getClientsWithAllOrdersReceived(_allClients, orderState.orders);
                    if (clientsToDelete.isNotEmpty) {
                      return FloatingActionButton.extended(
                        heroTag: "delete_clients_button",
                        onPressed: _isDeleting ? null : () => _showDeleteConfirmation(clientsToDelete),
                        backgroundColor: _isDeleting ? Colors.grey : Colors.red,
                        foregroundColor: Colors.white,
                        icon: _isDeleting 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.delete_sweep),
                        label: Text(_isDeleting ? 'Deleting...' : '${AppStrings.delete} ${clientsToDelete.length}'),
                      );
                    }
                  }
                  // No add button if no clients to delete
                  return const SizedBox.shrink();
                },
              );
            }
            // No add button if not loaded
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  List<Client> _getClientsWithAllOrdersReceived(List<Client> clients, List<Order> orders) {
    return clients.where((client) {
      // Find all orders that include this client by name and phone number
      final clientOrders = orders.where((order) =>
        order.clients.any((orderClient) => 
          orderClient.name == client.name && 
          orderClient.phoneNumber == client.phoneNumber
        )
      );
      // For each order, check if this client's isReceived is true
      return clientOrders.isNotEmpty && clientOrders.every((order) {
        final orderClient = order.clients.firstWhere(
          (c) => c.name == client.name && c.phoneNumber == client.phoneNumber,
          orElse: () => throw Exception('Client not found in order')
        );
        return orderClient.isReceived;
      });
    }).toList();
  }

  void _showDeleteConfirmation(List<Client> clients) async {
    try {
      if (clients.length == 1) {
        // Only one client, simple confirmation
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Client'),
            content: Text('Are you sure you want to delete ${clients.first.name}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
            ],
          ),
        );
        if (confirm == true) {
          context.read<ClientBloc>().add(DeleteClient(clients.first.id));
        }
      } else {
        // Multiple clients, let user select
        List<Client> selected = List.from(clients);
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: Text('Select Clients to Delete'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: clients.map((client) {
                      final isSelected = selected.contains(client);
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(client.name),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              selected.add(client);
                            } else {
                              selected.remove(client);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                  TextButton(
                    onPressed: selected.isEmpty ? null : () => Navigator.pop(context, true),
                    child: Text('Delete'),
                  ),
                ],
              ),
            );
          },
        );
        if (confirm == true && selected.isNotEmpty) {
          // Show final confirmation
          final reallyDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Confirm Delete'),
              content: Text('Are you sure you want to delete ${selected.length} clients?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
              ],
            ),
          );
          if (reallyDelete == true) {
            try {
              // Use DeleteClientsByNameAndPhone event
              final clientMaps = selected.map((c) => <String, String>{
                'name': c.name,
                'phoneNumber': c.phoneNumber,
              }).toList();
              
              print('Dispatching DeleteClientsByNameAndPhone with ${clientMaps.length} clients'); // Debug print
              context.read<ClientBloc>().add(DeleteClientsByNameAndPhone(clientMaps));
            } catch (e) {
              print('Error in delete confirmation: $e'); // Debug print
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error preparing delete: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error in _showDeleteConfirmation: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error showing delete confirmation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 
} 