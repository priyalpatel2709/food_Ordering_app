import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
    final bool isDesktop = Device.width > 900;
    // Sort categories by display order
    final sortedCategories = List<CategoryEntity>.from(categories)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return SizedBox(
      height: isDesktop ? 6.h : 6.5.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // "All" chip
          Padding(
            padding: EdgeInsets.only(right: 1.w),
            child: FilterChip(
              label: Text(
                'All',
                style: TextStyle(
                  fontSize: isDesktop ? 12.sp : 14.sp,
                  fontWeight: FontWeight.w600,
                ),
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
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 1.w : 12,
                vertical: isDesktop ? 0.5.h : 8,
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Category chips
          ...sortedCategories.map((category) {
            final isSelected = selectedCategoryId == category.id;
            return Padding(
              padding: EdgeInsets.only(right: 1.w),
              child: FilterChip(
                label: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: isDesktop ? 12.sp : 14.sp,
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
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 1.w : 12,
                  vertical: isDesktop ? 0.5.h : 8,
                ),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
