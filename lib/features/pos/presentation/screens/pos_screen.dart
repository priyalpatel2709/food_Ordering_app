import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';
import '../widgets/pos_header.dart';
import '../widgets/category_selector.dart';
import '../widgets/product_grid.dart';
import '../widgets/order_builder.dart';
import '../widgets/billing_summary.dart';
import '../widgets/pos_footer.dart';
import '../providers/pos_provider.dart';
import '../../../order/presentation/providers/order_provider.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final bool isDesktop = Device.width > 900;
    final bool isTablet = Device.width > 600 && Device.width <= 900;

    // Listen to order state changes
    ref.listen<OrderState>(orderNotifierProvider, (previous, next) {
      if (next is OrderSuccess) {
        ref.read(posNotifierProvider.notifier).clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${next.order.orderId} placed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (next is OrderError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header Bar
                const PosHeader(),

                if (state.error != null)
                  Container(
                    width: double.infinity,
                    color: AppColors.error.withOpacity(0.1),
                    padding: EdgeInsets.all(1.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: isDesktop ? 1.5.w : 5.w,
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            'Error loading data: ${state.error}',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: isDesktop ? 13.sp : 14.sp,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref
                              .read(posNotifierProvider.notifier)
                              .fetchProductsAndCategories(),
                          child: Text(
                            'Retry',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main Content Area
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Panel: Category & Product Grid
                      Expanded(
                        flex: isDesktop ? 50 : (isTablet ? 45 : 100),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              const CategorySelector(),
                              const Expanded(child: ProductGrid()),
                            ],
                          ),
                        ),
                      ),

                      // Center Panel: Order Builder
                      if (!isTablet || isDesktop)
                        Expanded(
                          flex: isDesktop ? 28 : (isTablet ? 30 : 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border(
                                right: BorderSide(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const OrderBuilder(),
                          ),
                        ),

                      // Right Panel: Billing Summary
                      Expanded(
                        flex: isDesktop ? 22 : (isTablet ? 25 : 0),
                        child: Container(
                          color: AppColors.grey50,
                          child: const BillingSummary(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                const PosFooter(),
              ],
            ),

            if (state.isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
