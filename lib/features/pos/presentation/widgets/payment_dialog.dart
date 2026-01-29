import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../dine_in/domain/entities/payment_entity.dart';
import '../../../cash_management/presentation/viewmodels/cash_register_view_model.dart';

/// Payment dialog for collecting payment method and processing payment
class PaymentDialog extends ConsumerStatefulWidget {
  final double totalAmount;
  final double loyaltyDiscount;
  final Function(PaymentEntity? payment, bool payNow) onConfirmed;

  const PaymentDialog({
    super.key,
    required this.totalAmount,
    required this.loyaltyDiscount,
    required this.onConfirmed,
  });

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  String _selectedMethod = 'cash';
  String? _selectedRegisterId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  double _manualDiscount = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.totalAmount.toStringAsFixed(2);
    // Load registers on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cashRegisterNotifierProvider.notifier).loadRegisters();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  double get _finalAmount {
    final amount =
        widget.totalAmount - widget.loyaltyDiscount - _manualDiscount;
    return amount > 0 ? amount : 0.0;
  }

  void _showDiscountDialog() {
    final controller = TextEditingController();
    bool isPercentage = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Discount'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Fixed Amount'),
                        selected: !isPercentage,
                        onSelected: (v) => setState(() => isPercentage = false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Percentage'),
                        selected: isPercentage,
                        onSelected: (v) => setState(() => isPercentage = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: isPercentage ? 'Percentage (%)' : 'Amount (\$)',
                    hintText: 'Enter value',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final value = double.tryParse(controller.text) ?? 0.0;
                  double discount = 0.0;

                  if (isPercentage) {
                    discount = (widget.totalAmount * value) / 100;
                  } else {
                    discount = value;
                  }

                  if (discount >
                      (widget.totalAmount - widget.loyaltyDiscount)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Discount cannot exceed remaining amount',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context, discount);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    ).then((value) {
      if (value != null && value is double) {
        setState(() {
          _manualDiscount = value;
          // Reset amount field to the new final amount
          _amountController.text = _finalAmount.toStringAsFixed(2);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.px)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500.px),
        padding: EdgeInsets.all(24.px),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.payment, color: AppColors.primary, size: 28.px),
                SizedBox(width: 12.px),
                Expanded(
                  child: Text(
                    'Payment',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            SizedBox(height: 24.px),

            // Amount Summary
            Container(
              padding: EdgeInsets.all(16.px),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.px),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  if (widget.loyaltyDiscount > 0) ...[
                    _summaryRow(
                      'Subtotal',
                      '\$${widget.totalAmount.toStringAsFixed(2)}',
                      false,
                    ),
                    SizedBox(height: 8.px),
                    _summaryRow(
                      'Loyalty Discount',
                      '-\$${widget.loyaltyDiscount.toStringAsFixed(2)}',
                      false,
                      color: AppColors.success,
                    ),
                    Divider(height: 16.px),
                  ],
                  if (_manualDiscount > 0) ...[
                    // Conditionally show Subtotal only if not already shown by loyalty discount logic,
                    // or just accept duplicate subtotal if acceptable.
                    // Better logic: ensure Subtotal is distinct.
                    // Since loyalty block already shows Subtotal if > 0, we check.
                    if (widget.loyaltyDiscount == 0)
                      _summaryRow(
                        'Subtotal',
                        '\$${widget.totalAmount.toStringAsFixed(2)}',
                        false,
                      ),
                    SizedBox(height: 8.px),
                    _summaryRow(
                      'Manual Discount',
                      '-\$${_manualDiscount.toStringAsFixed(2)}',
                      false,
                      color: AppColors.success,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _manualDiscount = 0.0;
                            _amountController.text = _finalAmount
                                .toStringAsFixed(2);
                          });
                        },
                        child: const Text(
                          'Remove',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                    Divider(height: 16.px),
                  ],
                  if (_manualDiscount == 0) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _showDiscountDialog,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Discount'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    Divider(height: 16.px),
                  ],
                  _summaryRow(
                    'Total Due',
                    '\$${_finalAmount.toStringAsFixed(2)}',
                    true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.px),

            // Payment Method Selection
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.px),
            Wrap(
              spacing: 12.px,
              runSpacing: 12.px,
              children: [
                _paymentMethodButton('cash', 'Cash', Icons.money),
                _paymentMethodButton('card', 'Card', Icons.credit_card),
                _paymentMethodButton('upi', 'UPI', Icons.qr_code_scanner),
                _paymentMethodButton('other', 'Other', Icons.more_horiz),
              ],
            ),
            // Cash Register Selection (Visible only for Cash payments)
            if (_selectedMethod == 'cash') ...[
              SizedBox(height: 24.px),
              Text(
                'Select Cash Register',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.px),
              Consumer(
                builder: (context, ref, child) {
                  final cashState = ref.watch(cashRegisterNotifierProvider);
                  if (cashState is CashRegisterLoading) {
                    return const LinearProgressIndicator();
                  }
                  if (cashState is CashRegisterLoaded) {
                    final openRegisters = cashState.registers
                        .where((r) => r.isOpen)
                        .toList();
                    if (openRegisters.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(12.px),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.px),
                        ),
                        child: Text(
                          'No open cash registers found! Please open a register first.',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12.sp,
                          ),
                        ),
                      );
                    }
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.px),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.px),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedRegisterId,
                          hint: const Text('Select an open register'),
                          items: openRegisters.map((r) {
                            return DropdownMenuItem<String>(
                              value: r.id,
                              child: Text(r.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedRegisterId = val);
                          },
                        ),
                      ),
                    );
                  }
                  return Text(
                    'Error loading registers',
                    style: TextStyle(color: AppColors.error),
                  );
                },
              ),
              SizedBox(height: 16.px),
            ],

            SizedBox(height: 16.px),
            // Payment Amount (editable for partial payments)
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount Received',
                hintText: 'Enter amount',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.px),
                ),
                helperText: 'Default: Total Due',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),

            SizedBox(height: 24.px),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handlePayLater(),
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      'Pay Later',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.border, width: 2),
                      padding: EdgeInsets.symmetric(vertical: 16.px),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.px),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.px),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handlePayNow,
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      'Pay Now',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.px),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.px),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isBold, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16.sp : 13.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18.sp : 13.sp,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            color:
                color ?? (isBold ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _paymentMethodButton(String method, String label, IconData icon) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(12.px),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.px, vertical: 14.px),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.grey100,
          borderRadius: BorderRadius.circular(12.px),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2.px : 1.px,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20.px,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(width: 8.px),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePayNow() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedMethod == 'cash' && _selectedRegisterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a cash register'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedMethod == 'cash' && _selectedRegisterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a cash register'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final discountDetails = <DiscountDetails>[];
    double totalDiscount = 0.0;

    if (widget.loyaltyDiscount > 0) {
      discountDetails.add(
        DiscountDetails(
          discountAmount: widget.loyaltyDiscount,
          discountType: 'loyalty_points',
        ),
      );
      totalDiscount += widget.loyaltyDiscount;
    }

    if (_manualDiscount > 0) {
      discountDetails.add(
        DiscountDetails(
          discountAmount: _manualDiscount,
          discountType: 'manual',
        ),
      );
      totalDiscount += _manualDiscount;
    }

    Discount? discount;
    if (discountDetails.isNotEmpty) {
      discount = Discount(
        discounts: discountDetails,
        totalDiscountAmount: totalDiscount,
      );
    }

    final payment = PaymentEntity(
      payment: Payment(
        method: _selectedMethod,
        amount: amount,
        notes: _referenceController.text.isNotEmpty
            ? _referenceController.text
            : null,
        discount: discount,
        cashRegisterId: _selectedRegisterId,
      ),
      customerPhone: null,
      customerEmail: null,
      customerName: null,
    );

    widget.onConfirmed(payment, true); // true = pay now
    Navigator.pop(context);
  }

  void _handlePayLater() {
    // Create order without payment
    widget.onConfirmed(null, false); // false = pay later
    Navigator.pop(context);
  }
}
