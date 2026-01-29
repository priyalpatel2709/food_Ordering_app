import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/customer_loyalty_entity.dart';
import '../providers/loyalty_providers.dart';

/// Dialog for redeeming loyalty points
class RedeemPointsDialog extends ConsumerStatefulWidget {
  final CustomerLoyaltyEntity customer;
  final Function(double discountAmount, int pointsRedeemed)? onPointsRedeemed;

  const RedeemPointsDialog({
    super.key,
    required this.customer,
    this.onPointsRedeemed,
  });

  @override
  ConsumerState<RedeemPointsDialog> createState() => _RedeemPointsDialogState();
}

class _RedeemPointsDialogState extends ConsumerState<RedeemPointsDialog> {
  final TextEditingController _pointsController = TextEditingController();
  int _pointsToRedeem = 0;
  double _discountAmount = 0.0;

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  void _updateDiscount(String value) {
    final points = int.tryParse(value) ?? 0;
    setState(() {
      _pointsToRedeem = points;
      _discountAmount = points / 100; // 100 points = $1
    });
  }

  void _setQuickAmount(int points) {
    _pointsController.text = points.toString();
    _updateDiscount(points.toString());
  }

  Future<void> _redeemPoints() async {
    if (_pointsToRedeem <= 0) {
      _showError('Please enter points to redeem');
      return;
    }

    if (_pointsToRedeem > widget.customer.loyaltyPoints.current) {
      _showError(
        'Insufficient points. Available: ${widget.customer.loyaltyPoints.current}',
      );
      return;
    }

    final result = {
      'success': true,
      'discountAmount': _discountAmount,
      'pointsRedeemed': _pointsToRedeem,
    };

    if (widget.onPointsRedeemed != null) {
      widget.onPointsRedeemed!(
        result['discountAmount'] as double,
        result['pointsRedeemed'] as int,
      );
    }
    if (mounted) {
      Navigator.pop(context, result);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loyaltyState = ref.watch(loyaltyNotifierProvider);
    // Use the latest customer data from the provider if it matches the current customer
    final customer = (loyaltyState.customer?.id == widget.customer.id)
        ? loyaltyState.customer!
        : widget.customer;
    final availablePoints = customer.loyaltyPoints.current;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.redeem, color: AppColors.secondary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redeem Points',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        customer.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Available Points Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Points',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$availablePoints',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Worth',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${customer.availableDiscount}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Points Input
            TextField(
              controller: _pointsController,
              decoration: InputDecoration(
                labelText: 'Points to Redeem',
                hintText: 'Enter points',
                prefixIcon: const Icon(Icons.stars),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: '100 points = \$1.00',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _updateDiscount,
            ),
            const SizedBox(height: 16),

            // Quick Select Buttons
            Text(
              'Quick Select',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickSelectButton(
                  points: 100,
                  onTap: () => _setQuickAmount(100),
                  enabled: availablePoints >= 100,
                ),
                _QuickSelectButton(
                  points: 250,
                  onTap: () => _setQuickAmount(250),
                  enabled: availablePoints >= 250,
                ),
                _QuickSelectButton(
                  points: 500,
                  onTap: () => _setQuickAmount(500),
                  enabled: availablePoints >= 500,
                ),
                _QuickSelectButton(
                  points: 1000,
                  onTap: () => _setQuickAmount(1000),
                  enabled: availablePoints >= 1000,
                ),
                _QuickSelectButton(
                  label: 'Max',
                  points: availablePoints,
                  onTap: () => _setQuickAmount(availablePoints),
                  enabled: availablePoints > 0,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Discount Preview
            if (_pointsToRedeem > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discount Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${_discountAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Remaining Points',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${availablePoints - _pointsToRedeem}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Redeem Button
            ElevatedButton.icon(
              onPressed: loyaltyState.isLoading ? null : _redeemPoints,
              icon: loyaltyState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(
                loyaltyState.isLoading ? 'Redeeming...' : 'Redeem Points',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
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

class _QuickSelectButton extends StatelessWidget {
  final String? label;
  final int points;
  final VoidCallback onTap;
  final bool enabled;

  const _QuickSelectButton({
    this.label,
    required this.points,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Text(
              label ?? '$points',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: enabled ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            if (label == null)
              Text(
                '\$${(points / 100).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 10,
                  color: enabled ? AppColors.textSecondary : AppColors.grey300,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
