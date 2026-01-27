import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../dine_in/domain/entities/dine_in_session.dart';
import '../../domain/entities/cart_entity.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_card.dart';
import '../widgets/empty_cart_widget.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../../discount/presentation/providers/discount_provider.dart';
import '../../../dine_in/presentation/providers/dine_in_providers.dart';
import '../../../dine_in/domain/entities/dine_in_order_entity.dart';
import '../../../../shared/navigation/navigation_provider.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _isProcessingCheckout = false;

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
    final selectedDiscount = ref.watch(selectedDiscountProvider);

    CartSummary? discountedSummary;
    if (cartState is CartLoaded) {
      final summary = cartState.summary;
      if (selectedDiscount != null) {
        final discountAmount = selectedDiscount.calculateDiscountAmount(
          summary.subtotal,
        );
        discountedSummary = summary.copyWith(
          discountAmount: discountAmount,
          total: (summary.total - discountAmount).clamp(0, double.infinity),
        );
      } else {
        discountedSummary = summary;
      }
    }

    // Listen to order state changes
    ref.listen<OrderState>(orderNotifierProvider, (previous, next) {
      if (next is OrderSuccess) {
        setState(() {
          _isProcessingCheckout = false;
        });

        // Clear cart and discount
        ref.read(cartNotifierProvider.notifier).clearCart();
        ref.read(selectedDiscountProvider.notifier).state = null;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order placed successfully! Order ID: ${next.order.id}',
              style: TextStyle(fontSize: 14.sp),
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );

        // Redirect staff back to dashboard, customers stay/go to home
        final storageService = StorageService();
        final user = storageService.getUser();
        if (user != null && user.role != 'customer') {
          context.go(RouteConstants.staffHome);
        }
      } else if (next is OrderError) {
        setState(() {
          _isProcessingCheckout = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message, style: TextStyle(fontSize: 14.sp)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final bool isDesktop = Device.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 15.sp : 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: isDesktop
            ? null
            : IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 6.w,
                ),
                onPressed: () => context.pop(),
              ),
        actions: [
          if (cartState is CartLoaded && cartState.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: isDesktop ? 1.5.w : 6.w,
              ),
              onPressed: () => _showClearCartDialog(context, ref),
            ),
          if (isDesktop) SizedBox(width: 1.w),
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
        child: _buildContent(context, ref, cartState, discountedSummary),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : (cartState is CartLoaded &&
                    cartState.isNotEmpty &&
                    discountedSummary != null
                ? _buildCheckoutButton(context, ref, discountedSummary)
                : null),
    );
  }

  String _getCheckoutButtonText(WidgetRef ref, CartSummary summary) {
    final session = ref.watch(dineInSessionProvider);
    if (session != null) {
      if (session.orderId == null) {
        return 'Create Order for Table ${session.tableNumber} • \$${summary.total.toStringAsFixed(2)}';
      } else {
        return 'Add to Table ${session.tableNumber} • \$${summary.total.toStringAsFixed(2)}';
      }
    }
    return 'Checkout • \$${summary.total.toStringAsFixed(2)}';
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    CartState state,
    CartSummary? discountedSummary,
  ) {
    final bool isDesktop = Device.width > 900;

    if (state is CartEmpty) {
      return const EmptyCartWidget();
    }

    if (state is CartLoaded) {
      if (isDesktop) {
        return Column(
          children: [
            _buildDineInBanner(ref),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cart Items List
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        children: [
                          ...state.summary.items.map(
                            (item) => _buildCartItem(context, ref, item),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Sidebar: Summary & Checkout
                  Container(
                    width: 30.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade200),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(-5, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(1.5.w),
                            child: Column(
                              children: [
                                if (ref.watch(dineInSessionProvider) == null)
                                  _buildDiscountSection(
                                    context,
                                    ref,
                                    state.summary,
                                  ),
                                if (discountedSummary != null)
                                  CartSummaryCard(summary: discountedSummary),
                              ],
                            ),
                          ),
                        ),
                        if (discountedSummary != null)
                          _buildCheckoutButton(context, ref, discountedSummary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      return Column(
        children: [
          _buildDineInBanner(ref),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Column(
                children: [
                  ...state.summary.items.map(
                    (item) => _buildCartItem(context, ref, item),
                  ),
                  if (ref.watch(dineInSessionProvider) == null)
                    _buildDiscountSection(context, ref, state.summary),
                  if (discountedSummary != null)
                    CartSummaryCard(summary: discountedSummary),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCartItem(
    BuildContext context,
    WidgetRef ref,
    CartItemEntity item,
  ) {
    return CartItemCard(
      item: item,
      onIncrement: () {
        ref.read(cartNotifierProvider.notifier).incrementQuantity(item.id);
      },
      onDecrement: () {
        ref.read(cartNotifierProvider.notifier).decrementQuantity(item.id);
      },
      onRemove: () {
        ref.read(cartNotifierProvider.notifier).removeItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.menuItemName} removed from cart',
              style: TextStyle(fontSize: Device.width > 900 ? 11.sp : 14.sp),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildDineInBanner(WidgetRef ref) {
    final session = ref.watch(dineInSessionProvider);
    if (session == null) return const SizedBox.shrink();

    final bool isDesktop = Device.width > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 2.w : 4.w,
        vertical: isDesktop ? 0.8.h : 1.h,
      ),
      color: AppColors.primary.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.table_restaurant,
            color: AppColors.primary,
            size: isDesktop ? 1.5.w : 5.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'Ordering for Table ${session.tableNumber}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: isDesktop ? 12.sp : 15.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(dineInSessionProvider.notifier).state = null;
            },
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: isDesktop ? 11.sp : 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(
    BuildContext context,
    WidgetRef ref,
    CartSummary summary,
  ) {
    final bool isDesktop = Device.width > 900;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 1.w : 4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: isDesktop
            ? Border(top: BorderSide(color: Colors.grey.shade200))
            : null,
        boxShadow: isDesktop
            ? null
            : [
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
            padding: EdgeInsets.symmetric(vertical: isDesktop ? 1.5.h : 2.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: AppColors.grey300,
            elevation: isDesktop ? 0 : 2,
          ),
          child: _isProcessingCheckout
              ? SizedBox(
                  height: isDesktop ? 2.h : 3.h,
                  width: isDesktop ? 2.h : 3.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      color: AppColors.white,
                      size: isDesktop ? 1.2.w : 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Flexible(
                      child: Text(
                        _getCheckoutButtonText(ref, summary),
                        style: TextStyle(
                          fontSize: isDesktop ? 12.sp : 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _handleCheckout(
    BuildContext context,
    WidgetRef ref,
    CartSummary summary,
  ) async {
    final session = ref.read(dineInSessionProvider);

    if (session != null) {
      await _handleDineInCheckout(context, ref, summary, session);
      return;
    }

    setState(() {
      _isProcessingCheckout = true;
    });

    // ... existing logic for pickup/delivery checkout
    final orderItems = summary.items.map((cartItem) {
      return OrderItemRequest(
        item: cartItem.menuItemId,
        quantity: cartItem.quantity,
        price: cartItem.basePrice,
        customizationOptions: cartItem.selectedCustomizations
            .map((c) => DineInModifier(name: c.name, price: c.price))
            .toList(),
      );
    }).toList();

    final taxIds = summary.items
        .where((item) => item.taxRate != null)
        .map((item) => item.taxRate!.id)
        .toSet()
        .toList();

    final selectedDiscount = ref.read(selectedDiscountProvider);
    final discountIds = selectedDiscount != null
        ? <String>[selectedDiscount.id!]
        : <String>[];

    // Fetch order types to get the correct ID for Take-away
    String otId = '';
    try {
      final orderTypes = await ref.read(getOrderTypesUseCaseProvider).call();
      final takeAway = orderTypes.firstWhere(
        (t) => t.orderType.toLowerCase() == 'take_away',
        orElse: () => orderTypes.first,
      );
      otId = takeAway.id;
    } catch (e) {
      log('Error fetching order types for cart checkout: $e');
    }

    final orderRequest = CreateOrderRequest(
      orderItems: orderItems,
      tax: taxIds,
      discount: discountIds,
      restaurantTipCharge: 0,
      deliveryCharge: 0,
      deliveryTipCharge: 0,
      orderType: otId,
    );

    ref.read(orderNotifierProvider.notifier).createOrder(orderRequest);
  }

  Future<void> _handleDineInCheckout(
    BuildContext context,
    WidgetRef ref,
    CartSummary summary,
    DineInSession session,
  ) async {
    setState(() {
      _isProcessingCheckout = true;
    });

    try {
      final dineInItems = summary.items.map((cartItem) {
        return DineInOrderItem(
          id: '',
          itemId: cartItem.menuItemId,
          name: cartItem.menuItemName,
          quantity: cartItem.quantity,
          price: cartItem.basePrice,
          modifiers: cartItem.selectedCustomizations
              .map((c) => DineInModifier(name: c.name, price: c.price))
              .toList(),
          specialInstructions: cartItem.note,
        );
      }).toList();

      if (session.orderId == null) {
        await ref
            .read(createDineInOrderUseCaseProvider)
            .call(session.tableNumber, items: dineInItems);
      } else {
        await ref
            .read(addItemsToDineInOrderUseCaseProvider)
            .call(session.orderId!, dineInItems);
      }

      ref.read(cartNotifierProvider.notifier).clearCart();
      ref.read(dineInSessionProvider.notifier).state = null;
      ref.invalidate(tablesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Dine-In order updated successfully!',
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        final storageService = StorageService();
        final user = storageService.getUser();
        if (user != null && user.role != 'customer') {
          context.go(RouteConstants.staffHome);
        } else {
          ref.read(bottomNavIndexProvider.notifier).state = 2;
          context.go(RouteConstants.home);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: TextStyle(fontSize: 14.sp)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCheckout = false;
        });
      }
    }
  }

  Widget _buildDiscountSection(
    BuildContext context,
    WidgetRef ref,
    CartSummary summary,
  ) {
    final discountState = ref.watch(discountNotifierProvider);
    final selectedDiscount = ref.watch(selectedDiscountProvider);

    final bool isDesktop = Device.width > 900;

    return Container(
      margin: EdgeInsets.all(isDesktop ? 1.w : 4.w),
      padding: EdgeInsets.all(isDesktop ? 1.w : 4.w),
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
              Icon(
                Icons.local_offer,
                color: AppColors.primary,
                size: isDesktop ? 1.5.w : 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Available Discounts',
                style: TextStyle(
                  fontSize: isDesktop ? 13.sp : 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          switch (discountState) {
            DiscountLoading() => Center(
              child: Padding(
                padding: EdgeInsets.all(2.h),
                child: SizedBox(
                  height: isDesktop ? 2.h : 4.h,
                  width: isDesktop ? 2.h : 4.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            DiscountError(:final message) => Text(
              message,
              style: TextStyle(
                color: AppColors.error,
                fontSize: isDesktop ? 11.sp : 13.sp,
              ),
            ),
            DiscountLoaded(:final discounts) =>
              discounts.isEmpty
                  ? Text(
                      'No discounts available',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: isDesktop ? 11.sp : 14.sp,
                      ),
                    )
                  : Column(
                      children: discounts.map((discount) {
                        final isSelected = selectedDiscount?.id == discount.id;
                        final discountAmount = discount.calculateDiscountAmount(
                          summary.subtotal,
                        );

                        return Container(
                          margin: EdgeInsets.only(bottom: 1.h),
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
                              padding: EdgeInsets.all(isDesktop ? 1.w : 2.w),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.percent,
                                color: AppColors.white,
                                size: isDesktop ? 1.w : 4.w,
                              ),
                            ),
                            title: Text(
                              discount.discountCode ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 11.sp : 14.sp,
                              ),
                            ),
                            subtitle: Text(
                              discount.type == 'percentage'
                                  ? '${discount.value?.toInt()}% off'
                                  : '\$${discount.value?.toStringAsFixed(2)} off',
                              style: TextStyle(
                                fontSize: isDesktop ? 10.sp : 13.sp,
                              ),
                            ),
                            trailing: isSelected
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '-\$${discountAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isDesktop ? 11.sp : 14.sp,
                                        ),
                                      ),
                                      SizedBox(width: 1.w),
                                      Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                        size: isDesktop ? 1.w : 5.w,
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
                                    child: Text(
                                      'Apply',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 11.sp : 14.sp,
                                      ),
                                    ),
                                  ),
                            onTap: () {
                              ref
                                  .read(selectedDiscountProvider.notifier)
                                  .state = isSelected
                                  ? null
                                  : discount;
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
        title: Text('Clear Cart', style: TextStyle(fontSize: 18.sp)),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(fontSize: 16.sp),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(fontSize: 15.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).clearCart();
              ref.read(selectedDiscountProvider.notifier).state = null;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cart cleared',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  duration: const Duration(seconds: 2),
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
            child: Text('Clear', style: TextStyle(fontSize: 15.sp)),
          ),
        ],
      ),
    );
  }
}
