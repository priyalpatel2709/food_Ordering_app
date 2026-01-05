import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rbac_provider.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/entities/permission_entity.dart';

import '../widgets/permission_guard.dart';

class RoleManagementPage extends ConsumerWidget {
  const RoleManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesState = ref.watch(rolesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Role Management')),
      body: rolesState.when(
        data: (roles) => ListView.builder(
          itemCount: roles.length,
          itemBuilder: (context, index) {
            final role = roles[index];
            return ListTile(
              title: Text(role.name),
              subtitle: Text(
                '${role.description}\n${role.permissions.length} permissions • ${role.isSystem ? "System" : "Custom"}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                if (role.isSystem) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('System roles cannot be edited'),
                    ),
                  );
                  return;
                }
                // Check permission manually or let the UI handle it (e.g. guard the dialog)
                // For better UX, we show the dialog but maybe disable fields?
                // Or best: use PermissionGuard equivalent logic.
                // Here we simply allow opening. The user might get a 403 APIs if backend protects it.
                // But let's reuse _showCreateRoleDialog with the role.
                _showCreateRoleDialog(context, ref, role);
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: // PermissionGuard(
          // permission: 'ROLE.CREATE',
          // child:
          FloatingActionButton(
            onPressed: () => _showCreateRoleDialog(context, ref, null),
            child: const Icon(Icons.add),
          ),
      // ),
    );
  }

  void _showCreateRoleDialog(
    BuildContext context,
    WidgetRef ref,
    RoleEntity? role,
  ) {
    showDialog(
      context: context,
      builder: (context) => CreateRoleDialog(role: role),
    );
  }
}

class CreateRoleDialog extends ConsumerStatefulWidget {
  final RoleEntity? role;
  const CreateRoleDialog({super.key, this.role});

  @override
  ConsumerState<CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends ConsumerState<CreateRoleDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _selectedPermissions = {};

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      _nameController.text = widget.role!.name;
      _descriptionController.text = widget.role!.description; // Now supported
      _selectedPermissions.addAll(
        widget.role!.permissions.map((p) => p.id ?? ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionsAsync = ref.watch(permissionsProvider);
    final isEditing = widget.role != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Role' : 'Create Role'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Role Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Permissions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: permissionsAsync.when(
                data: (permissions) {
                  // Group permissions by module
                  final grouped = <String, List<PermissionEntity>>{};
                  for (final p in permissions) {
                    grouped.putIfAbsent(p.module, () => []).add(p);
                  }

                  return ListView(
                    shrinkWrap: true,
                    children: grouped.entries.map((entry) {
                      return ExpansionTile(
                        title: Text(entry.key),
                        children: entry.value.map((p) {
                          return CheckboxListTile(
                            title: Text(p.name),
                            subtitle: Text(p.description),
                            value: _selectedPermissions.contains(p.id),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedPermissions.add(p.id ?? '');
                                } else {
                                  _selectedPermissions.remove(p.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error loading permissions: $e'),
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
            final name = _nameController.text.trim();
            final desc = _descriptionController.text.trim();
            if (name.isEmpty) return;

            // Call API
            try {
              if (isEditing) {
                final updatedRole = await ref
                    .read(updateRoleUseCaseProvider)
                    .call(
                      widget.role!.id,
                      name,
                      desc,
                      _selectedPermissions.toList(),
                    );
                ref.read(rolesProvider.notifier).updateRole(updatedRole);
              } else {
                final newRole = await ref
                    .read(createRoleUseCaseProvider)
                    .call(name, desc, _selectedPermissions.toList());
                ref.read(rolesProvider.notifier).addRole(newRole);
              }

              if (context.mounted) Navigator.pop(context);
            } catch (e, st) {
              log(' Error: $e $st');
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
