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
import '../../../../features/settings/presentation/providers/settings_provider.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final width = Device.width;

    // Responsive Rules
    final settings = ref.watch(settingsNotifierProvider);
    final bool isDesktop = width > 1000;
    final bool isMobile = width <= 600;

    // Calculate dynamic scaling factor
    double scaleFactor = switch (settings.textScale) {
      TextScale.small => 0.85,
      TextScale.medium => 1.0,
      TextScale.large => 1.25,
    };

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: scaleFactor),
      child: Scaffold(
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
                          if (!settings.leftHandedMode) ...[
                            // Left Panel: Categories
                            SizedBox(
                              width: isDesktop ? 10.w : 120.px,
                              child: const CategorySelector(),
                            ),
                            const Expanded(flex: 3, child: ProductGrid()),
                            _buildCartSidebar(isDesktop),
                          ] else ...[
                            _buildCartSidebar(isDesktop),
                            const Expanded(flex: 3, child: ProductGrid()),
                            // Right Panel: Categories
                            SizedBox(
                              width: isDesktop ? 10.w : 120.px,
                              child: const CategorySelector(),
                            ),
                          ],
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
      ),
    );
  }

  Widget _buildCartSidebar(bool isDesktop) {
    return SizedBox(
      width: isDesktop ? 400.px : 320.px,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            left: BorderSide(color: AppColors.border, width: 1.px),
            right: BorderSide(color: AppColors.border, width: 1.px),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10.px,
              offset: Offset(-4.px, 0),
            ),
          ],
        ),
        child: const OrderBuilder(),
      ),
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
            size: isDesktop ? 1.5.w : 20.px,
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
            child: Text('Retry', style: TextStyle(fontSize: 10.sp)),
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
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.px),
                  ),
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
            borderRadius: BorderRadius.circular(12.px),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            SizedBox(width: 2.w),
            Text(
              'View Cart (${state.cartItems.length} items) - \$${state.summary.total.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
