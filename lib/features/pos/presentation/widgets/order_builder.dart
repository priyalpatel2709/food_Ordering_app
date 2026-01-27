import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../dine_in/domain/entities/dine_in_order_entity.dart';
import '../../../dine_in/domain/entities/payment_entity.dart';
import '../providers/pos_provider.dart';
import '../providers/pos_state.dart';

import './table_selection_dialog.dart';
import './schedule_order_dialog.dart';

class OrderBuilder extends ConsumerWidget {
  const OrderBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final items = state.cartItems;
    final ongoingOrder = state.ongoingOrder;
    final summary = state.summary;

    final double totalToPay = summary.total + (ongoingOrder?.totalAmount ?? 0);

    String formatScheduledTime(DateTime date, String? time) {
      final dateStr = '${date.month}/${date.day}';
      return time != null ? '$dateStr at $time' : dateStr;
    }

    return Column(
      children: [
        // Cart Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your Cart',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (items.isNotEmpty)
                    TextButton(
                      onPressed: () =>
                          ref.read(posNotifierProvider.notifier).clearCart(),
                      child: Text(
                        'Clear All',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                ],
              ),
              if (state.tableNumber != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Table: ${state.tableNumber}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Items List
        Expanded(
          child: (items.isEmpty && ongoingOrder == null)
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (items.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'NEW ITEMS',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      ...items.map((item) => _CartItemTile(item: item)),
                    ],
                    if (ongoingOrder != null &&
                        ongoingOrder.items.isNotEmpty) ...[
                      const Divider(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              'ORDERED ITEMS',
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                                letterSpacing: 1,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                ongoingOrder.status.toUpperCase(),
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...ongoingOrder.items.map(
                        (item) => _OngoingItemTile(item: item),
                      ),
                    ],
                  ],
                ),
        ),

        // Billing Summary Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              if (items.isNotEmpty) ...[
                _summaryRow('Cart Subtotal', summary.subtotal),
                _summaryRow('Cart Tax', summary.totalTax),
              ],
              if (ongoingOrder != null)
                _summaryRow('Already Ordered', ongoingOrder.totalAmount),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${totalToPay.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              // Schedule Order Button (for non-Dine-In orders)
              if (state.orderType != OrderType.dineIn && items.isNotEmpty) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ScheduleOrderDialog(),
                    );
                  },
                  icon: Icon(
                    Icons.schedule,
                    size: 18,
                    color: state.scheduledFor != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  label: Text(
                    state.scheduledFor != null
                        ? 'Scheduled: ${formatScheduledTime(state.scheduledFor!, state.scheduledOrderTime)}'
                        : 'Schedule Order',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: state.scheduledFor != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: state.scheduledFor != null
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    side: BorderSide(
                      color: state.scheduledFor != null
                          ? AppColors.primary
                          : AppColors.border,
                      width: state.scheduledFor != null ? 2 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (items.isNotEmpty)
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (state.orderType == OrderType.dineIn &&
                                state.tableNumber == null) {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    const TableSelectionDialog(),
                              );
                              return;
                            }
                            ref.read(posNotifierProvider.notifier).placeOrder();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (state.orderType == OrderType.dineIn &&
                                    state.tableNumber == null)
                                ? AppColors.grey400
                                : AppColors.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            (state.orderType == OrderType.dineIn &&
                                    state.tableNumber == null)
                                ? 'SELECT TABLE'
                                : (ongoingOrder != null
                                      ? 'ADD TO ORDER'
                                      : 'PLACE ORDER'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  if (items.isNotEmpty && ongoingOrder != null)
                    const SizedBox(width: 12),
                  if (ongoingOrder != null)
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _handleSettle(
                            context,
                            ref,
                            ongoingOrder.id,
                            totalToPay.toStringAsFixed(2),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'SETTLE',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSettle(
    BuildContext context,
    WidgetRef ref,
    String orderId,
    String amount,
  ) {
    // Show payment dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settle Order'),
        content: const Text('Choose payment method and finalize order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(posNotifierProvider.notifier)
                  .settleOrder(
                    orderId,
                    PaymentEntity(
                      payment: Payment(
                        method: 'cash',
                        amount: double.tryParse(amount) ?? 0,
                      ),
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Confirm Cash Payment'),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
          ),
          Text(
            '${amount < 0 ? "-" : ""}\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDiscount ? AppColors.error : AppColors.textPrimary,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 64,
            color: AppColors.grey300,
          ),
          const SizedBox(height: 16),
          Text(
            'Cart is empty',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap products to add items',
            style: TextStyle(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItemEntity item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.menuItemName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (item.selectedCustomizations.isNotEmpty ||
                        item.note != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.selectedCustomizations.isNotEmpty)
                              Text(
                                item.selectedCustomizations
                                    .map((c) => c.name)
                                    .join(', '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            if (item.note != null)
                              Text(
                                'Note: ${item.note}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '\$${(item.pricePerItem * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _qtyButton(
                    icon: Icons.remove,
                    onTap: () => ref
                        .read(posNotifierProvider.notifier)
                        .decrementQuantity(item.id),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _qtyButton(
                    icon: Icons.add,
                    onTap: () => ref
                        .read(posNotifierProvider.notifier)
                        .incrementQuantity(item.id),
                  ),
                ],
              ),
              IconButton(
                onPressed: () =>
                    ref.read(posNotifierProvider.notifier).removeItem(item.id),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

class _OngoingItemTile extends StatelessWidget {
  final DineInOrderItem item;

  const _OngoingItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${item.quantity}x',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.withOpacity(0.8),
                      ),
                    ),
                    if (item.modifiers.isNotEmpty ||
                        item.specialInstructions != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.modifiers.isNotEmpty)
                              Text(
                                item.modifiers.map((m) => m.name).join(', '),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            if (item.specialInstructions != null)
                              Text(
                                'Note: ${item.specialInstructions}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary.withOpacity(0.7),
                ),
              ),
            ],
          ),
          if (item.status != 'served')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(item.status),
                    size: 14,
                    color: _getStatusColor(item.status),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(item.status),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'preparing':
        return Icons.timer_outlined;
      case 'ready':
        return Icons.check_circle_outline;
      case 'new':
        return Icons.fiber_new_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'preparing':
        return Colors.orange;
      case 'ready':
        return AppColors.success;
      case 'new':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}
