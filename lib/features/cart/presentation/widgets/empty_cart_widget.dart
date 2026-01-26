import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Device.width > 900;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 5.w : 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 3.w : 40),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: isDesktop ? 6.w : 80,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: isDesktop ? 18.sp : 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              'Add some delicious items to get started!',
              style: TextStyle(
                fontSize: isDesktop ? 12.sp : 16.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.restaurant_menu,
                color: AppColors.white,
                size: isDesktop ? 1.5.w : 20.sp,
              ),
              label: Text(
                'Browse Menu',
                style: TextStyle(
                  fontSize: isDesktop ? 11.sp : 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 2.w : 32,
                  vertical: isDesktop ? 1.5.h : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
