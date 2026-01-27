import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../shared/theme/app_colors.dart';
import '../providers/pos_provider.dart';
import '../providers/pos_state.dart';
import 'table_selection_dialog.dart';

class BillingSummary extends ConsumerWidget {
  const BillingSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final summary = state.summary;

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ORDER TYPE
          _sectionTitle('Order Type'),
          SizedBox(height: 1.5.h),

          Row(
            children: [
              _buildOrderType(
                ref,
                OrderType.dineIn,
                Icons.restaurant,
                'Dine-in',
                state.orderType,
              ),
              SizedBox(width: 2.w),
              _buildOrderType(
                ref,
                OrderType.takeaway,
                Icons.shopping_bag,
                'Takeaway',
                state.orderType,
              ),
              SizedBox(width: 2.w),
              _buildOrderType(
                ref,
                OrderType.delivery,
                Icons.delivery_dining,
                'Delivery',
                state.orderType,
              ),
            ],
          ),

          SizedBox(height: 3.h),

          if (state.orderType == OrderType.dineIn) ...[
            SizedBox(height: 2.h),

            _sectionTitle('Table Selection'),
            SizedBox(height: 1.5.h),

            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const TableSelectionDialog(),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.tableNumber != null
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.table_restaurant,
                      color: state.tableNumber != null
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            state.tableNumber != null
                                ? 'Table ${state.tableNumber}'
                                : 'Select Table',
                            maxLines: 1,
                            minFontSize: 12,
                            maxFontSize: 16,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: state.tableNumber != null
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (state.ongoingOrderId != null)
                            AutoSizeText(
                              'Ongoing Order Active',
                              maxLines: 1,
                              minFontSize: 10,
                              maxFontSize: 13,
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 2.h),
          ],

          /// SCROLLABLE SUMMARY
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  /// EXISTING ITEMS
                  if (state.ongoingOrder != null &&
                      state.ongoingOrder!.items.isNotEmpty) ...[
                    _sectionTitle(
                      'Existing Items (Table ${state.tableNumber})',
                    ),
                    SizedBox(height: 0.8.h),
                    ...state.ongoingOrder!.items.map(
                      (item) => _summaryRow(
                        '${item.name} x${item.quantity}',
                        item.price * item.quantity,
                      ),
                    ),
                    Divider(height: 2.h),
                    _sectionTitle('Pending Items'),
                    SizedBox(height: 0.8.h),
                  ],

                  _summaryRow('Subtotal', summary.subtotal),
                  _summaryRow('Tax (GST 10%)', summary.totalTax),
                  _summaryRow(
                    'Discount',
                    summary.discountAmount,
                    isDiscount: true,
                  ),
                  _summaryRow('Service Charge', 0),
                ],
              ),
            ),
          ),

          Divider(height: 3.h),

          /// TOTAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(
                'Grand Total',
                maxLines: 1,
                minFontSize: 14,
                maxFontSize: 16,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              AutoSizeText(
                '\$${((state.ongoingOrder?.totalAmount ?? 0) + summary.total).toStringAsFixed(2)}',
                maxLines: 1,
                minFontSize: 14,
                maxFontSize: 16,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.8.h),
          AutoSizeText(
            '${summary.totalItems} items selected',
            maxLines: 1,
            minFontSize: 14,
            maxFontSize: 16,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// ===================== COMPONENTS =====================

  Widget _sectionTitle(String text) {
    return AutoSizeText(
      text,
      maxLines: 1,
      minFontSize: 12,
      maxFontSize: 16,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildOrderType(
    WidgetRef ref,
    OrderType type,
    IconData icon,
    String label,
    OrderType currentType,
  ) {
    final bool isSelected = type == currentType;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => ref.read(posNotifierProvider.notifier).setOrderType(type),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),

              SizedBox(height: 0.6.h),
              AutoSizeText(
                label,
                maxLines: 1,
                minFontSize: 10,
                maxFontSize: 14,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText(
            label,
            maxLines: 1,
            minFontSize: 10,
            maxFontSize: 14,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          AutoSizeText(
            '${isDiscount ? "-" : ""}\$${amount.toStringAsFixed(2)}',
            maxLines: 1,
            minFontSize: 10,
            maxFontSize: 14,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDiscount ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
