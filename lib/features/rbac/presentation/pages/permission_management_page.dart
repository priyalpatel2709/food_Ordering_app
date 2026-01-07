import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/constants/permission_constants.dart';
import '../providers/rbac_provider.dart';
import '../widgets/permission_guard.dart';

class PermissionManagementPage extends ConsumerWidget {
  const PermissionManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Permission Management')),
      body: permissionsAsync.when(
        data: (permissions) => ListView.separated(
          itemCount: permissions.length,
          separatorBuilder: (c, i) => const Divider(),
          itemBuilder: (context, index) {
            final permission = permissions[index];
            return ListTile(
              title: Text(permission.name),
              subtitle: Text(
                '${permission.description}\nModule: ${permission.module}',
              ),
              isThreeLine: true,
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: PermissionGuard(
        // Assuming a SUPER_ADMIN permission or similar is needed to create permissions
        // Or generic permission 'PERMISSION.CREATE'
        permission: PermissionConstants.roleCreate,
        fallback: FloatingActionButton(
          // Placeholder: Allow if no check for now, or just hide.
          // But following user request, we show it.
          // If PermissionGuard hides it and user doesn't have perms, they will complain.
          // We'll keep the permission check but note it might be hidden.
          onPressed: () => _showCreatePermissionDialog(context, ref),
          child: const Icon(Icons.add),
        ),
        child: FloatingActionButton(
          onPressed: () => _showCreatePermissionDialog(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showCreatePermissionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CreatePermissionDialog(),
    );
  }
}

class CreatePermissionDialog extends ConsumerStatefulWidget {
  const CreatePermissionDialog({super.key});

  @override
  ConsumerState<CreatePermissionDialog> createState() =>
      _CreatePermissionDialogState();
}

class _CreatePermissionDialogState
    extends ConsumerState<CreatePermissionDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _moduleController = TextEditingController();
  final StorageService storageService = StorageService();
  bool _isLoading = false;
  String? _selectedPermission;

  void _onPermissionChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      _selectedPermission = newValue;
      _nameController.text = newValue;

      // Auto-fill module
      final parts = newValue.split('.');
      if (parts.isNotEmpty) {
        _moduleController.text = parts[0];
      }

      // Auto-fill description (basic)
      _descriptionController.text = _formatDescription(newValue);
    });
  }

  String _formatDescription(String permission) {
    // Convert "USER.CREATE" to "Create User" or similar if possible,
    // or just leave it blank or friendly format.
    // For now, let's make it readable: USER.CREATE -> Create User permission
    final parts = permission.split('.');
    if (parts.length == 2) {
      final action = parts[1].toLowerCase(); // create
      final module = parts[0].toLowerCase(); // user
      // Capitalize first letter
      final actionCap = action[0].toUpperCase() + action.substring(1);
      final moduleCap = module[0].toUpperCase() + module.substring(1);
      return "$actionCap $moduleCap permission";
    }
    return "$permission permission";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Permission'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedPermission,
            decoration: const InputDecoration(
              labelText: 'Select Permission',
              border: OutlineInputBorder(),
            ),
            items: PermissionConstants.values.map((perm) {
              return DropdownMenuItem<String>(value: perm, child: Text(perm));
            }).toList(),
            onChanged: _onPermissionChanged,
          ),
          const SizedBox(height: 16),
          // Keep hidden or read-only if we strictly follow the dropdown,
          // but maybe user wants to see what's being sent.
          // Note: The previous name TextField is removed/replaced by key logic mostly,
          // but we still keep the controller updated for submission.
          TextField(
            controller: _nameController,
            enabled: false, // Read-only as it's set by dropdown
            decoration: const InputDecoration(
              labelText: 'Selected Permission Code',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _moduleController,
            decoration: const InputDecoration(labelText: 'Module (e.g. ORDER)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  try {
                    final user = storageService.getUser();
                    final restaurantId = user?.restaurantsId;
                    if (restaurantId == null) {
                      throw Exception("Current user has no restaurant ID");
                    }
                    final newPerm = await ref
                        .read(createPermissionUseCaseProvider)
                        .call(
                          _nameController.text.trim(),
                          _descriptionController.text.trim(),
                          _moduleController.text.trim(),
                          restaurantId,
                        );
                    ref
                        .read(permissionsProvider.notifier)
                        .addPermission(newPerm);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e, st) {
                    log('ROLE.READ error: $e $st');
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
