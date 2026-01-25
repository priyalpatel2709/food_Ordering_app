import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Error loading data: ${state.error}',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
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
                  ),

                // Main Content Area
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Panel: Category & Product Grid
                      Expanded(
                        flex: 5,
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
                      Expanded(
                        flex: 3,
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
                        flex: 2,
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
