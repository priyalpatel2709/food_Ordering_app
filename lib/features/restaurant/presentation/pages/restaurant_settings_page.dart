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
  final _cuisineController = TextEditingController();
  final _capacityController = TextEditingController();
  final _totalTablesController = TextEditingController();
  final _paymentMethodsController = TextEditingController();

  bool _isActive = true;
  bool _isVegetarianFriendly = false;
  bool _hasParking = false;
  bool _acceptsOnlineOrders = false;
  bool _acceptsReservations = false;

  final Map<String, Map<String, String>> _operatingHours = {
    'Monday': {'openTime': '09:00', 'closeTime': '22:00'},
    'Tuesday': {'openTime': '09:00', 'closeTime': '22:00'},
    'Wednesday': {'openTime': '09:00', 'closeTime': '22:00'},
    'Thursday': {'openTime': '09:00', 'closeTime': '22:00'},
    'Friday': {'openTime': '09:00', 'closeTime': '23:00'},
    'Saturday': {'openTime': '10:00', 'closeTime': '23:00'},
    'Sunday': {'openTime': '10:00', 'closeTime': '22:00'},
  };

  List<CategoryEntity> _allCategories = [];
  List<Map<String, dynamic>> _stations = [];
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
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
    _cuisineController.dispose();
    _capacityController.dispose();
    _totalTablesController.dispose();
    _paymentMethodsController.dispose();
    super.dispose();
  }

  void _updateControllers(Map<String, dynamic> settings) {
    _nameController.text = settings['name'] ?? '';
    _addressController.text = settings['address'] ?? '';
    _phoneController.text = settings['phone'] ?? '';
    _emailController.text = settings['email'] ?? '';

    _isActive = settings['isActive'] ?? true;
    _isVegetarianFriendly = settings['isVegetarianFriendly'] ?? false;
    _hasParking = settings['hasParking'] ?? false;
    _acceptsOnlineOrders = settings['acceptsOnlineOrders'] ?? false;
    _acceptsReservations = settings['acceptsReservations'] ?? false;

    _capacityController.text = (settings['capacity'] ?? '').toString();
    _totalTablesController.text =
        (settings['tableConfiguration']?['totalTables'] ?? '').toString();

    if (settings['cuisineType'] is List) {
      _cuisineController.text = (settings['cuisineType'] as List).join(', ');
    }

    if (settings['paymentMethods'] is List) {
      _paymentMethodsController.text = (settings['paymentMethods'] as List)
          .join(', ');
    }

    if (settings['operatingHours'] is Map) {
      final Map hours = settings['operatingHours'];
      hours.forEach((key, value) {
        // Simple case-insensitive match or direct match
        final dayKey = _operatingHours.keys.firstWhere(
          (k) => k.toLowerCase() == key.toString().toLowerCase(),
          orElse: () => '',
        );

        if (dayKey.isNotEmpty && value is Map) {
          _operatingHours[dayKey] = {
            'openTime': value['openTime']?.toString() ?? '09:00',
            'closeTime': value['closeTime']?.toString() ?? '22:00',
          };
        }
      });
    }

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
          // Show save button always (or if form is valid/dirty ideally)
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final settings = settingsState.settings;
                bool success;
                if (settings != null && settings['_id'] != null) {
                  success = await ref
                      .read(restaurantSettingsProvider.notifier)
                      .updateSettings(settings['_id'], {
                        'name': _nameController.text,
                        'address': _addressController.text,
                        'phone': _phoneController.text,
                        'email': _emailController.text,
                        'isActive': _isActive,
                        'capacity': int.tryParse(_capacityController.text) ?? 0,
                        'isVegetarianFriendly': _isVegetarianFriendly,
                        'hasParking': _hasParking,
                        'acceptsOnlineOrders': _acceptsOnlineOrders,
                        'acceptsReservations': _acceptsReservations,
                        'tableConfiguration': {
                          'totalTables':
                              int.tryParse(_totalTablesController.text) ?? 0,
                        },
                        'cuisineType': _cuisineController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList(),
                        'paymentMethods': _paymentMethodsController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList(),
                        'operatingHours': _operatingHours,
                        'kdsConfiguration': {
                          'stations': _stations,
                          'workflow':
                              settings['kdsConfiguration']?['workflow'] ??
                              ['new', 'start', 'prepared', 'ready'],
                        },
                      });
                } else {
                  // Create mode
                  success = await ref
                      .read(restaurantSettingsProvider.notifier)
                      .createSettings({
                        'name': _nameController.text,
                        'address': _addressController.text,
                        'phone': _phoneController.text,
                        'email': _emailController.text,
                        'isActive': _isActive,
                        'capacity': int.tryParse(_capacityController.text) ?? 0,
                        'isVegetarianFriendly': _isVegetarianFriendly,
                        'hasParking': _hasParking,
                        'acceptsOnlineOrders': _acceptsOnlineOrders,
                        'acceptsReservations': _acceptsReservations,
                        'tableConfiguration': {
                          'totalTables':
                              int.tryParse(_totalTablesController.text) ?? 0,
                        },
                        'cuisineType': _cuisineController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList(),
                        'paymentMethods': _paymentMethodsController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList(),
                        'operatingHours': _operatingHours,
                        'kdsConfiguration': {
                          'stations': _stations,
                          'workflow': ['new', 'start', 'prepared', 'ready'],
                        },
                      });
                }

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings saved successfully'),
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
          : settingsState.error != null && settingsState.settings == null
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
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Restaurant Is Active'),
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),

                  const Divider(),
                  const Text(
                    'Operational Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _totalTablesController,
                    decoration: const InputDecoration(
                      labelText: 'Total Tables',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cuisineController,
                    decoration: const InputDecoration(
                      labelText: 'Cuisine Types (comma separated)',
                      hintText: 'e.g. Italian, Mexican, Fast Food',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _paymentMethodsController,
                    decoration: const InputDecoration(
                      labelText: 'Payment Methods (comma separated)',
                      hintText: 'e.g. Cash, Credit Card, Apple Pay',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Vegetarian Friendly'),
                    value: _isVegetarianFriendly,
                    onChanged: (val) =>
                        setState(() => _isVegetarianFriendly = val),
                  ),
                  SwitchListTile(
                    title: const Text('Has Parking'),
                    value: _hasParking,
                    onChanged: (val) => setState(() => _hasParking = val),
                  ),
                  SwitchListTile(
                    title: const Text('Accepts Online Orders'),
                    value: _acceptsOnlineOrders,
                    onChanged: (val) =>
                        setState(() => _acceptsOnlineOrders = val),
                  ),
                  SwitchListTile(
                    title: const Text('Accepts Reservations'),
                    value: _acceptsReservations,
                    onChanged: (val) =>
                        setState(() => _acceptsReservations = val),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Operating Hours',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._operatingHours.keys.map((day) {
                    final times = _operatingHours[day]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: int.parse(
                                      times['openTime']!.split(':')[0],
                                    ),
                                    minute: int.parse(
                                      times['openTime']!.split(':')[1],
                                    ),
                                  ),
                                );
                                if (time != null) {
                                  setState(() {
                                    final hour = time.hour.toString().padLeft(
                                      2,
                                      '0',
                                    );
                                    final minute = time.minute
                                        .toString()
                                        .padLeft(2, '0');
                                    times['openTime'] = '$hour:$minute';
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(times['openTime']!),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('to'),
                          ),
                          Expanded(
                            flex: 3,
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: int.parse(
                                      times['closeTime']!.split(':')[0],
                                    ),
                                    minute: int.parse(
                                      times['closeTime']!.split(':')[1],
                                    ),
                                  ),
                                );
                                if (time != null) {
                                  setState(() {
                                    final hour = time.hour.toString().padLeft(
                                      2,
                                      '0',
                                    );
                                    final minute = time.minute
                                        .toString()
                                        .padLeft(2, '0');
                                    times['closeTime'] = '$hour:$minute';
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(times['closeTime']!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

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
