import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../domain/entities/cart_entity.dart';
import '../../../../shared/theme/app_colors.dart';

class CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Device.width > 900;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isDesktop ? 1.w : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Image
                Container(
                  width: isDesktop ? 6.w : 80,
                  height: isDesktop ? 6.w : 80,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                    image: item.menuItemImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(item.menuItemImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.menuItemImage.isEmpty
                      ? Icon(
                          Icons.restaurant,
                          size: isDesktop ? 2.w : 32,
                          color: AppColors.grey400,
                        )
                      : null,
                ),
                SizedBox(width: isDesktop ? 1.w : 12),
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.menuItemName,
                              style: TextStyle(
                                fontSize: isDesktop ? 14.sp : 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: onRemove,
                            icon: Icon(
                              Icons.close,
                              size: isDesktop ? 1.2.w : 20,
                            ),
                            color: AppColors.error,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      if (item.selectedCustomizations.isNotEmpty) ...[
                        SizedBox(height: 0.5.h),
                        Container(
                          padding: EdgeInsets.all(isDesktop ? 0.6.w : 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: isDesktop ? 1.w : 14.sp,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 0.4.w),
                                  Text(
                                    'Add-ons:',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 11.sp : 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.4.h),
                              ...item.selectedCustomizations.map(
                                (customization) => Padding(
                                  padding: EdgeInsets.only(
                                    left: isDesktop ? 1.2.w : 18,
                                    top: 2,
                                  ),
                                  child: Text(
                                    '• ${customization.name} (+\$${customization.price.toStringAsFixed(2)})',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 10.sp : 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 1.2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Quantity Controls
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: onDecrement,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      isDesktop ? 0.6.w : 8,
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: isDesktop ? 1.w : 16.sp,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 1.w : 12,
                                  ),
                                  child: Text(
                                    '${item.quantity}',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 13.sp : 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: onIncrement,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      isDesktop ? 0.6.w : 8,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: isDesktop ? 1.w : 16.sp,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: isDesktop ? 15.sp : 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (item.quantity > 1)
                                Text(
                                  '\$${item.pricePerItemWithTax.toStringAsFixed(2)} each',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 10.sp : 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Price breakdown
          if (item.selectedCustomizations.isNotEmpty || item.taxPerItem > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 1.w : 12,
                vertical: 0.8.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Base: \$${item.basePrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isDesktop ? 10.sp : 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (item.selectedCustomizations.isNotEmpty)
                    Text(
                      'Add-ons: \$${item.selectedCustomizations.fold<double>(0, (sum, c) => sum + c.price).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isDesktop ? 10.sp : 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  Text(
                    'Tax: \$${item.taxPerItem.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isDesktop ? 10.sp : 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
