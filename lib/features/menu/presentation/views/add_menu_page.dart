import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/menu_entity.dart';
import '../../presentation/viewmodels/menu_view_model.dart';
import '../../presentation/viewmodels/categories_view_model.dart';
import '../../presentation/viewmodels/items_view_model.dart';
import '../../../tax/presentation/providers/tax_provider.dart';

class AddMenuPage extends ConsumerStatefulWidget {
  final MenuEntity? menu;
  const AddMenuPage({super.key, this.menu});

  @override
  ConsumerState<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends ConsumerState<AddMenuPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isActive = true;
  final List<String> _selectedCategoryIds = [];
  final List<String> _selectedItemIds = [];
  final List<String> _selectedTaxIds = [];

  // Advanced Rules
  final List<MenuAvailability> _availableDays = [];
  final List<MetaDataEntity> _metaData = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoriesNotifierProvider.notifier).loadCategories(limit: 1000);
      ref.read(itemsNotifierProvider.notifier).loadItems(limit: 1000);
      ref.read(taxNotifierProvider.notifier).loadTaxes(limit: 1000);
    });

    if (widget.menu != null) {
      final menu = widget.menu!;
      _nameController.text = menu.name;
      _descriptionController.text = menu.description;
      _isActive = menu.isActive;
      _selectedCategoryIds.addAll(menu.categories.map((c) => c.id));
      _selectedItemIds.addAll(menu.items.map((i) => i.id));
      _selectedTaxIds.addAll(menu.taxes.map((t) => t.id));
      _availableDays.addAll(menu.availableDays);
      _metaData.addAll(menu.metaData);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    // Prepare Available Days logic
    final availableDaysMap = _availableDays.map((e) {
      return {
        'day': e.day,
        'timeSlots': e.timeSlots
            .map((t) => {'openTime': t.openTime, 'closeTime': t.closeTime})
            .toList(),
      };
    }).toList();

    // Prepare Items logic (Schema expects object with item ref)
    // Assuming backend can handle just IDs or we need to wrap
    // Based on schema: items: [{ item: ID }]
    final itemsList = _selectedItemIds.map((id) => {'item': id}).toList();

    final menuData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'isActive': _isActive,
      'categories': _selectedCategoryIds,
      'items': itemsList,
      'availableDays': availableDaysMap,
      'taxes': _selectedTaxIds,
      'metaData': _metaData
          .map((e) => {'key': e.key, 'value': e.value})
          .toList(),
      // 'discounts': [] // Todo: Add discount selection
    };

    bool success;
    if (widget.menu != null) {
      success = await ref
          .read(menuNotifierProvider.notifier)
          .updateMenu(widget.menu!.id, menuData);
    } else {
      success = await ref
          .read(menuNotifierProvider.notifier)
          .createMenu(menuData);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.menu != null
                  ? 'Menu updated successfully'
                  : 'Menu created successfully',
            ),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.menu != null
                  ? 'Failed to update menu'
                  : 'Failed to create menu',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menu != null ? 'Edit Menu' : 'Create Menu'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('General Info'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Menu Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Active'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Relations'),
              _buildCategorySelector(),
              const SizedBox(height: 16),
              _buildItemSelector(),
              const SizedBox(height: 16),
              _buildTaxSelector(),

              const SizedBox(height: 24),
              _buildSectionTitle('Availability'),
              _buildAvailabilityEditor(),

              const SizedBox(height: 24),
              _buildSectionTitle('Meta Data'),
              _buildMetaDataEditor(),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.menu != null ? 'Update Menu' : 'Create Menu',
                        ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categoriesState = ref.watch(categoriesNotifierProvider);

    if (categoriesState is! CategoriesLoaded)
      return const LinearProgressIndicator();

    return _MultiSelectDialogField(
      title: 'Categories',
      items: categoriesState.categories,
      selectedIds: _selectedCategoryIds,
      labelBuilder: (c) => c.name,
      onSelectionChanged: (ids) => setState(() {
        _selectedCategoryIds.clear();
        _selectedCategoryIds.addAll(ids);
      }),
    );
  }

  Widget _buildItemSelector() {
    final itemsState = ref.watch(itemsNotifierProvider);

    if (itemsState is! ItemsLoaded) return const LinearProgressIndicator();

    var items = itemsState.items;

    // Filter items based on selected categories
    if (_selectedCategoryIds.isNotEmpty) {
      items = items
          .where((i) => _selectedCategoryIds.contains(i.category.id))
          .toList();
    }

    return _MultiSelectDialogField(
      title: 'Items',
      items: items,
      selectedIds: _selectedItemIds,
      labelBuilder: (i) => '${i.name} (\$${i.price})',
      onSelectionChanged: (ids) => setState(() {
        _selectedItemIds.clear();
        _selectedItemIds.addAll(ids);
      }),
    );
  }

  Widget _buildTaxSelector() {
    final taxState = ref.watch(taxNotifierProvider);

    // Check TaxLoaded
    if (taxState is! TaxLoaded) {
      // Assuming TaxLoaded state is available from providers
      return const SizedBox.shrink();
    }

    return _MultiSelectDialogField(
      title: 'Taxes',
      items: taxState.taxes,
      selectedIds: _selectedTaxIds,
      labelBuilder: (t) => '${t.name} ({t.percentage}%)',
      onSelectionChanged: (ids) => setState(() {
        _selectedTaxIds.clear();
        _selectedTaxIds.addAll(ids);
      }),
    );
  }

  Widget _buildAvailabilityEditor() {
    return Column(
      children: [
        ..._availableDays.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Card(
            child: ListTile(
              title: Text(item.day),
              subtitle: Text(
                item.timeSlots
                    .map((t) => '${t.openTime}-${t.closeTime}')
                    .join(', '),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => _availableDays.removeAt(index)),
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _showAddAvailabilityDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Availability Rule'),
        ),
      ],
    );
  }

  void _showAddAvailabilityDialog() {
    String selectedDay = 'Monday';
    final openController = TextEditingController();
    final closeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Availability'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedDay,
              items: [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => selectedDay = val!,
            ),
            TextField(
              controller: openController,
              decoration: const InputDecoration(labelText: 'Open Time (HH:mm)'),
            ),
            TextField(
              controller: closeController,
              decoration: const InputDecoration(
                labelText: 'Close Time (HH:mm)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (openController.text.isNotEmpty &&
                  closeController.text.isNotEmpty) {
                setState(() {
                  _availableDays.add(
                    MenuAvailability(
                      day: selectedDay,
                      timeSlots: [
                        TimeSlot(
                          openTime: openController.text,
                          closeTime: closeController.text,
                        ),
                      ],
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaDataEditor() {
    return Column(
      children: [
        ..._metaData.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return ListTile(
            title: Text(item.key),
            subtitle: Text(item.value.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => setState(() => _metaData.removeAt(index)),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () {
            final keyController = TextEditingController();
            final valController = TextEditingController();
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Add Meta Data'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: keyController,
                      decoration: const InputDecoration(labelText: 'Key'),
                    ),
                    TextField(
                      controller: valController,
                      decoration: const InputDecoration(labelText: 'Value'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (keyController.text.isNotEmpty) {
                        setState(() {
                          // Assuming simple string value for now, or JSON parse if needed
                          _metaData.add(
                            MetaDataEntity(
                              id: DateTime.now().toString(),
                              key: keyController.text,
                              value: valController.text,
                            ),
                          );
                        });
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Meta Data'),
        ),
      ],
    );
  }
}

class _MultiSelectDialogField<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final List<String> selectedIds;
  final String Function(T) labelBuilder;
  final ValueChanged<List<String>> onSelectionChanged;

  const _MultiSelectDialogField({
    required this.title,
    required this.items,
    required this.selectedIds,
    required this.labelBuilder,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Helper to get ID. Assuming we can't reflect.
    // So we need an Id extractor or rely on T having id field (but generic T can't without interface).
    // We will assume T is dynamic or we accept a getId function.
    // For simplicity, let's just make T dynamic or create a helper.
    // Actually, I'll update the class to accept idBuilder.
    return InkWell(
      onTap: () => _showSelectionDialog(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          selectedIds.isEmpty
              ? 'Select $title'
              : '${selectedIds.length} selected',
        ),
      ),
    );
  }

  void _showSelectionDialog(BuildContext context) {
    final selected = Set<String>.from(selectedIds);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select $title'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    // We need to extract ID.
                    // To avoid casting issues, pass idBuilder.
                    // Or cheat: assume item has .id via dynamic.
                    final id = (item as dynamic).id;
                    final isSelected = selected.contains(id);
                    return CheckboxListTile(
                      title: Text(labelBuilder(item)),
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true)
                            selected.add(id);
                          else
                            selected.remove(id);
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onSelectionChanged(selected.toList());
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
