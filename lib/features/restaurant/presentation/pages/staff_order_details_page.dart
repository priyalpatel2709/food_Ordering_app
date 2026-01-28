import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../../../features/rbac/presentation/widgets/permission_guard.dart';
import '../../../../core/constants/permission_constants.dart';
import '../widgets/order_payment_dialog.dart';

class StaffOrderDetailsPage extends ConsumerStatefulWidget {
  final OrderEntity order;

  const StaffOrderDetailsPage({super.key, required this.order});

  @override
  ConsumerState<StaffOrderDetailsPage> createState() =>
      _StaffOrderDetailsPageState();
}

class _StaffOrderDetailsPageState extends ConsumerState<StaffOrderDetailsPage> {
  // We might want to refresh the order details on this page if it changes

  @override
  Widget build(BuildContext context) {
    // We use the passed order, but we could also watch it if we had a single order provider
    // For now, let's just display the data passed in.
    // Ideally, we'd fetch the latest version of this specific order.

    final order = widget.order;
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.orderId}'),
        actions: [
          if (order.orderStatus.toLowerCase() == 'pending' ||
              order.orderStatus.toLowerCase() == 'confirmed')
            PermissionGuard(
              permission: PermissionConstants.orderUpdate,
              child: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () => _showCancelDialog(context, ref, order.id),
                tooltip: 'Cancel Order',
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Placed on ${dateFormat.format(order.createdAt.toLocal())}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                _buildStatusChip(order.orderStatus),
              ],
            ),
            const SizedBox(height: 24),

            // Customer Info
            if (order.customer != null) ...[
              const Text(
                'Customer Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${order.customer!.name}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Items
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.orderItems.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = order.orderItems[index];

                // Calculate item total including modifiers
                double modifiersTotal = 0.0;
                for (var m in item.modifiers) {
                  if (m is Map && m.containsKey('price')) {
                    modifiersTotal += (m['price'] as num).toDouble();
                  }
                }
                final itemTotal =
                    (item.price * item.quantity) +
                    (modifiersTotal * item.quantity);

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.item.image ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: const Icon(Icons.fastfood),
                      ),
                    ),
                  ),
                  title: Text(item.item.name ?? 'Unknown Item'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qty: ${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                      ),
                      if (item.modifiers.isNotEmpty)
                        ...item.modifiers.map((m) {
                          if (m is Map) {
                            final name =
                                m['modifierName'] ?? m['name'] ?? 'Modifier';
                            final price =
                                (m['price'] as num?)?.toDouble() ?? 0.0;
                            return Text(
                              ' + $name (\$${price.toStringAsFixed(2)})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                    ],
                  ),
                  trailing: Text(
                    '\$${itemTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
            const Divider(thickness: 1),

            // Financials
            _buildSummaryRow('Subtotal', order.subtotal),
            _buildSummaryRow('Tax', order.totalTaxAmount),
            if (order.totalDiscountAmount > 0)
              _buildSummaryRow(
                'Discount',
                -order.totalDiscountAmount,
                color: Colors.green,
              ),
            if (order.deliveryCharge > 0)
              _buildSummaryRow('Delivery Charge', order.deliveryCharge),
            if (order.restaurantTipCharge > 0)
              _buildSummaryRow('Tip', order.restaurantTipCharge),
            const Divider(),
            _buildSummaryRow(
              'Total',
              order.orderFinalCharge,
              isBold: true,
              fontSize: 18,
            ),

            const SizedBox(height: 24),

            // Payment Info
            const Text(
              'Payment Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status', style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            Icon(
                              _getPaymentIcon(order.payment.paymentStatus),
                              color: _getPaymentColor(
                                order.payment.paymentStatus,
                              ),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              order.payment.paymentStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getPaymentColor(
                                  order.payment.paymentStatus,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Total Paid', order.payment.totalPaid),
                    _buildSummaryRow(
                      'Remaining Due',
                      order.orderFinalCharge - order.payment.totalPaid,
                    ),

                    if (order.payment.paymentStatus.toLowerCase() != 'paid' &&
                        order.orderStatus.toLowerCase() != 'cancelled')
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: PermissionGuard(
                            permission: PermissionConstants.orderUpdate,
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      OrderPaymentDialog(order: order),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Take Payment'),
                            ),
                          ),
                        ),
                      ),

                    if (order.payment.paymentStatus.toLowerCase() == 'paid' &&
                        order.refunds.totalRefundedAmount <
                            order.payment.totalPaid &&
                        order.orderStatus.toLowerCase() !=
                            'cancelled') // Logic for refund button availability
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: PermissionGuard(
                            permission: PermissionConstants.orderUpdate,
                            child: OutlinedButton(
                              onPressed: () =>
                                  _showRefundDialog(context, ref, order),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text('Issue Refund'),
                            ),
                          ),
                        ),
                      ),
                    if (order.refunds.totalRefundedAmount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Total Refunded: \$${order.refunds.totalRefundedAmount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'preparing':
        color = Colors.purple;
        break;
      case 'ready':
        color = Colors.green;
        break;
      case 'completed':
        color = Colors.teal;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getPaymentColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(staffOrdersListNotifierProvider.notifier)
                  .cancelOrder(orderId);
              if (context.mounted) {
                if (success) {
                  Navigator.pop(
                    context,
                  ); // Go back to list if needed, or refresh
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order cancelled successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to cancel order'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'YES, CANCEL',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(
    BuildContext context,
    WidgetRef ref,
    OrderEntity order,
  ) {
    final refundable =
        order.payment.totalPaid - order.refunds.totalRefundedAmount;
    final amountController = TextEditingController(
      text: refundable.toStringAsFixed(2),
    );
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Issue Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Refundable: \$${refundable.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              final reason = reasonController.text.trim();

              if (amount <= 0 || amount > refundable) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Invalid amount')));
                return;
              }

              Navigator.pop(context);
              final success = await ref
                  .read(staffOrdersListNotifierProvider.notifier)
                  .refundOrder(order.id, amount, reason);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refund processed')),
                  );
                  // Ideally reload this page or go back
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Refund failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Refund'),
          ),
        ],
      ),
    );
  }
}
