import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../../order/domain/entities/order_entity.dart';

class StaffOrdersPage extends ConsumerStatefulWidget {
  const StaffOrdersPage({super.key});

  @override
  ConsumerState<StaffOrdersPage> createState() => _StaffOrdersPageState();
}

class _StaffOrdersPageState extends ConsumerState<StaffOrdersPage> {
  @override
  void initState() {
    super.initState();
    // Fetch ALL orders when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(staffOrdersListNotifierProvider.notifier).getAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(staffOrdersListNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Orders (Staff)'), elevation: 0),
      body: _buildBody(ordersState),
    );
  }

  Widget _buildBody(OrdersListState state) {
    return switch (state) {
      OrdersListInitial() => const Center(child: Text('Loading orders...')),
      OrdersListLoading() => const Center(child: CircularProgressIndicator()),
      OrdersListSuccess(:final orders) =>
        orders.isEmpty ? _buildEmptyState() : _buildOrdersList(orders),
      OrdersListError(:final message) => _buildErrorState(message),
    };
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(staffOrdersListNotifierProvider.notifier).getAllOrders();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderEntity> orders) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(staffOrdersListNotifierProvider.notifier).getAllOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to staff order details if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(order.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(order.orderStatus),
                ],
              ),
              const Divider(height: 24),

              // Order items
              ...order.orderItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // Item image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.item.image ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Icon(Icons.fastfood),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Item details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.item.name ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Qty: ${item.quantity}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Item price
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24),

              // Order summary
              Column(
                children: [
                  _buildSummaryRow('Subtotal', order.subtotal),
                  _buildSummaryRow('Tax', order.totalTaxAmount),
                  if (order.discount.discounts.isNotEmpty)
                    ...order.discount.discounts.map(
                      (d) => _buildSummaryRow(
                        'Discount (${d.discount.discountName})',
                        -d.discountAmount,
                        color: Colors.green[700],
                      ),
                    )
                  else if (order.totalDiscountAmount > 0)
                    _buildSummaryRow(
                      'Discount',
                      -order.totalDiscountAmount,
                      color: Colors.green[700],
                    ),
                  if (order.deliveryCharge > 0)
                    _buildSummaryRow('Delivery', order.deliveryCharge),
                  if (order.restaurantTipCharge > 0)
                    _buildSummaryRow('Tip', order.restaurantTipCharge),
                  const Divider(height: 16),
                  _buildSummaryRow(
                    'Total',
                    order.orderFinalCharge,
                    isBold: true,
                  ),
                ],
              ),

              // Payment status
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getPaymentIcon(order.payment.paymentStatus),
                        size: 16,
                        color: _getPaymentColor(order.payment.paymentStatus),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Payment: ${order.payment.paymentStatus.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getPaymentColor(order.payment.paymentStatus),
                        ),
                      ),
                    ],
                  ),
                  if (order.payment.paymentStatus.toLowerCase() == 'paid' &&
                      order.orderStatus.toLowerCase() != 'cancelled')
                    OutlinedButton(
                      onPressed: () => _showRefundDialog(context, order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Refund'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
        break;
      case 'confirmed':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[900]!;
        break;
      case 'preparing':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[900]!;
        break;
      case 'ready':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[900]!;
        break;
      case 'completed':
        backgroundColor = Colors.teal[100]!;
        textColor = Colors.teal[900]!;
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[900]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[900]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isBold ? Colors.black : Colors.grey[700]),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? (isBold ? Colors.black : Colors.grey[900]),
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

  void _showRefundDialog(BuildContext context, OrderEntity order) {
    if (order.orderStatus.toLowerCase() == 'cancelled') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order cannot be refunded')));
      return;
    }

    // Calculate refundable amount
    // assuming totalPaid is the max refundable if not already refunded
    final totalPaid = order.payment.totalPaid;
    final refunded = order.refunds.totalRefundedAmount;
    final refundable = totalPaid - refunded;

    if (refundable <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No refundable amount remaining')),
      );
      return;
    }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refundable Amount: \$${refundable.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Order Summary Breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal', order.subtotal),
                  _buildSummaryRow('Tax', order.totalTaxAmount),
                  if (order.discount.discounts.isNotEmpty)
                    ...order.discount.discounts.map(
                      (d) => _buildSummaryRow(
                        'Discount (${d.discount.discountName})',
                        -d.discountAmount,
                        color: Colors.green[700],
                      ),
                    )
                  else if (order.totalDiscountAmount > 0)
                    _buildSummaryRow(
                      'Discount',
                      -order.totalDiscountAmount,
                      color: Colors.green[700],
                    ),
                  if (order.deliveryCharge > 0)
                    _buildSummaryRow('Delivery', order.deliveryCharge),
                  if (order.restaurantTipCharge > 0)
                    _buildSummaryRow('Tip', order.restaurantTipCharge),
                  const Divider(height: 16),
                  _buildSummaryRow(
                    'Total Paid',
                    order.payment.totalPaid,
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Refund Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Refund',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  final reason = reasonController.text.trim();

                  if (amount <= 0 || amount > refundable) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid refund amount')),
                    );
                    return;
                  }

                  if (reason.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please provide a reason')),
                    );
                    return;
                  }

                  Navigator.pop(context); // Close dialog

                  // Show loading indicator or snackbar?
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing refund...')),
                  );

                  // Use Staff provider here
                  final success = await ref
                      .read(staffOrdersListNotifierProvider.notifier)
                      .refundOrder(order.id, amount, reason);

                  if (success) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Refund processed successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to process refund'),
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
              );
            },
          ),
        ],
      ),
    );
  }
}
