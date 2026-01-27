import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../dine_in/presentation/providers/dine_in_providers.dart';
import '../../../dine_in/domain/entities/table_entity.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/pos_provider.dart';

class TableSelectionDialog extends ConsumerWidget {
  const TableSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tablesProvider);
    final bool isDesktop = Device.width > 900;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isDesktop ? 60.w : 90.w,
        height: 70.h,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Table',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: tablesAsync.when(
                data: (tables) => GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 6 : 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: tables.length,
                  itemBuilder: (context, index) {
                    final table = tables[index];
                    return _TableGridItem(table: table);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableGridItem extends ConsumerWidget {
  final TableEntity table;

  const _TableGridItem({required this.table});

  Color get _statusColor {
    switch (table.status) {
      case TableStatus.available:
        return AppColors.success;
      case TableStatus.occupied:
        return AppColors.error;
      case TableStatus.ongoing:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDesktop = Device.width > 900;
    final posState = ref.watch(posNotifierProvider);
    final isSelected = posState.tableNumber == table.tableNumber;

    return InkWell(
      onTap: () {
        ref
            .read(posNotifierProvider.notifier)
            .selectTable(
              table.tableNumber,
              orderId: table.status == TableStatus.ongoing
                  ? table.currentOrderId
                  : null,
            );
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _statusColor.withOpacity(0.15) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _statusColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: _statusColor.withOpacity(0.2), blurRadius: 4)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant,
              color: _statusColor,
              size: isDesktop ? 2.w : 24.sp,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'T-${table.tableNumber}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: isSelected ? _statusColor : AppColors.textPrimary,
              ),
            ),
            Text(
              table.status.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10.sp,
                color: _statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
