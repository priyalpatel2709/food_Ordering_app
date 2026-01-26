import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/pos_provider.dart';

class PosFooter extends ConsumerWidget {
  const PosFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDesktop = Device.width > 900;
    final bool isTablet = Device.width > 600 && Device.width <= 900;

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(posNotifierProvider);
        final hasItems = state.cartItems.isNotEmpty;

        return Container(
          height: isDesktop ? 10.h : 90,
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.2.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left Side Actions
              _buildActionButton(
                label: 'Hold',
                icon: Icons.pause_circle_outline,
                color: AppColors.secondary,
                onPressed: hasItems ? () {} : null,
              ),
              SizedBox(width: 1.w),
              _buildActionButton(
                label: 'Clear',
                icon: Icons.delete_sweep_outlined,
                color: AppColors.error,
                onPressed: hasItems
                    ? () => ref.read(posNotifierProvider.notifier).clearCart()
                    : null,
              ),
              SizedBox(width: 1.w),
              _buildActionButton(
                label: 'Discount',
                icon: Icons.local_offer_outlined,
                color: AppColors.grey700,
                onPressed: hasItems ? () {} : null,
              ),
              SizedBox(width: 1.w),
              if (isDesktop || isTablet)
                _buildActionButton(
                  label: 'Split',
                  icon: Icons.call_split,
                  color: AppColors.grey700,
                  onPressed: hasItems ? () {} : null,
                ),

              const Spacer(),

              // Primary Action: Pay Now
              SizedBox(
                height: double.infinity,
                width: isDesktop ? 15.w : 220,
                child: ElevatedButton(
                  onPressed: hasItems
                      ? () => _showPaymentDialog(
                          context,
                          ref,
                          state.summary.total,
                        )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payments_outlined, size: isDesktop ? 2.w : 24),
                      SizedBox(width: 0.8.w),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PAY NOW',
                              style: TextStyle(
                                fontSize: isDesktop ? 15.sp : 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'Total: \$${state.summary.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: isDesktop ? 12.sp : 11,
                                color: AppColors.white.withOpacity(0.9),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    final bool isDesktop = Device.width > 900;
    return SizedBox(
      height: double.infinity,
      width: isDesktop ? 7.w : 80,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: onPressed != null ? color : AppColors.grey300,
          ),
          foregroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 0.5.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: onPressed != null
              ? color.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isDesktop ? 1.5.w : 20,
              color: onPressed != null ? color : AppColors.grey400,
            ),
            SizedBox(height: 0.2.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 12.sp : 10,
                  fontWeight: FontWeight.bold,
                  color: onPressed != null ? color : AppColors.grey500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, WidgetRef ref, double amount) {
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        totalAmount: amount,
        onConfirm: () {
          ref.read(posNotifierProvider.notifier).placeOrder();
          Navigator.pop(context);
        },
      ),
    );
  }
}

class PaymentDialog extends StatelessWidget {
  final double totalAmount;
  final VoidCallback onConfirm;

  const PaymentDialog({
    super.key,
    required this.totalAmount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Device.width > 900;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isDesktop ? 30.w : 400,
        padding: EdgeInsets.all(isDesktop ? 2.w : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Amount Payable: \$${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 3.h),

            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 1.5.h,
              crossAxisSpacing: 1.5.w,
              childAspectRatio: 2.8,
              children: [
                _buildPaymentOption(
                  Icons.money,
                  'Cash',
                  AppColors.success,
                  onConfirm,
                ),
                _buildPaymentOption(
                  Icons.credit_card,
                  'Card',
                  AppColors.primary,
                  onConfirm,
                ),
                _buildPaymentOption(
                  Icons.qr_code,
                  'UPI',
                  AppColors.secondary,
                  onConfirm,
                ),
                _buildPaymentOption(
                  Icons.call_split,
                  'Split',
                  AppColors.grey700,
                  onConfirm,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.grey700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    final bool isDesktop = Device.width > 900;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isDesktop ? 1.5.w : 20),
            SizedBox(width: 0.8.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
