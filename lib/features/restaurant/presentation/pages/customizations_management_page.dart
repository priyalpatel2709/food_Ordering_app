import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../features/rbac/presentation/widgets/permission_guard.dart';
import '../../../../core/constants/permission_constants.dart';
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

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
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref
          .read(customizationsNotifierProvider.notifier)
          .loadOptions(search: query);
    });
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
        title: const Text(
          'Customizations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search customizations...',
                hintStyle: const TextStyle(fontSize: 15),
                prefixIcon: const Icon(Icons.search, size: 22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: switch (state) {
              CustomizationsInitial() || CustomizationsLoading() =>
                const Center(child: CircularProgressIndicator()),
              CustomizationsError(:final message) => Center(
                child: Text(
                  'Error: $message',
                  style: const TextStyle(fontSize: 15),
                ),
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
          ),
        ],
      ),
      floatingActionButton: PermissionGuard(
        permission: PermissionConstants.customizationCreate,
        child: FloatingActionButton(
          onPressed: () => _showAddCustomizationDialog(),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildCustomizationList(
    List<CustomizationOptionEntity> options,
    bool isLoadingMore,
    bool hasMore,
  ) {
    if (options.isEmpty) {
      return const Center(
        child: Text(
          'No customization options found.',
          style: TextStyle(fontSize: 15),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;

        if (crossAxisCount > 1) {
          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3.5,
            ),
            itemCount: options.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == options.length) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildCustomizationCard(options[index]);
            },
          );
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
            return _buildCustomizationCard(option);
          },
        );
      },
    );
  }

  Widget _buildCustomizationCard(CustomizationOptionEntity option) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          option.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '\$${option.price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PermissionGuard(
              permission: PermissionConstants.customizationUpdate,
              child: Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: option.isActive,
                  onChanged: (val) {
                    ref
                        .read(customizationsNotifierProvider.notifier)
                        .updateOption(option.id, {'isActive': val});
                  },
                ),
              ),
            ),
            PermissionGuard(
              permission: PermissionConstants.customizationDelete,
              child: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 22,
                ),
                onPressed: () => _confirmDeleteOption(option),
              ),
            ),
          ],
        ),
        onTap: () => _showEditCustomizationDialog(option),
      ),
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
            const SizedBox(height: 16),
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
            const SizedBox(height: 16.0),
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
