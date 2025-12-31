import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/menu_entity.dart';
import '../viewmodels/menu_view_model.dart';

class MenuManagementPage extends ConsumerStatefulWidget {
  const MenuManagementPage({super.key});

  @override
  ConsumerState<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends ConsumerState<MenuManagementPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(menuNotifierProvider.notifier).loadCurrentMenu(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: switch (menuState) {
        MenuInitial() ||
        MenuLoading() => const Center(child: CircularProgressIndicator()),
        MenuError(:final message) => Center(child: Text('Error: $message')),
        MenuLoaded(:final menus) => _buildMenuList(menus),
      },
    );
  }

  Widget _buildMenuList(List<MenuEntity> menus) {
    if (menus.isEmpty) {
      return const Center(child: Text('No menus found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              menu.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(menu.description),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showGeneralUpdateDialog(menu),
                          icon: const Icon(Icons.edit),
                          label: const Text('General Info'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAdvancedUpdateDialog(menu),
                          icon: const Icon(Icons.settings),
                          label: const Text('Advanced Rules'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGeneralUpdateDialog(MenuEntity menu) {
    final nameController = TextEditingController(text: menu.name);
    final descController = TextEditingController(text: menu.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update General Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Menu Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
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
              final navigator = Navigator.of(context);
              final result = await ref.read(updateMenuUseCaseProvider).call(
                menu.id,
                {
                  'name': nameController.text,
                  'description': descController.text,
                },
              );

              result.when(
                success: (_) {
                  navigator.pop();
                  ref.read(menuNotifierProvider.notifier).refresh();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Menu updated successfully!')),
                  );
                },
                failure: (f) {
                  ScaffoldMessenger.of(
                    this.context,
                  ).showSnackBar(SnackBar(content: Text('Error: $f')));
                },
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAdvancedUpdateDialog(MenuEntity menu) {
    // For demonstration, we'll implement a simple dialog that accepts common fields from the guide
    final timeSlotIdController = TextEditingController();
    final openTimeController = TextEditingController();
    final closeTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Rule Update'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update a specific Time Slot using array filters',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              TextField(
                controller: timeSlotIdController,
                decoration: const InputDecoration(labelText: 'Time Slot ID'),
              ),
              TextField(
                controller: openTimeController,
                decoration: const InputDecoration(
                  labelText: 'Open Time (HH:mm)',
                ),
              ),
              TextField(
                controller: closeTimeController,
                decoration: const InputDecoration(
                  labelText: 'Close Time (HH:mm)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final result = await ref
                  .read(updateMenuAdvancedUseCaseProvider)
                  .call(menu.id, {
                    'timeSlotId': timeSlotIdController.text,
                    'openTime': openTimeController.text,
                    'closeTime': closeTimeController.text,
                  });

              result.when(
                success: (_) {
                  navigator.pop();
                  ref.read(menuNotifierProvider.notifier).refresh();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Advanced rules updated!')),
                  );
                },
                failure: (f) {
                  ScaffoldMessenger.of(
                    this.context,
                  ).showSnackBar(SnackBar(content: Text('Error: $f')));
                },
              );
            },
            child: const Text('Update Rules'),
          ),
        ],
      ),
    );
  }
}
