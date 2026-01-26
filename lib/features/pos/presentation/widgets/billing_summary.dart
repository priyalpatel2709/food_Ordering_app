import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/pos_provider.dart';
import '../providers/pos_state.dart';

class BillingSummary extends ConsumerWidget {
  const BillingSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final summary = state.summary;
    final bool isDesktop = Device.width > 900;

    return Padding(
      padding: EdgeInsets.all(isDesktop ? 1.5.w : 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Type Selector
          Text(
            'Order Type',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 15.sp : 17.sp,
            ),
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              _buildTypeIcon(
                context,
                ref,
                OrderType.dineIn,
                Icons.restaurant,
                'Dine-in',
                state.orderType,
              ),
              SizedBox(width: isDesktop ? 0.8.w : 2.w),
              _buildTypeIcon(
                context,
                ref,
                OrderType.takeaway,
                Icons.shopping_bag,
                'Takeaway',
                state.orderType,
              ),
              SizedBox(width: isDesktop ? 0.8.w : 2.w),
              _buildTypeIcon(
                context,
                ref,
                OrderType.delivery,
                Icons.delivery_dining,
                'Delivery',
                state.orderType,
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Customer Details
          Text(
            'Customer Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 15.sp : 17.sp,
            ),
          ),
          SizedBox(height: 1.5.h),
          Container(
            padding: EdgeInsets.all(isDesktop ? 1.w : 3.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_add_alt_1,
                  color: AppColors.textSecondary,
                  size: isDesktop ? 1.5.w : 5.w,
                ),
                SizedBox(width: isDesktop ? 0.8.w : 3.w),
                Expanded(
                  child: Text(
                    state.customerName ?? 'Walk-in Customer',
                    style: TextStyle(
                      fontSize: isDesktop ? 14.sp : 15.sp,
                      color: state.customerName != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: state.customerName != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.edit,
                  size: isDesktop ? 1.2.w : 4.w,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Calculation
          _buildSummaryRow('Subtotal', summary.subtotal, isDesktop),
          _buildSummaryRow('Tax (GST 10%)', summary.totalTax, isDesktop),
          _buildSummaryRow(
            'Discount',
            summary.discountAmount,
            isDesktop,
            isDiscount: true,
          ),
          _buildSummaryRow('Service Charge', 0.00, isDesktop),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: const Divider(thickness: 1),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: isDesktop ? 16.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '\$${summary.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: isDesktop ? 18.sp : 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '${summary.totalItems} Items selected',
            style: TextStyle(
              fontSize: isDesktop ? 13.sp : 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon(
    BuildContext context,
    WidgetRef ref,
    OrderType type,
    IconData icon,
    String label,
    OrderType currentType,
  ) {
    final bool isDesktop = Device.width > 900;
    final isSelected = type == currentType;

    return Expanded(
      child: InkWell(
        onTap: () => ref.read(posNotifierProvider.notifier).setOrderType(type),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 0.5.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: isDesktop ? 2.w : 6.w,
              ),
              SizedBox(height: 0.8.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isDesktop ? 13.sp : 14.sp,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount,
    bool isDesktop, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isDesktop ? 14.sp : 15.sp,
            ),
          ),
          Text(
            '${isDiscount ? "-" : ""}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDiscount ? AppColors.error : AppColors.textPrimary,
              fontSize: isDesktop ? 14.sp : 15.sp,
            ),
          ),
        ],
      ),
    );
  }
}
