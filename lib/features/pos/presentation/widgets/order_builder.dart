import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/pos_provider.dart';

class OrderBuilder extends ConsumerWidget {
  const OrderBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final items = state.cartItems;
    final bool isDesktop = Device.width > 900;

    return Column(
      children: [
        // Order Header
        Container(
          padding: EdgeInsets.all(isDesktop ? 1.w : 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Order',
                style: TextStyle(
                  fontSize: isDesktop ? 15.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                style: TextStyle(
                  fontSize: isDesktop ? 12.sp : 13.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Items List
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: EdgeInsets.all(isDesktop ? 1.w : 16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quantity & Controls
                          Column(
                            children: [
                              _buildSquareButton(
                                icon: Icons.add,
                                color: AppColors.primary,
                                isDesktop: isDesktop,
                                onTap: () => ref
                                    .read(posNotifierProvider.notifier)
                                    .incrementQuantity(item.id),
                              ),
                              SizedBox(height: 0.5.h),
                              Container(
                                width: isDesktop ? 2.w : 32,
                                height: isDesktop ? 2.w : 32,
                                alignment: Alignment.center,
                                child: Text(
                                  item.quantity.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isDesktop ? 14.sp : 16.sp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              _buildSquareButton(
                                icon: Icons.remove,
                                color: AppColors.textSecondary,
                                isDesktop: isDesktop,
                                onTap: () => ref
                                    .read(posNotifierProvider.notifier)
                                    .decrementQuantity(item.id),
                              ),
                            ],
                          ),

                          SizedBox(width: 1.w),

                          // Item Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.menuItemName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isDesktop ? 14.sp : 15.sp,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 0.2.h),
                                if (item.selectedCustomizations.isNotEmpty)
                                  ...item.selectedCustomizations.map(
                                    (c) => Text(
                                      '+ ${c.name} (\$${c.price.toStringAsFixed(2)})',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 12.sp : 13.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.edit_note,
                                    size: isDesktop ? 1.2.w : 14,
                                  ),
                                  label: Text(
                                    'Add Note',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 12.sp : 13.sp,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 1.w),

                          // Price & Remove
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${(item.pricePerItem * item.quantity).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isDesktop ? 14.sp : 16.sp,
                                ),
                              ),
                              IconButton(
                                onPressed: () => ref
                                    .read(posNotifierProvider.notifier)
                                    .removeItem(item.id),
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: isDesktop ? 1.5.w : 20,
                                  color: AppColors.error,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSquareButton({
    required IconData icon,
    required Color color,
    required bool isDesktop,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: isDesktop ? 2.w : 30,
        height: isDesktop ? 2.w : 30,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: isDesktop ? 1.2.w : 16, color: color),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 8.w,
            color: AppColors.grey300,
          ),
          const SizedBox(height: 16),
          Text(
            'Order is empty',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select products to start building',
            style: TextStyle(color: AppColors.textHint, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}
