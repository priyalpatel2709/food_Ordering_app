import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rbac_provider.dart';
import '../../../../features/authentication/presentation/providers/auth_provider.dart';
import '../../../../core/di/providers.dart';
import '../../../../features/authentication/domain/entities/user_entity.dart';
import '../../domain/entities/role_entity.dart';
import '../widgets/permission_guard.dart'; // Import PermissionGuard

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffState = ref.watch(staffUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Management')),
      body: staffState.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(user.name.isNotEmpty ? user.name[0] : '?'),
              ),
              title: Text(user.name),
              subtitle: Text(
                '${user.email}\nRoles: ${user.roles.map((r) => r.name).join(", ")}',
              ),
              isThreeLine: true,
              trailing: // PermissionGuard(
                  // Guard Assign Role button
                  // permission: 'USER.UPDATE',
                  // child:
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showAssignRoleDialog(context, ref, user),
                    tooltip: 'Assign Role',
                  ),
              // ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: // PermissionGuard(
          // Guard Add Staff button
          // permission: 'USER.CREATE',
          // child:
          FloatingActionButton(
            onPressed: () => _showAddStaffDialog(context, ref),
            child: const Icon(Icons.person_add),
          ),
      // ),
    );
  }

  void _showAssignRoleDialog(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AssignRoleDialog(user: user),
    );
  }

  void _showAddStaffDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => const AddStaffDialog());
  }
}

class AssignRoleDialog extends ConsumerStatefulWidget {
  final UserEntity user;
  const AssignRoleDialog({super.key, required this.user});

  @override
  ConsumerState<AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends ConsumerState<AssignRoleDialog> {
  final Set<String> _selectedRoleIds = {};

  @override
  void initState() {
    super.initState();
    // Pre-select existing roles
    _selectedRoleIds.addAll(widget.user.roles.map((r) => r.id));
  }

  @override
  Widget build(BuildContext context) {
    // We need roles to select from
    final rolesAsync = ref.watch(rolesProvider);

    return AlertDialog(
      title: Text('Assign Roles to ${widget.user.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: rolesAsync.when(
          data: (roles) => ListView.builder(
            shrinkWrap: true,
            itemCount: roles.length,
            itemBuilder: (context, index) {
              final role = roles[index];
              return CheckboxListTile(
                title: Text(role.name),
                subtitle: Text(role.isSystem ? 'System Role' : 'Custom Role'),
                value: _selectedRoleIds.contains(role.id),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedRoleIds.add(role.id);
                    } else {
                      _selectedRoleIds.remove(role.id);
                    }
                  });
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Error loading roles: $e'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await ref
                  .read(assignRoleUseCaseProvider)
                  .call(widget.user.id, _selectedRoleIds.toList());

              // Refresh staff list to show updated roles
              ref.refresh(staffUsersProvider);

              if (context.mounted) Navigator.pop(context);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Roles updated successfully')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class AddStaffDialog extends ConsumerStatefulWidget {
  const AddStaffDialog({super.key});

  @override
  ConsumerState<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends ConsumerState<AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Staff'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v?.isNotEmpty == true ? null : 'Required',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) =>
                  v?.contains('@') == true ? null : 'Invalid email',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (v) =>
                  v != null && v.length >= 6 ? null : 'Min 6 chars',
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
          onPressed: _isLoading ? null : _createStaff,
          child: _isLoading
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createStaff() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // final authState = ref.read(authNotifierProvider);
      // String? restaurantId;
      // if (authState is AuthAuthenticated) {
      //   restaurantId = authState.user.restaurantsId;
      // }

      // if (restaurantId == null) {
      //   throw Exception("Current user has no restaurant ID");
      // }

      await ref
          .read(signUpUseCaseProvider)
          .execute(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            restaurantId: 'restaurant_123',
          );

      // Refresh staff list
      ref.refresh(staffUsersProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
