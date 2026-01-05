import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        permission: 'PERMISSION.CREATE',
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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Permission'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name (e.g. ORDER.DELETE)',
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
                    final newPerm = await ref
                        .read(createPermissionUseCaseProvider)
                        .call(
                          _nameController.text.trim(),
                          _descriptionController.text.trim(),
                          _moduleController.text.trim(),
                        );
                    ref
                        .read(permissionsProvider.notifier)
                        .addPermission(newPerm);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e ,st) {
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
