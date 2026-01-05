import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/dine_in_order_entity.dart';
import '../providers/dine_in_providers.dart';
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
  @override
  Widget build(BuildContext context) {
    // If table is available, show "Start Order"
    if (widget.table.status == TableStatus.available) {
      return _buildAvailableView(context, ref);
    }

    // If occupied but no ID (shouldn't happen ideally if data consistent)
    if (widget.table.currentOrderId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Table ${widget.table.tableNumber}')),
        body: const Center(
          child: Text("Status is occupied but no Order ID found."),
        ),
      );
    }

    // Watch order details
    final orderAsync = ref.watch(
      orderDetailsProvider(widget.table.currentOrderId!),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Table ${widget.table.tableNumber} - Order')),
      body: orderAsync.when(
        data: (order) => _buildOrderView(context, ref, order),
        error: (e, s) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildAvailableView(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Table ${widget.table.tableNumber}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.table_restaurant, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("Table is Available", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(dineInSessionProvider.notifier).state = DineInSession(
                  tableNumber: widget.table.tableNumber,
                );

                // Get user role
                final storageService = StorageService();
                final user = storageService.getUser();

                if (user?.role == 'staff') {
                  context.push(RouteConstants.menu);
                } else {
                  ref.read(bottomNavIndexProvider.notifier).state =
                      0; // Menu Tab
                  context.go(RouteConstants.home);
                }
              },
              icon: const Icon(Icons.restaurant_menu),
              label: const Text("Open Table & Start Order"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderView(
    BuildContext context,
    WidgetRef ref,
    DineInOrderEntity order,
  ) {
    return Column(
      children: [
        // Order Items List
        Expanded(
          child: ListView.builder(
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return ListTile(
                title: Row(
                  children: [
                    Expanded(child: Text(item.name)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        item.status.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
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
                      Text(
                        item.modifiers.map((m) => '+ ${m.name}').join(', '),
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.grey600,
                        ),
                      ),
                    if (item.specialInstructions != null)
                      Text(item.specialInstructions!),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${item.quantity}x  \$${item.price.toStringAsFixed(2)}',
                    ),
                    if (item.status.toLowerCase() == 'new') ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _showRemoveItemDialog(
                          context,
                          ref,
                          order.id,
                          item.id,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        // Footer: Add Items & Pay
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "\$${order.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
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

                              // Get user role
                              final storageService = StorageService();
                              final user = storageService.getUser();

                              if (user?.role == 'staff') {
                                context.push(RouteConstants.menu);
                              } else {
                                ref
                                        .read(bottomNavIndexProvider.notifier)
                                        .state =
                                    0; // Menu Tab
                                context.go(RouteConstants.home);
                              }
                            },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Items"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
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
                      icon: const Icon(Icons.payment),
                      label: const Text("Pay & Close"),
                    ),
                  ),
                ],
              ),
              if (order.status.toLowerCase() == 'pending') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () =>
                        _showCancelOrderDialog(context, ref, order.id),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      "Cancel Order / Reset Table",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    WidgetRef ref,
    String orderId,
    double amount,
  ) {
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
                  title: const Text("Complete Payment"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Subtotal:"),
                          Text("\$${amount.toStringAsFixed(2)}"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Apply Discount:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (discountsAsync is DiscountLoaded) ...[
                        DropdownButton<DiscountEntity>(
                          isExpanded: true,
                          value: selectedDiscount,
                          hint: const Text("Select Discount"),
                          items: [
                            const DropdownMenuItem<DiscountEntity>(
                              value: null,
                              child: Text("None"),
                            ),
                            ...discountsAsync.discounts.map((d) {
                              return DropdownMenuItem(
                                value: d,
                                child: Text(
                                  "${d.discountCode} (${d.type == 'percentage' ? '${d.value}%' : '\$${d.value}'})",
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
                      ] else if (discountsAsync is DiscountLoading) ...[
                        const LinearProgressIndicator(),
                      ],
                      if (selectedDiscount != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Discard:",
                              style: TextStyle(color: Colors.green),
                            ),
                            Text(
                              "- \$${selectedDiscount!.calculateDiscountAmount(amount).toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total To Pay:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "\$${finalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Reset discount selection if needed, but local state handles it
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
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
                      child: const Text("Confirm Payment"),
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Remove Item"),
          content: const Text("Are you sure you want to remove this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  Navigator.pop(context); // Close dialog
                  // Show loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Removing item...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  await ref
                      .read(removeDineInItemUseCaseProvider)
                      .call(orderId, itemId);

                  // Refresh order details
                  ref.invalidate(orderDetailsProvider(orderId));

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item removed')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text(
                "Yes, Remove",
                style: TextStyle(color: Colors.red),
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancel Order"),
          content: const Text(
            "Are you sure you want to cancel the entire order and reset this table?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  Navigator.pop(context); // Close dialog
                  // Show loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cancelling order...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  await ref
                      .read(removeDineInOrderUseCaseProvider)
                      .call(orderId);

                  // Invalidate tables and navigate back
                  ref.invalidate(tablesProvider);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order cancelled and table reset'),
                      ),
                    );
                    context.pop(); // Go back to table grid
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text(
                "Yes, Cancel Order",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
