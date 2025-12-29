import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/cart_entity.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_card.dart';
import '../widgets/empty_cart_widget.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../../discount/presentation/providers/discount_provider.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _isProcessingCheckout = false;

  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    // Fetch valid discounts when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discountNotifierProvider.notifier).getValidDiscounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);

    // Listen to order state changes
    ref.listen<OrderState>(orderNotifierProvider, (previous, next) {
      if (next is OrderSuccess) {
        setState(() {
          _isProcessingCheckout = false;
        });

        // Clear cart
        ref.read(cartNotifierProvider.notifier).clearCart();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order placed successfully! Order ID: ${next.order.id}',
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back to menu
        // context.pop();
      } else if (next is OrderError) {
        setState(() {
          _isProcessingCheckout = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,

        actions: [
          if (cartState is CartLoaded && cartState.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _showClearCartDialog(context, ref),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.grey50,
              AppColors.white,
              AppColors.primaryContainer,
            ],
          ),
        ),
        child: _buildContent(context, ref, cartState),
      ),
      bottomNavigationBar: cartState is CartLoaded && cartState.isNotEmpty
          ? _buildCheckoutButton(context, ref, cartState.summary)
          : null,
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, CartState state) {
    return switch (state) {
      CartEmpty() => const EmptyCartWidget(),
      CartLoaded(:final summary) => SingleChildScrollView(
        child: Column(
          children: [
            // Cart items list
            ...summary.items.map((item) {
              return CartItemCard(
                item: item,
                onIncrement: () {
                  ref
                      .read(cartNotifierProvider.notifier)
                      .incrementQuantity(item.id);
                },
                onDecrement: () {
                  ref
                      .read(cartNotifierProvider.notifier)
                      .decrementQuantity(item.id);
                },
                onRemove: () {
                  ref.read(cartNotifierProvider.notifier).removeItem(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.menuItemName} removed from cart'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            }).toList(),

            // Discount section
            _buildDiscountSection(context, ref, summary),

            // Summary card appears after all items
            CartSummaryCard(summary: summary),
          ],
        ),
      ),
    };
  }

  Widget _buildCheckoutButton(
    BuildContext context,
    WidgetRef ref,
    CartSummary summary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isProcessingCheckout
              ? null
              : () => _handleCheckout(context, ref, summary),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: AppColors.grey300,
          ),
          child: _isProcessingCheckout
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag, color: AppColors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Checkout • \$${summary.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _handleCheckout(
    BuildContext context,
    WidgetRef ref,
    CartSummary summary,
  ) {
    setState(() {
      _isProcessingCheckout = true;
    });

    // Convert cart items to order items
    final orderItems = summary.items.map((cartItem) {
      return OrderItemRequest(
        item: cartItem.menuItemId,
        quantity: cartItem.quantity,
        price: cartItem.basePrice,
        customizationOptions: cartItem.selectedCustomizations
            .map((c) => c.id)
            .toList(),
      );
    }).toList();

    // Collect unique tax IDs from cart items
    final taxIds = summary.items
        .where((item) => item.taxRate != null)
        .map((item) => item.taxRate!.id)
        .toSet()
        .toList();

    // Get selected discount
    final selectedDiscount = ref.read(selectedDiscountProvider);
    final discountIds = selectedDiscount != null
        ? <String>[selectedDiscount.id]
        : <String>[];

    // Create order request
    final orderRequest = CreateOrderRequest(
      orderItems: orderItems,
      tax: taxIds,
      discount: discountIds,
      restaurantTipCharge: 0,
      deliveryCharge: 0,
      deliveryTipCharge: 0,
      restaurantId: _storageService.getRestaurantId() ?? '',
    );

    // Call API
    ref.read(orderNotifierProvider.notifier).createOrder(orderRequest);
  }

  Widget _buildDiscountSection(
    BuildContext context,
    WidgetRef ref,
    CartSummary summary,
  ) {
    final discountState = ref.watch(discountNotifierProvider);
    final selectedDiscount = ref.watch(selectedDiscountProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Available Discounts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Discount list or loading/error state
          switch (discountState) {
            DiscountLoading() => const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
            DiscountError(:final message) => Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
            DiscountLoaded(:final discounts) =>
              discounts.isEmpty
                  ? const Text(
                      'No discounts available',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    )
                  : Column(
                      children: discounts.map((discount) {
                        final isSelected = selectedDiscount?.id == discount.id;
                        final discountAmount = discount.calculateDiscountAmount(
                          summary.subtotal,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.grey300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? AppColors.primaryContainer
                                : AppColors.grey50,
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.percent,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              discount.discountCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              discount.type == 'percentage'
                                  ? '${discount.value.toInt()}% off'
                                  : '\$${discount.value.toStringAsFixed(2)} off',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: isSelected
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '-\$${discountAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                      ),
                                    ],
                                  )
                                : TextButton(
                                    onPressed: () {
                                      ref
                                              .read(
                                                selectedDiscountProvider
                                                    .notifier,
                                              )
                                              .state =
                                          discount;
                                    },
                                    child: const Text('Apply'),
                                  ),
                            onTap: () {
                              if (isSelected) {
                                ref
                                        .read(selectedDiscountProvider.notifier)
                                        .state =
                                    null;
                              } else {
                                ref
                                        .read(selectedDiscountProvider.notifier)
                                        .state =
                                    discount;
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).clearCart();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
