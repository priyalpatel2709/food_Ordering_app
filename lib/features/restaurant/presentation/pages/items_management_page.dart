import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../../../menu/presentation/viewmodels/items_view_model.dart';
import '../../../menu/presentation/viewmodels/menu_view_model.dart';

class ItemsManagementPage extends ConsumerStatefulWidget {
  const ItemsManagementPage({super.key});

  @override
  ConsumerState<ItemsManagementPage> createState() =>
      _ItemsManagementPageState();
}

class _ItemsManagementPageState extends ConsumerState<ItemsManagementPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(itemsNotifierProvider.notifier).loadItems(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsState = ref.watch(itemsNotifierProvider);
    final menuState = ref.watch(menuNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Items Management'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: switch (itemsState) {
        ItemsInitial() ||
        ItemsLoading() => const Center(child: CircularProgressIndicator()),
        ItemsError(:final message) => Center(child: Text('Error: $message')),
        ItemsLoaded(:final items) => _buildItemList(items),
      },

      floatingActionButton: switch (menuState) {
        MenuLoaded(:final menus) => FloatingActionButton(
          onPressed: () => context.push(RouteConstants.addItem, extra: menus),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        ),
        _ => FloatingActionButton(
          onPressed: () {
            ref.read(menuNotifierProvider.notifier).loadCurrentMenu();
          },
          child: const Icon(Icons.refresh),
        ),
      },
    );
  }

  Widget _buildItemList(List<MenuItemEntity> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No items found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            leading: item.image.isNotEmpty
                ? Image.network(
                    item.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const CircleAvatar(child: Icon(Icons.fastfood)),
            title: Text(item.name),
            subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: item.isAvailable,
                  onChanged: (val) {
                    ref.read(itemsNotifierProvider.notifier).updateItem(
                      item.id,
                      {'isAvailable': val},
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: () => _confirmDeleteItem(item),
                ),
              ],
            ),
            onTap: () => _showEditItemDialog(item),
          ),
        );
      },
    );
  }

  void _showEditItemDialog(MenuItemEntity item) {
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(text: item.price.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item (Basic)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(itemsNotifierProvider.notifier)
                  .updateItem(item.id, {
                    'name': nameController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                  });
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteItem(MenuItemEntity item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final success = await ref
                  .read(itemsNotifierProvider.notifier)
                  .deleteItem(item.id);
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
