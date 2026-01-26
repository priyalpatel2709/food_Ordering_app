import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/dine_in_order_entity.dart';
import '../providers/dine_in_providers.dart';
import '../../../../core/di/providers.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/dine_in_session.dart';
import '../../../../shared/navigation/navigation_provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../core/services/storage_service.dart';
import '../../../discount/domain/entities/discount_entity.dart';
import '../../../discount/presentation/providers/discount_provider.dart';

class TableDetailsPage extends ConsumerStatefulWidget {
  final TableEntity table;

  const TableDetailsPage({super.key, required this.table});

  @override
  ConsumerState<TableDetailsPage> createState() => _TableDetailsPageState();
}

class _TableDetailsPageState extends ConsumerState<TableDetailsPage> {
  StreamSubscription? _orderDeletedSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _joinTableRoom();
      _listenToOrderDeletion();
    });
  }

  @override
  void dispose() {
    _orderDeletedSubscription?.cancel();
    super.dispose();
  }

  void _joinTableRoom() {
    final storageService = StorageService();
    final restaurantId = storageService.getRestaurantId();
    if (restaurantId != null) {
      ref
          .read(socketServiceProvider)
          .joinTable(restaurantId, widget.table.tableNumber);
    }
  }

  void _listenToOrderDeletion() {
    _orderDeletedSubscription = ref
        .read(socketServiceProvider)
        .orderDeletedStream
        .listen((data) {
          if (data['orderId'] == widget.table.currentOrderId) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order has been removed/cancelled'),
                ),
              );
              context.pop();
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Device.width > 900;

    // If table is available, show "Start Order"
    if (widget.table.status == TableStatus.available) {
      return _buildAvailableView(context, ref);
    }

    // If occupied but no ID (shouldn't happen ideally if data consistent)
    if (widget.table.currentOrderId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Table ${widget.table.tableNumber}',
            style: TextStyle(fontSize: isDesktop ? 14.sp : 18.sp),
          ),
        ),
        body: Center(
          child: Text(
            "Status is occupied but no Order ID found.",
            style: TextStyle(fontSize: isDesktop ? 13.sp : 16.sp),
          ),
        ),
      );
    }

    // Watch order details
    final orderAsync = ref.watch(
      orderDetailsProvider(widget.table.currentOrderId!),
    );

    // Automatically navigate back if order is completed or cancelled from another device
    ref.listen(orderDetailsProvider(widget.table.currentOrderId!), (
      previous,
      next,
    ) {
      if (next.hasValue) {
        final order = next.value!;
        final status = order.status.toUpperCase();
        if (status == 'COMPLETED' || status == 'CANCELLED') {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Order has been $status')));
            context.pop();
          }
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Table ${widget.table.tableNumber} - Order',
          style: TextStyle(fontSize: isDesktop ? 14.sp : 18.sp),
        ),
      ),
      body: orderAsync.when(
        data: (order) => _buildOrderView(context, ref, order),
        error: (e, s) => Center(
          child: Text(
            'Error: $e',
            style: TextStyle(fontSize: isDesktop ? 12.sp : 15.sp),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildAvailableView(BuildContext context, WidgetRef ref) {
    final bool isDesktop = Device.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Table ${widget.table.tableNumber}',
          style: TextStyle(fontSize: isDesktop ? 14.sp : 18.sp),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktop ? 40.w : 600),
          padding: EdgeInsets.all(isDesktop ? 2.w : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_restaurant,
                size: isDesktop ? 10.w : 15.w,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 3.h),
              Text(
                "Table is Available",
                style: TextStyle(
                  fontSize: isDesktop ? 18.sp : 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                "Table ${widget.table.tableNumber} is empty. Start a new order to seat guests.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 12.sp : 15.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(dineInSessionProvider.notifier).state =
                      DineInSession(tableNumber: widget.table.tableNumber);

                  // Get user role
                  final storageService = StorageService();
                  final user = storageService.getUser();

                  if (user != null && user.role != 'customer') {
                    context.push(RouteConstants.menu);
                  } else {
                    ref.read(bottomNavIndexProvider.notifier).state =
                        0; // Menu Tab
                    context.go(RouteConstants.home);
                  }
                },
                icon: Icon(
                  Icons.restaurant_menu,
                  size: isDesktop ? 1.5.w : 5.w,
                ),
                label: Text(
                  "Open Table & Start Order",
                  style: TextStyle(
                    fontSize: isDesktop ? 13.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 3.w : 10.w,
                    vertical: isDesktop ? 1.5.h : 2.h,
                  ),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderView(
    BuildContext context,
    WidgetRef ref,
    DineInOrderEntity order,
  ) {
    final bool isDesktop = Device.width > 900;

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Items List
          Expanded(flex: 6, child: _buildItemsList(context, ref, order)),
          // Sidebar: Summary & Actions
          Container(
            width: 30.w,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(-5, 0),
                ),
              ],
            ),
            child: _buildFooterActions(context, ref, order),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Order Items List
        Expanded(child: _buildItemsList(context, ref, order)),
        // Footer: Add Items & Pay
        _buildFooterActions(context, ref, order),
      ],
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    WidgetRef ref,
    DineInOrderEntity order,
  ) {
    final bool isDesktop = Device.width > 900;

    return ListView.separated(
      padding: EdgeInsets.all(isDesktop ? 1.5.w : 16),
      itemCount: order.items.length,
      separatorBuilder: (context, index) =>
          Divider(color: Colors.grey.shade100),
      itemBuilder: (context, index) {
        final item = order.items[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 0.5.h),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: isDesktop ? 13.sp : 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 0.8.w : 2.w,
                    vertical: 0.4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: isDesktop ? 10.sp : 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.modifiers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      item.modifiers.map((m) => '+ ${m.name}').join(', '),
                      style: TextStyle(
                        fontSize: isDesktop ? 11.sp : 14.sp,
                        fontStyle: FontStyle.italic,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                if (item.specialInstructions != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      item.specialInstructions!,
                      style: TextStyle(
                        fontSize: isDesktop ? 11.sp : 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.quantity}x',
                  style: TextStyle(
                    fontSize: isDesktop ? 12.sp : 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isDesktop ? 12.sp : 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.status.toLowerCase() == 'new') ...[
                  SizedBox(width: 1.w),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: isDesktop ? 1.5.w : 22.sp,
                    ),
                    onPressed: () =>
                        _showRemoveItemDialog(context, ref, order.id, item.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooterActions(
    BuildContext context,
    WidgetRef ref,
    DineInOrderEntity order,
  ) {
    final bool isDesktop = Device.width > 900;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 2.w : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isDesktop
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: isDesktop ? 13.sp : 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                "\$${order.totalAmount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: isDesktop ? 16.sp : 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  (order.status == 'COMPLETED' ||
                      order.status == 'PAYMENT_PENDING')
                  ? null
                  : () {
                      ref
                          .read(dineInSessionProvider.notifier)
                          .state = DineInSession(
                        tableNumber: widget.table.tableNumber,
                        orderId: order.id,
                      );

                      final storageService = StorageService();
                      final user = storageService.getUser();

                      if (user != null && user.role != 'customer') {
                        context.push(RouteConstants.menu);
                      } else {
                        ref.read(bottomNavIndexProvider.notifier).state = 0;
                        context.go(RouteConstants.home);
                      }
                    },
              icon: Icon(Icons.add, size: isDesktop ? 1.5.w : 20.sp),
              label: Text(
                "Add Items",
                style: TextStyle(fontSize: isDesktop ? 12.sp : 15.sp),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 1.5.h : 16),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (order.status == 'COMPLETED')
                  ? null
                  : () {
                      _showPaymentDialog(
                        context,
                        ref,
                        order.id,
                        order.totalAmount,
                      );
                    },
              icon: Icon(Icons.payment, size: isDesktop ? 1.5.w : 20.sp),
              label: Text(
                "Pay & Close",
                style: TextStyle(fontSize: isDesktop ? 12.sp : 15.sp),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 1.5.h : 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
          if (order.status.toLowerCase() == 'pending') ...[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _showCancelOrderDialog(context, ref, order.id),
                icon: Icon(
                  Icons.cancel_outlined,
                  color: AppColors.error,
                  size: isDesktop ? 1.2.w : 18.sp,
                ),
                label: Text(
                  "Cancel Order",
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: isDesktop ? 11.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    WidgetRef ref,
    String orderId,
    double amount,
  ) {
    final bool isDesktop = Device.width > 900;
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final discountsAsync = ref.watch(discountNotifierProvider);
            DiscountEntity? selectedDiscount;

            return StatefulBuilder(
              builder: (context, setState) {
                double finalAmount = amount;
                if (selectedDiscount != null) {
                  final discountAmount = selectedDiscount!
                      .calculateDiscountAmount(amount);
                  finalAmount = (amount - discountAmount).clamp(
                    0,
                    double.infinity,
                  );
                }

                return AlertDialog(
                  title: Text(
                    "Complete Payment",
                    style: TextStyle(fontSize: isDesktop ? 14.sp : 18.sp),
                  ),
                  content: SizedBox(
                    width: isDesktop ? 30.w : double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Subtotal:",
                              style: TextStyle(
                                fontSize: isDesktop ? 12.sp : 15.sp,
                              ),
                            ),
                            Text(
                              "\$${amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: isDesktop ? 12.sp : 15.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.5.h),
                        Text(
                          "Apply Discount:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isDesktop ? 12.sp : 15.sp,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        if (discountsAsync is DiscountLoaded) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<DiscountEntity>(
                                isExpanded: true,
                                value: selectedDiscount,
                                hint: Text(
                                  "Select Discount",
                                  style: TextStyle(
                                    fontSize: isDesktop ? 11.sp : 14.sp,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: isDesktop ? 1.5.w : 20,
                                ),
                                items: [
                                  DropdownMenuItem<DiscountEntity>(
                                    value: null,
                                    child: Text(
                                      "None",
                                      style: TextStyle(
                                        fontSize: isDesktop ? 11.sp : 14.sp,
                                      ),
                                    ),
                                  ),
                                  ...discountsAsync.discounts.map((d) {
                                    return DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                        "${d.discountCode} (${d.type == 'percentage' ? '${d.value}%' : '\$${d.value}'})",
                                        style: TextStyle(
                                          fontSize: isDesktop ? 11.sp : 14.sp,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    selectedDiscount = val;
                                  });
                                },
                              ),
                            ),
                          ),
                        ] else if (discountsAsync is DiscountLoading) ...[
                          const LinearProgressIndicator(),
                        ],
                        if (selectedDiscount != null) ...[
                          SizedBox(height: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Discount Savings:",
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: isDesktop ? 11.sp : 14.sp,
                                ),
                              ),
                              Text(
                                "- \$${selectedDiscount!.calculateDiscountAmount(amount).toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isDesktop ? 11.sp : 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          child: const Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total To Pay:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 13.sp : 16.sp,
                              ),
                            ),
                            Text(
                              "\$${finalAmount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 16.sp : 20.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: isDesktop ? 11.sp : 14.sp,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          Map<String, dynamic> discountData = {
                            "discounts": [],
                            "totalDiscountAmount": 0,
                          };

                          if (selectedDiscount != null) {
                            discountData = {
                              "discounts": [
                                {
                                  "discountId": selectedDiscount!.id,
                                  "discountAmount": selectedDiscount!
                                      .calculateDiscountAmount(amount),
                                },
                              ],
                              "totalDiscountAmount": selectedDiscount!
                                  .calculateDiscountAmount(amount),
                            };
                          }

                          await ref
                              .read(completeDineInPaymentUseCaseProvider)
                              .call(orderId, {
                                "method": "cash",
                                "amount": finalAmount,
                                "notes": "Paid via App",
                                "discount": discountData,
                              });
                          if (context.mounted) {
                            ref.invalidate(tablesProvider);
                            Navigator.pop(context); // Close dialog
                            context.pop(); // Close detail page
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Confirm Payment",
                        style: TextStyle(fontSize: isDesktop ? 11.sp : 14.sp),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showRemoveItemDialog(
    BuildContext context,
    WidgetRef ref,
    String orderId,
    String itemId,
  ) {
    final bool isDesktop = Device.width > 900;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Remove Item",
            style: TextStyle(fontSize: isDesktop ? 14.sp : 18.sp),
          ),
          content: Text(
            "Are you sure you want to remove this item?",
            style: TextStyle(fontSize: isDesktop ? 12.sp : 15.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "No",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isDesktop ? 11.sp : 14.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  Navigator.pop(context); // Close dialog
                  // Show loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Removing item...',
                        style: TextStyle(fontSize: isDesktop ? 11.sp : 14.sp),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );

                  await ref
                      .read(removeDineInItemUseCaseProvider)
                      .call(orderId, itemId);

                  // Refresh order details
                  ref.invalidate(orderDetailsProvider(orderId));

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Item removed',
                          style: TextStyle(fontSize: isDesktop ? 11.sp : 14.sp),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error: $e',
                          style: TextStyle(fontSize: isDesktop ? 11.sp : 14.sp),
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(
                "Yes, Remove",
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 11.sp : 14.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCancelOrderDialog(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) {
    final bool isDesktop = Device.width > 900;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Cancel Order",
            style: TextStyle(fontSize: isDesktop ? 14.sp : 18.sp),
          ),
          content: Text(
            "Are you sure you want to cancel the entire order and reset this table?",
            style: TextStyle(fontSize: isDesktop ? 12.sp : 15.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "No",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isDesktop ? 11.sp : 14.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  Navigator.pop(context); // Close dialog
                  // Show loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cancelling order...',
                        style: TextStyle(fontSize: isDesktop ? 11.sp : 14.sp),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );

                  await ref
                      .read(removeDineInOrderUseCaseProvider)
                      .call(orderId);

                  // Invalidate tables and navigate back
                  ref.invalidate(tablesProvider);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Order cancelled and table reset',
                          style: TextStyle(fontSize: isDesktop ? 11.sp : 14.sp),
                        ),
                      ),
                    );
                    context.pop(); // Go back to table grid
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error: $e',
                          style: TextStyle(fontSize: isDesktop ? 11.sp : 14.sp),
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(
                "Yes, Cancel Order",
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 11.sp : 14.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
