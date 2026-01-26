import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../domain/entities/cart_entity.dart';
import '../../../../shared/theme/app_colors.dart';

class CartSummaryCard extends StatelessWidget {
  final CartSummary summary;

  const CartSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Device.width > 900;

    return Container(
      margin: EdgeInsets.all(isDesktop ? 1.w : 16),
      padding: EdgeInsets.all(isDesktop ? 1.5.w : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white,
            AppColors.primaryContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 0.6.w : 8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: AppColors.white,
                  size: isDesktop ? 1.5.w : 20,
                ),
              ),
              SizedBox(width: 1.w),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: isDesktop ? 15.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildSummaryRow(
            'Subtotal',
            '\$${summary.subtotal.toStringAsFixed(2)}',
            false,
            Icons.shopping_basket_outlined,
          ),
          SizedBox(height: 1.2.h),
          _buildSummaryRow(
            'Tax (included)',
            '\$${summary.totalTax.toStringAsFixed(2)}',
            false,
            Icons.receipt_outlined,
          ),
          if (summary.discountAmount > 0) ...[
            SizedBox(height: 1.2.h),
            _buildSummaryRow(
              'Discount',
              '-\$${summary.discountAmount.toStringAsFixed(2)}',
              false,
              Icons.local_offer_outlined,
              valueColor: AppColors.success,
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.5.h),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.grey200,
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.grey200,
                  ],
                ),
              ),
            ),
          ),
          _buildSummaryRow(
            'Total',
            '\$${summary.total.toStringAsFixed(2)}',
            true,
            Icons.payments_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isTotal,
    IconData icon, {
    Color? valueColor,
  }) {
    final bool isDesktop = Device.width > 900;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: isTotal
                  ? (isDesktop ? 1.5.w : 20.sp)
                  : (isDesktop ? 1.2.w : 16.sp),
              color: isTotal ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16.sp : 14.sp,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTotal ? (isDesktop ? 1.w : 12) : 0,
            vertical: isTotal ? (isDesktop ? 0.4.h : 6) : 0,
          ),
          decoration: isTotal
              ? BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18.sp : 15.sp,
              fontWeight: FontWeight.bold,
              color: isTotal
                  ? AppColors.white
                  : (valueColor ?? AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
