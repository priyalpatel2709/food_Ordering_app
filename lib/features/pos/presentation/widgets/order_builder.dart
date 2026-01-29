import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../dine_in/domain/entities/dine_in_order_entity.dart';
import '../../../loyalty/presentation/providers/loyalty_providers.dart';
import '../providers/pos_state.dart';
import '../providers/pos_provider.dart';
import './table_selection_dialog.dart';
import './schedule_order_dialog.dart';
import './payment_dialog.dart';
import '../../../loyalty/presentation/widgets/customer_lookup_dialog.dart';
import '../../../loyalty/presentation/widgets/redeem_points_dialog.dart';

class OrderBuilder extends ConsumerWidget {
  const OrderBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final items = state.cartItems;
    final ongoingOrder = state.ongoingOrder;
    final summary = state.summary;

    final double totalToPay = summary.total + (ongoingOrder?.totalAmount ?? 0);

    return Column(
      children: [
        // Top Order Info Bar (Simplified)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 12.px),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.primary,
                size: 20.px,
              ),
              SizedBox(width: 12.px),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.orderType.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHint,
                      ),
                    ),
                    Text(
                      state.tableNumber != null
                          ? 'Table: ${state.tableNumber}'
                          : 'Cart',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isNotEmpty)
                IconButton(
                  onPressed: () =>
                      ref.read(posNotifierProvider.notifier).clearCart(),
                  icon: Icon(
                    Icons.delete_sweep_outlined,
                    color: AppColors.error,
                    size: 20.px,
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
                  padding: EdgeInsets.zero,
                  children: [
                    if (items.isNotEmpty)
                      ...items.map((item) => _CartItemTile(item: item)),
                    if (ongoingOrder != null &&
                        ongoingOrder.items.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.px,
                          vertical: 4.px,
                        ),
                        color: AppColors.grey50,
                        child: Text(
                          'ORDERED ITEMS',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                      ...ongoingOrder.items.map(
                        (item) => _OngoingItemTile(item: item),
                      ),
                    ],
                  ],
                ),
        ),

        // Bottom Info & Action Section
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Customer Info Row
            _buildCustomerBar(context, ref, state),

            // Grid-style Summary
            Container(
              height: 80.px,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  // Subtotal/Tax/Discount Column
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: EdgeInsets.all(8.px),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _miniSummaryRow('DISCOUNT:', state.loyaltyDiscount),
                          _miniSummaryRow('SUBTOTAL:', summary.subtotal),
                          _miniSummaryRow('TAX:', summary.totalTax),
                        ],
                      ),
                    ),
                  ),
                  // Total Column
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.all(8.px),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '\$${(totalToPay - state.loyaltyDiscount).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Details Column (Buttons)
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Visibility(
                          visible: state.orderType == OrderType.dineIn,
                          child: _summaryButton('SELECT TABLE', () {
                            if (state.orderType == OrderType.dineIn) {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    const TableSelectionDialog(),
                              );
                            }
                          }),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        Visibility(
                          visible: state.orderType != OrderType.dineIn,
                          child: _summaryButton(
                            state.scheduledFor != null
                                ? 'SCHEDULED'
                                : 'SCHEDULE',
                            () {
                              if (state.orderType != OrderType.dineIn) {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const ScheduleOrderDialog(),
                                );
                              }
                            },
                            color: state.scheduledFor != null
                                ? AppColors.primary
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Action Bar (Clear/Send/Discount-Settle)
            Container(
              height: 48.px,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  _actionButton(
                    Icons.close,
                    'CLEAR',
                    (items.isEmpty && ongoingOrder == null)
                        ? AppColors.borderDark
                        : AppColors.error,
                    () {
                      if (items.isEmpty && ongoingOrder == null) return;
                      ref.read(posNotifierProvider.notifier).clearCart();
                    },
                  ),
                  const VerticalDivider(width: 1, color: AppColors.border),
                  _actionButton(
                    Icons.send,
                    ongoingOrder != null ? 'ADD' : 'SEND',
                    (items.isEmpty && ongoingOrder == null)
                        ? AppColors.borderDark
                        : AppColors.secondary,
                    () {
                      if (items.isEmpty && ongoingOrder == null) return;
                      if (state.orderType == OrderType.dineIn &&
                          state.tableNumber == null) {
                        showDialog(
                          context: context,
                          builder: (context) => const TableSelectionDialog(),
                        );
                        return;
                      }

                      // For dine-in, just place the order (add items to table)
                      if (state.orderType == OrderType.dineIn) {
                        ref.read(posNotifierProvider.notifier).placeOrder();
                      } else {
                        // For takeaway/delivery, show payment dialog
                        _handlePaymentForOrder(context, ref, state);
                      }
                    },
                  ),
                  const VerticalDivider(width: 1, color: AppColors.border),
                  _actionButton(
                    Icons.payments,
                    'SETTLE',
                    ongoingOrder == null
                        ? AppColors.borderDark
                        : AppColors.primary,
                    () {
                      if (ongoingOrder != null) {
                        _handleSettle(
                          context,
                          ref,
                          ongoingOrder.id,
                          totalToPay.toStringAsFixed(2),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerBar(
    BuildContext context,
    WidgetRef ref,
    PosState state,
  ) {
    final customer = state.loyaltyCustomer;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.px, vertical: 6.px),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(Icons.person, size: 14.px, color: AppColors.textSecondary),
          SizedBox(width: 4.px),
          Text(
            customer != null ? '1' : '0',
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 12.px),
          Icon(Icons.search, size: 14.px, color: AppColors.textHint),
          SizedBox(width: 4.px),
          Expanded(
            child: InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (context) => CustomerLookupDialog(
                  onCustomerFound: (c) => ref
                      .read(posNotifierProvider.notifier)
                      .setLoyaltyCustomer(c),
                ),
              ),
              child: Text(
                customer != null ? customer.name : 'Customer',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: customer != null
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ),
          ),
          if (customer != null) ...[
            InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (context) => RedeemPointsDialog(
                  customer: customer,
                  onPointsRedeemed: (discount, points) {
                    ref
                        .read(posNotifierProvider.notifier)
                        .applyLoyaltyDiscount(discount, points);
                  },
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${customer.loyaltyPoints.current}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(width: 2.px),
                  Text(
                    'PTS',
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 14.px, color: AppColors.error),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                ref.read(posNotifierProvider.notifier).clearLoyalty();
                Future.microtask(() {
                  ref.read(loyaltyNotifierProvider.notifier).clearCustomer();
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniSummaryRow(String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.px),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _summaryButton(String label, VoidCallback onTap, {Color? color}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 4.px),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.px, color: color),
              SizedBox(width: 6.px),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSettle(
    BuildContext context,
    WidgetRef ref,
    String orderId,
    String amount,
  ) {
    final state = ref.read(posNotifierProvider);
    final double totalAmount = double.tryParse(amount) ?? 0;

    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        totalAmount: totalAmount,
        loyaltyDiscount: state.loyaltyDiscount,
        onConfirmed: (payment, payNow) {
          if (payment != null) {
            ref
                .read(posNotifierProvider.notifier)
                .settleOrder(orderId, payment);
          }
        },
      ),
    );
  }

  void _handlePaymentForOrder(
    BuildContext context,
    WidgetRef ref,
    PosState state,
  ) {
    final totalAmount = state.summary.total;
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        totalAmount: totalAmount,
        loyaltyDiscount: state.loyaltyDiscount,
        onConfirmed: (payment, payNow) {
          log(' payment: $payment, payNow: $payNow');
          if (payNow && payment != null) {
            // Pay Now: Use create-with-payment endpoint
            ref
                .read(posNotifierProvider.notifier)
                .placeOrderWithPayment(payment);
          } else {
            // Pay Later: Create order without payment
            ref.read(posNotifierProvider.notifier).placeOrder();
          }
        },
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
            size: 48.px,
            color: AppColors.grey300,
          ),
          SizedBox(height: 12.px),
          Text(
            'Cart is empty',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.px),
          Text(
            'Tap products to add items',
            style: TextStyle(fontSize: 11.sp, color: AppColors.textHint),
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
      padding: EdgeInsets.symmetric(horizontal: 12.px, vertical: 8.px),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.03),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          _qtyButton(
            icon: Icons.remove,
            onTap: () => ref
                .read(posNotifierProvider.notifier)
                .decrementQuantity(item.id),
          ),
          Container(
            width: 32.px,
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ),
          _qtyButton(
            icon: Icons.add,
            onTap: () => ref
                .read(posNotifierProvider.notifier)
                .incrementQuantity(item.id),
          ),
          SizedBox(width: 12.px),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuItemName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                if (item.selectedCustomizations.isNotEmpty)
                  Text(
                    item.selectedCustomizations.map((c) => c.name).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.px),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.px, vertical: 4.px),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4.px),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Text(
              '\$${(item.pricePerItem * item.quantity).toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
            ),
          ),
          SizedBox(width: 8.px),
          InkWell(
            onTap: () =>
                ref.read(posNotifierProvider.notifier).removeItem(item.id),
            child: Icon(Icons.cancel, color: AppColors.error, size: 20.px),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.px),
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(4.px),
        ),
        child: Icon(icon, size: 14.px, color: AppColors.textPrimary),
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
      padding: EdgeInsets.symmetric(horizontal: 12.px, vertical: 8.px),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.px,
            height: 24.px,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(4.px),
            ),
            child: Text(
              '${item.quantity}',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 12.px),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                if (item.modifiers.isNotEmpty)
                  Text(
                    item.modifiers.map((c) => c.name).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.px),
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
