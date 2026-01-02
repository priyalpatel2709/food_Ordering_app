import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../../../menu/presentation/viewmodels/menu_view_model.dart';

class AddItemPage extends ConsumerStatefulWidget {
  final List<MenuEntity> menus;
  const AddItemPage({super.key, required this.menus});

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedMenuId;
  String? _selectedCategoryId;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _minQtyController = TextEditingController(text: '1');
  final _maxQtyController = TextEditingController(text: '99');

  bool _isAvailable = true;
  bool _taxable = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.menus.isNotEmpty) {
      _selectedMenuId = widget.menus.first.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _prepTimeController.dispose();
    _minQtyController.dispose();
    _maxQtyController.dispose();
    super.dispose();
  }

  List<CategoryEntity> get _availableCategories {
    if (_selectedMenuId == null) return [];
    final menu = widget.menus.firstWhere((m) => m.id == _selectedMenuId);
    return menu.categories;
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
      'allergens': [],
      'customizationOptions': [],
      'metaData': [],
    };

    final success = await ref
        .read(menuNotifierProvider.notifier)
        .addItem(_selectedMenuId!, itemData);

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
              items: _availableCategories.map((cat) {
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
          ],
        ),
      ),
    );
  }
}
