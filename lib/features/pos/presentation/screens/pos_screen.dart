import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../shared/theme/app_colors.dart';
import '../widgets/pos_header.dart';
import '../widgets/category_selector.dart';
import '../widgets/product_grid.dart';
import '../widgets/order_builder.dart';
import '../widgets/pos_footer.dart';
import '../providers/pos_provider.dart';
import '../../../order/presentation/providers/order_provider.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final width = Device.width;

    // Responsive Rules
    final bool isDesktop = width > 1000;
    final bool isMobile = width <= 600;

    // Listen to order state changes
    ref.listen<OrderState>(orderNotifierProvider, (previous, next) {
      if (next is OrderSuccess) {
        ref.read(posNotifierProvider.notifier).clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${next.order.orderId} placed successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next is OrderError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.message}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            const PosHeader(),

            // Error Message (if any)
            if (state.error != null)
              _buildErrorBanner(context, ref, state.error!, isDesktop),

            // Main Content Area
            Expanded(
              child: isMobile
                  ? const MobilePosLayout()
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Panel: Categories (Narrow vertical strip)
                        const SizedBox(
                          width: 120, // Fixed width for category sidebar
                          child: CategorySelector(),
                        ),

                        // Center Panel: Products Grid
                        const Expanded(flex: 3, child: ProductGrid()),

                        // Right Panel: Cart Management
                        SizedBox(
                          width: isDesktop
                              ? 400
                              : 320, // Flexible based on screen
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border(
                                left: BorderSide(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(-4, 0),
                                ),
                              ],
                            ),
                            child: const OrderBuilder(),
                          ),
                        ),
                      ],
                    ),
            ),

            // Footer Bar
            if (!isMobile) const PosFooter(),
          ],
        ),
      ),
      // Mobile Slide-up Cart
      bottomNavigationBar: isMobile ? const MobileCartButton() : null,
    );
  }

  Widget _buildErrorBanner(
    BuildContext context,
    WidgetRef ref,
    String error,
    bool isDesktop,
  ) {
    return Container(
      width: double.infinity,
      color: AppColors.error.withOpacity(0.1),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: isDesktop ? 1.5.w : 20,
          ),
          SizedBox(width: 1.w),
          Expanded(
            child: Text(
              'Error: $error',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => ref
                .read(posNotifierProvider.notifier)
                .fetchProductsAndCategories(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class MobilePosLayout extends StatelessWidget {
  const MobilePosLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CategorySelector(), // Horizontal on mobile
        const Expanded(child: ProductGrid()),
      ],
    );
  }
}

class MobileCartButton extends ConsumerWidget {
  const MobileCartButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    if (state.cartItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, controller) => Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.remove, color: AppColors.grey300),
                    const Expanded(child: OrderBuilder()),
                    const PosFooter(),
                  ],
                ),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            SizedBox(width: 2.w),
            Text(
              'View Cart (${state.cartItems.length} items) - \$${state.summary.total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
