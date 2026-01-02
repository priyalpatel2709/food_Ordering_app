import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../viewmodels/restaurant_settings_view_model.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class RestaurantSettingsPage extends ConsumerStatefulWidget {
  const RestaurantSettingsPage({super.key});

  @override
  ConsumerState<RestaurantSettingsPage> createState() =>
      _RestaurantSettingsPageState();
}

class _RestaurantSettingsPageState
    extends ConsumerState<RestaurantSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authState = ref.read(authNotifierProvider);
      if (authState is AuthAuthenticated) {
        final user = authState.user;
        if (user.restaurantsId != null) {
          ref
              .read(restaurantSettingsProvider.notifier)
              .loadSettings(user.restaurantsId!);
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateControllers(Map<String, dynamic> settings) {
    _nameController.text = settings['name'] ?? '';
    _addressController.text = settings['address'] ?? '';
    _phoneController.text = settings['phoneNumber'] ?? '';
    _emailController.text = settings['email'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(restaurantSettingsProvider);

    ref.listen(restaurantSettingsProvider, (prev, next) {
      if (next.settings != null && prev?.settings == null) {
        _updateControllers(next.settings!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Settings'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (settingsState.settings != null)
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final authState = ref.read(authNotifierProvider);
                  if (authState is AuthAuthenticated) {
                    final user = authState.user;
                    if (user.restaurantsId != null) {
                      final success = await ref
                          .read(restaurantSettingsProvider.notifier)
                          .updateSettings(user.restaurantsId!, {
                            'name': _nameController.text,
                            'address': _addressController.text,
                            'phoneNumber': _phoneController.text,
                            'email': _emailController.text,
                          });
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Settings updated successfully'),
                          ),
                        );
                      }
                    }
                  }
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: settingsState.isLoading && settingsState.settings == null
          ? const Center(child: CircularProgressIndicator())
          : settingsState.error != null
          ? Center(child: Text('Error: ${settingsState.error}'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Restaurant Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
    );
  }
}
