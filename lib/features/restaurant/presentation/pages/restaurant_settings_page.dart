import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../viewmodels/restaurant_settings_view_model.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../../../../core/di/providers.dart';

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

  List<CategoryEntity> _allCategories = [];
  List<Map<String, dynamic>> _stations = [];
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    log('Does me');
    Future.microtask(() {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    // Load Settings - Authentication is handled by the data layer returning the user's restaurant
    // We pass a dummy ID because the GET endpoint doesn't use it, but the notifier expects one.
    // Ideally we'd refactor the notifier, but for now this works safely.
    ref.read(restaurantSettingsProvider.notifier).loadSettings('current');

    // Load Categories
    setState(() => _isLoadingCategories = true);
    final categoriesResult = await ref
        .read(getAllCategoriesUseCaseProvider)
        .call(limit: 1000);

    categoriesResult.when(
      success: (data) {
        if (mounted) {
          setState(() {
            _allCategories = data.items;
            _isLoadingCategories = false;
          });
        }
      },
      failure: (err) {
        if (mounted) {
          setState(() => _isLoadingCategories = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load categories: $err')),
          );
        }
      },
    );
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
    _phoneController.text = settings['phone'] ?? '';
    _emailController.text = settings['email'] ?? '';

    // Parse Stations
    if (settings['kdsConfiguration'] != null &&
        settings['kdsConfiguration']['stations'] != null) {
      final stationsList = settings['kdsConfiguration']['stations'] as List;
      _stations = stationsList
          .map((s) {
            return {
              'name': s['name'],
              'categories': (s['categories'] as List).map((c) {
                // Handle if category is object or ID
                if (c is Map) return c['_id'] ?? c['id'];
                return c.toString();
              }).toList(),
            };
          })
          .toList()
          .cast<Map<String, dynamic>>();
    }
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
                  final settings = settingsState.settings;
                  if (settings != null && settings['_id'] != null) {
                    final success = await ref
                        .read(restaurantSettingsProvider.notifier)
                        .updateSettings(settings['_id'], {
                          'name': _nameController.text,
                          'address': _addressController.text,
                          'phone': _phoneController.text,
                          'email': _emailController.text,
                          'kdsConfiguration': {
                            'stations': _stations,
                            'workflow':
                                settings['kdsConfiguration']?['workflow'] ??
                                ['new', 'preparing', 'ready', 'served'],
                          },
                        });
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings updated successfully'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Error: Restaurant ID not found in settings',
                        ),
                      ),
                    );
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

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // KDS Stations Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'KDS Stations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showStationDialog(),
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (_isLoadingCategories)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_stations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No stations configured. Add one to enable KDS routing.',
                      ),
                    )
                  else
                    ..._stations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final station = entry.value;
                      final categoryIds = (station['categories'] as List)
                          .map((e) => e.toString())
                          .toList();
                      final categoryNames = _allCategories
                          .where((c) => categoryIds.contains(c.id))
                          .map((c) => c.name)
                          .join(', ');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            station['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            categoryNames.isEmpty
                                ? 'No Categories'
                                : categoryNames,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showStationDialog(
                                  index: index,
                                  station: station,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _stations.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }

  void _showStationDialog({int? index, Map<String, dynamic>? station}) {
    final nameCtrl = TextEditingController(text: station?['name']);

    // Ensure ids are strings
    List<String> selectedCategoryIds = [];
    if (station != null && station['categories'] != null) {
      selectedCategoryIds = (station['categories'] as List)
          .map((e) => e.toString())
          .toList();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(index == null ? 'Add Station' : 'Edit Station'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Station Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Assigned Categories:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _allCategories.length,
                      itemBuilder: (ctx, i) {
                        final cat = _allCategories[i];
                        final isSelected = selectedCategoryIds.contains(cat.id);
                        return CheckboxListTile(
                          title: Text(cat.name),
                          value: isSelected,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                selectedCategoryIds.add(cat.id);
                              } else {
                                selectedCategoryIds.remove(cat.id);
                              }
                            });
                          },
                        );
                      },
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
              TextButton(
                onPressed: () {
                  if (nameCtrl.text.isEmpty) return;

                  setState(() {
                    final newStation = {
                      'name': nameCtrl.text,
                      'categories': selectedCategoryIds,
                    };

                    if (index != null) {
                      _stations[index] = newStation;
                    } else {
                      _stations.add(newStation);
                    }
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
