import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/pos_provider.dart';

class PosFooter extends ConsumerWidget {
  const PosFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final hasItems = state.cartItems.isNotEmpty;

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            label: 'Hold Order',
            icon: Icons.pause_circle_outline,
            color: AppColors.secondary,
            onPressed: hasItems ? () {} : null,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            label: 'Clear Cart',
            icon: Icons.delete_sweep_outlined,
            color: AppColors.error,
            onPressed: hasItems
                ? () => ref.read(posNotifierProvider.notifier).clearCart()
                : null,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            label: 'Discount',
            icon: Icons.local_offer_outlined,
            color: AppColors.grey700,
            onPressed: hasItems ? () {} : null,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            label: 'Split Bill',
            icon: Icons.call_split,
            color: AppColors.grey700,
            onPressed: hasItems ? () {} : null,
          ),

          const Spacer(),

          // Primary Action: Pay Now
          SizedBox(
            height: double.infinity,
            width: 280,
            child: ElevatedButton(
              onPressed: hasItems
                  ? () => _showPaymentDialog(context, ref, state.summary.total)
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
                  const Icon(Icons.payments_outlined, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PAY NOW',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Total: \$${state.summary.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: double.infinity,
      width: 110,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: onPressed != null ? color : AppColors.grey300,
          ),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 8),
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
              size: 24,
              color: onPressed != null ? color : AppColors.grey400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: onPressed != null ? color : AppColors.grey500,
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount Payable: \$${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.5,
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
                  'UPI / Wallet',
                  AppColors.secondary,
                  onConfirm,
                ),
                _buildPaymentOption(
                  Icons.call_split,
                  'Split Pay',
                  AppColors.grey700,
                  onConfirm,
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.grey700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
