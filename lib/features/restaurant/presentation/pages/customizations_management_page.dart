import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../../../menu/presentation/viewmodels/customizations_view_model.dart';

class CustomizationsManagementPage extends ConsumerStatefulWidget {
  const CustomizationsManagementPage({super.key});

  @override
  ConsumerState<CustomizationsManagementPage> createState() =>
      _CustomizationsManagementPageState();
}

class _CustomizationsManagementPageState
    extends ConsumerState<CustomizationsManagementPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref.read(customizationsNotifierProvider.notifier).loadOptions(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(customizationsNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customizationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customizations'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: switch (state) {
        CustomizationsInitial() || CustomizationsLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        CustomizationsError(:final message) => Center(
          child: Text('Error: $message'),
        ),
        CustomizationsLoaded(
          :final options,
          :final isLoadingMore,
          :final currentPage,
          :final totalPages,
        ) =>
          _buildCustomizationList(
            options,
            isLoadingMore,
            currentPage < totalPages,
          ),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomizationDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCustomizationList(
    List<CustomizationOptionEntity> options,
    bool isLoadingMore,
    bool hasMore,
  ) {
    if (options.isEmpty) {
      return const Center(child: Text('No customization options found.'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: options.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == options.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final option = options[index];
        return Card(
          child: ListTile(
            title: Text(
              option.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('\$${option.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: option.isActive,
                  onChanged: (val) {
                    ref
                        .read(customizationsNotifierProvider.notifier)
                        .updateOption(option.id, {'isActive': val});
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: () => _confirmDeleteOption(option),
                ),
              ],
            ),
            onTap: () => _showEditCustomizationDialog(option),
          ),
        );
      },
    );
  }

  void _showAddCustomizationDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Customization'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Option Name'),
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
                  .read(customizationsNotifierProvider.notifier)
                  .createOption({
                    'name': nameController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'isActive': true,
                  });
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCustomizationDialog(CustomizationOptionEntity option) {
    final nameController = TextEditingController(text: option.name);
    final priceController = TextEditingController(
      text: option.price.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Customization'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Option Name'),
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
                  .read(customizationsNotifierProvider.notifier)
                  .updateOption(option.id, {
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

  void _confirmDeleteOption(CustomizationOptionEntity option) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customization'),
        content: Text('Are you sure you want to delete "${option.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final success = await ref
                  .read(customizationsNotifierProvider.notifier)
                  .deleteOption(option.id);
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
