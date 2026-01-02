import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../../../menu/presentation/viewmodels/menu_view_model.dart';
import '../../../menu/presentation/viewmodels/categories_view_model.dart';
import '../../../menu/presentation/viewmodels/customizations_view_model.dart';
import '../../../../features/tax/presentation/providers/tax_provider.dart';

class AddItemPage extends ConsumerStatefulWidget {
  const AddItemPage({super.key});

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategoryId;
  String? _selectedTaxId;
  final List<String> _selectedCustomizationIds = [];
  final List<String> _allergens = [];
  final List<Map<String, String>> _metaData = [];

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _minQtyController = TextEditingController(text: '1');
  final _maxQtyController = TextEditingController(text: '99');
  final _allergensController = TextEditingController();

  // For MetaData
  final _metaKeyController = TextEditingController();
  final _metaValueController = TextEditingController();

  bool _isAvailable = true;
  bool _taxable = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _prepTimeController.dispose();
    _minQtyController.dispose();
    _maxQtyController.dispose();
    _allergensController.dispose();
    _metaKeyController.dispose();
    _metaValueController.dispose();
    super.dispose();
  }

  void _addMetaData() {
    if (_metaKeyController.text.isNotEmpty &&
        _metaValueController.text.isNotEmpty) {
      setState(() {
        _metaData.add({
          'key': _metaKeyController.text,
          'value': _metaValueController.text,
        });
        _metaKeyController.clear();
        _metaValueController.clear();
      });
    }
  }

  void _removeMetaData(int index) {
    setState(() {
      _metaData.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isSubmitting = true);

    // Parse allergens from text if not added via list (optional logic)
    if (_allergensController.text.isNotEmpty && _allergens.isEmpty) {
      _allergens.addAll(
        _allergensController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );
    } else if (_allergensController.text.isNotEmpty) {
      // Append
      _allergens.addAll(
        _allergensController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty && !_allergens.contains(e)),
      );
    }

    final itemData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'image': _imageController.text.isNotEmpty
          ? _imageController.text
          : 'https://via.placeholder.com/150',
      'isAvailable': _isAvailable,
      'preparationTime': int.tryParse(_prepTimeController.text) ?? 0,
      'taxable': _taxable,
      'minOrderQuantity': int.tryParse(_minQtyController.text) ?? 1,
      'maxOrderQuantity': int.tryParse(_maxQtyController.text) ?? 99,
      'category': _selectedCategoryId,
      'allergens': _allergens,
      'customizationOptions': _selectedCustomizationIds,
      'metaData': _metaData,
      if (_selectedTaxId != null) 'taxRate': _selectedTaxId,
    };

    // The addItem use case might expect a menuId, but in this architecture,
    // it likely uses the selected category's menu ID or the backend handles it.
    // However, the signature is addItem(String menuId, Map itemData).
    // We need the menuId of the selected category.
    // Let's find the category entity to get the menuId?
    // Wait, CategoryEntity doesn't store menuId.
    // The previous implementation used `_selectedMenuId` from `widget.category.first.id`.
    // But CategoryEntity usually belongs to a Menu.
    // If the API requires `menuId`, we need to know which menu the category belongs to.
    // OR, maybe the API `addItem` actually takes `categoryId` inside the body and we just need a valid menuId for the URL?
    // Let's assume we can get menuId from somewhere or we need to select a menu first?
    // In the previous code: `widget.category` was passed.
    // AND `_selectedMenuId = widget.category.first.id;` -> This implies category object had ID, but maybe it was assumed that passed categories belong to a specific menu.
    // ACTUALLY, `loadMenus` loads `MenuEntity` which contains `categories`.
    // If we only have `CategoryEntity`, we don't know the `MenuEntity` ID easily unless we replicate the logic.
    // Implementation Detail: `addItem` in `MenuNotifier` calls `addItemToMenuUseCase`.
    // We need `menuId`.
    // Solution: Read `MenuNotifier` which contains `MenuLoaded` state with menus.
    // Find the menu that contains the selected category.

    final menuState = ref.read(menuNotifierProvider);
    String? derivedMenuId;
    if (menuState is MenuLoaded) {
      for (final menu in menuState.menus) {
        if (menu.categories.any((c) => c.id == _selectedCategoryId)) {
          derivedMenuId = menu.id;
          break;
        }
      }
    }

    // if (derivedMenuId == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text(
    //         'Error: Could not determine Menu ID for selected category',
    //       ),
    //     ),
    //   );
    //   setState(() => _isSubmitting = false);
    //   return;
    // }

    final success = await ref
        .read(menuNotifierProvider.notifier)
        .addItem(itemData);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add item')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesNotifierProvider);
    final customizationsState = ref.watch(customizationsNotifierProvider);
    final taxState = ref.watch(taxNotifierProvider);

    // We also need MenuLoaded to link category to menu if needed, OR just CategoriesLoaded if we rely on global categories.
    // NOTE: To safely find MenuID, we should probably watch MenuNotifier too, or assume Categories have MenuID (they don't in entity definition).
    // Let's watch MenuNotifier for the lookup logic in `_submit`.
    ref.watch(menuNotifierProvider);

    List<CategoryEntity> categories = [];
    if (categoriesState is CategoriesLoaded) {
      categories = categoriesState.categories;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Choose category',
              ),
              items: categories.map((cat) {
                return DropdownMenuItem(value: cat.id, child: Text(cat.name));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
              validator: (val) => val == null ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Item Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Prep Time (min)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minQtyController,
                    decoration: const InputDecoration(
                      labelText: 'Min Qty',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxQtyController,
                    decoration: const InputDecoration(
                      labelText: 'Max Qty',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Allergens',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _allergensController,
              decoration: const InputDecoration(
                labelText: 'Allergens (comma separated)',
                border: OutlineInputBorder(),
                hintText: 'e.g. Nuts, Dairy, Soy',
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Tax & Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (taxState is TaxLoaded)
              DropdownButtonFormField<String>(
                value: _selectedTaxId,
                decoration: const InputDecoration(
                  labelText: 'Tax Rate',
                  border: OutlineInputBorder(),
                ),
                items: taxState.taxes.map((tax) {
                  return DropdownMenuItem(
                    value: tax.id,
                    child: Text('${tax.name} (${tax.rate}%)'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedTaxId = val),
              ),

            SwitchListTile(
              title: const Text('Available'),
              value: _isAvailable,
              onChanged: (val) => setState(() => _isAvailable = val),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Taxable'),
              value: _taxable,
              onChanged: (val) => setState(() => _taxable = val),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),
            const Text(
              'Customization Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (customizationsState is CustomizationsLoaded)
              Wrap(
                spacing: 8,
                children: customizationsState.options.map((option) {
                  final isSelected = _selectedCustomizationIds.contains(
                    option.id,
                  );
                  return FilterChip(
                    label: Text(option.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCustomizationIds.add(option.id);
                        } else {
                          _selectedCustomizationIds.remove(option.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),
            const Text(
              'Metadata',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _metaKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Key',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _metaValueController,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: _addMetaData,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _metaData.length,
              itemBuilder: (context, index) {
                final item = _metaData[index];
                return ListTile(
                  title: Text(item['key'] ?? ''),
                  subtitle: Text(item['value'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _removeMetaData(index),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add Item', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
