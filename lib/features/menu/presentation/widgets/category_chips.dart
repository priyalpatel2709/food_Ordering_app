import 'package:flutter/material.dart';
import '../../domain/entities/menu_entity.dart';
import '../../../../shared/theme/app_colors.dart';

class CategoryChips extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Sort categories by display order
    final sortedCategories = List<CategoryEntity>.from(categories)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text(
                'All',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              selected: selectedCategoryId == null,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(null);
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.grey100,
              labelStyle: TextStyle(
                color: selectedCategoryId == null
                    ? AppColors.white
                    : AppColors.textPrimary,
              ),
              checkmarkColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: BorderSide.none,
            ),
          ),
          // Category chips
          ...sortedCategories.map((category) {
            final isSelected = selectedCategoryId == category.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onCategorySelected(category.id);
                  } else {
                    onCategorySelected(null);
                  }
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.grey100,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
                checkmarkColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                side: BorderSide.none,
              ),
            );
          }),
        ],
      ),
    );
  }
}
