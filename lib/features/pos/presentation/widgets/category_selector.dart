import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../providers/pos_provider.dart';

class CategorySelector extends ConsumerWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final categories = state.categories;
    final bool isDesktop = Device.width > 900;

    return Container(
      height: isDesktop ? 8.h : 60,
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 1.5.w : 4.w),
        itemCount: categories.length + 1, // +1 for "All"
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
          final isSelected = isAll
              ? state.selectedCategory == null
              : state.selectedCategory?.id == category?.id;

          return Padding(
            padding: EdgeInsets.only(right: 1.w),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (isAll) {
                    ref
                        .read(posNotifierProvider.notifier)
                        .selectCategory(
                          const CategoryEntity(
                            id: 'all',
                            name: 'All',
                            description: '',
                            isActive: true,
                            displayOrder: 0,
                          ),
                        );
                  } else if (category != null) {
                    ref
                        .read(posNotifierProvider.notifier)
                        .selectCategory(category);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 2.w : 6.w,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isAll ? 'All Items' : (category?.name ?? ''),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textPrimary,
                      fontSize: isDesktop ? 14.sp : 15.sp,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
