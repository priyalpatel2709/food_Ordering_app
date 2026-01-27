import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../providers/pos_provider.dart';

class ModifierDialog extends ConsumerStatefulWidget {
  final MenuItemEntity product;

  const ModifierDialog({super.key, required this.product});

  @override
  ConsumerState<ModifierDialog> createState() => _ModifierDialogState();
}

class _ModifierDialogState extends ConsumerState<ModifierDialog> {
  final List<CustomizationSelection> _selectedOptions = [];
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.product.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.primaryContainer,
                      child: const Icon(
                        Icons.restaurant,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 32),

            if (widget.product.customizationOptions.isNotEmpty) ...[
              Text(
                'Customizations',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.product.customizationOptions.map((opt) {
                  final isSelected = _selectedOptions.any(
                    (s) => s.id == opt.id,
                  );
                  return FilterChip(
                    label: Text('${opt.name} (+\$${opt.price})'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedOptions.add(
                            CustomizationSelection(
                              id: opt.id,
                              name: opt.name,
                              price: opt.price,
                            ),
                          );
                        } else {
                          _selectedOptions.removeWhere((s) => s.id == opt.id);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            Text(
              'Add Note / Special Instructions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. No onions, extra spicy...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.grey50,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(posNotifierProvider.notifier)
                          .addToCart(
                            widget.product,
                            customizations: List.from(_selectedOptions),
                          );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
