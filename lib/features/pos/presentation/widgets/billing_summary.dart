import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/pos_provider.dart';
import '../providers/pos_state.dart';

class BillingSummary extends ConsumerWidget {
  const BillingSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final summary = state.summary;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Type Selector
          const Text(
            'Order Type',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
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
              const SizedBox(width: 8),
              _buildTypeIcon(
                context,
                ref,
                OrderType.takeaway,
                Icons.shopping_bag,
                'Takeaway',
                state.orderType,
              ),
              const SizedBox(width: 8),
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

          const SizedBox(height: 24),

          // Customer Details
          const Text(
            'Customer Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.customerName ?? 'Walk-in Customer',
                    style: TextStyle(
                      color: state.customerName != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: state.customerName != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(Icons.edit, size: 16, color: AppColors.primary),
              ],
            ),
          ),

          const Spacer(),

          // Calculation
          _buildSummaryRow('Subtotal', summary.subtotal),
          _buildSummaryRow('Tax (GST 10%)', summary.totalTax),
          _buildSummaryRow(
            'Discount',
            summary.discountAmount,
            isDiscount: true,
          ),
          _buildSummaryRow('Service Charge', 0.00),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(thickness: 1),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '\$${summary.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${summary.totalItems} Items selected',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
    final isSelected = type == currentType;
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(posNotifierProvider.notifier).setOrderType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
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

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          Text(
            '${isDiscount ? "-" : ""}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDiscount ? AppColors.error : AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
