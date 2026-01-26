import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../../order/domain/entities/order_entity.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  @override
  void initState() {
    super.initState();
    // Fetch orders when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersListNotifierProvider.notifier).getMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: TextStyle(fontSize: 18.sp)),
        elevation: 0,
      ),
      body: _buildBody(ordersState),
    );
  }

  Widget _buildBody(OrdersListState state) {
    return switch (state) {
      OrdersListInitial() => Center(
        child: Text('Loading orders...', style: TextStyle(fontSize: 16.sp)),
      ),
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
          Icon(
            Icons.receipt_long_outlined,
            size: 20.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your orders will appear here',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
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
          Icon(Icons.error_outline, size: 20.w, color: Colors.red[300]),
          SizedBox(height: 2.h),
          Text(
            'Error loading orders',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(ordersListNotifierProvider.notifier).getMyOrders();
            },
            icon: Icon(Icons.refresh, size: 5.w),
            label: Text('Retry', style: TextStyle(fontSize: 15.sp)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderEntity> orders) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(ordersListNotifierProvider.notifier).getMyOrders();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
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
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to order details
        },
        child: Padding(
          padding: EdgeInsets.all(4.w),
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
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          dateFormat.format(order.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(order.orderStatus),
                ],
              ),
              Divider(height: 3.h),

              // Order items
              ...order.orderItems.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    children: [
                      // Item image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.item.image ?? '',
                          width: 12.w,
                          height: 12.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 12.w,
                              height: 12.w,
                              color: Colors.grey[300],
                              child: Icon(Icons.fastfood, size: 6.w),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 3.w),

                      // Item details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.item.name ?? '',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Qty: ${item.quantity}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Item price
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Divider(height: 3.h),

              // Order summary
              Column(
                children: [
                  _buildSummaryRow('Subtotal', order.subtotal),
                  _buildSummaryRow('Tax', order.totalTaxAmount),
                  if (order.totalDiscountAmount > 0)
                    _buildSummaryRow('Discount', -order.totalDiscountAmount),
                  if (order.deliveryCharge > 0)
                    _buildSummaryRow('Delivery', order.deliveryCharge),
                  if (order.restaurantTipCharge > 0)
                    _buildSummaryRow('Tip', order.restaurantTipCharge),
                  Divider(height: 2.h),
                  _buildSummaryRow(
                    'Total',
                    order.orderFinalCharge,
                    isBold: true,
                  ),
                ],
              ),

              SizedBox(height: 1.5.h),
              Row(
                children: [
                  Icon(
                    _getPaymentIcon(order.payment.paymentStatus),
                    size: 4.w,
                    color: _getPaymentColor(order.payment.paymentStatus),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Payment: ${order.payment.paymentStatus.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _getPaymentColor(order.payment.paymentStatus),
                    ),
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
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16.sp : 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isBold ? 16.sp : 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? Colors.black : Colors.grey[900],
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
}
