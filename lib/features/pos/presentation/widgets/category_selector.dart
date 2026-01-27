import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../providers/pos_provider.dart';
import '../providers/pos_state.dart';

class CategorySelector extends ConsumerWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final categories = state.categories;
    final bool isMobile = Device.width <= 600;

    if (isMobile) {
      return _buildHorizontalList(context, ref, categories, state);
    }

    return _buildVerticalList(context, ref, categories, state);
  }

  Widget _buildVerticalList(
    BuildContext context,
    WidgetRef ref,
    List<CategoryEntity> categories,
    PosState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
          final isSelected = isAll
              ? state.selectedCategory == null
              : state.selectedCategory?.id == category?.id;

          final Color categoryColor = isAll
              ? AppColors.primary
              : _hexToColor(category?.color);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: InkWell(
              onTap: () => _handleCategoryTap(ref, isAll, category),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? categoryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? categoryColor
                        : AppColors.border.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAll ? Icons.grid_view : Icons.category_outlined,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAll ? 'All' : (category?.name ?? ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalList(
    BuildContext context,
    WidgetRef ref,
    List<CategoryEntity> categories,
    PosState state,
  ) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
          final isSelected = isAll
              ? state.selectedCategory == null
              : state.selectedCategory?.id == category?.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(isAll ? 'All' : (category?.name ?? '')),
              selected: isSelected,
              onSelected: (_) => _handleCategoryTap(ref, isAll, category),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleCategoryTap(WidgetRef ref, bool isAll, CategoryEntity? category) {
    if (isAll) {
      ref.read(posNotifierProvider.notifier).selectCategory(null);
    } else {
      ref.read(posNotifierProvider.notifier).selectCategory(category);
    }
  }

  Color _hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return AppColors.primary;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return AppColors.primary;
    }
  }
}
