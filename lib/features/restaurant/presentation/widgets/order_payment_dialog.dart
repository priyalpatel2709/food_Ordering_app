import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../../order/domain/entities/payment_process_request.dart';

class OrderPaymentDialog extends ConsumerStatefulWidget {
  final OrderEntity order;

  const OrderPaymentDialog({super.key, required this.order});

  @override
  ConsumerState<OrderPaymentDialog> createState() => _OrderPaymentDialogState();
}

class _OrderPaymentDialogState extends ConsumerState<OrderPaymentDialog> {
  String _selectedMethod = 'cash';
  late TextEditingController _amountController;
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Default to unpaid amount
    final unpaidAmount =
        widget.order.orderFinalCharge - widget.order.payment.totalPaid;
    _amountController = TextEditingController(
      text: unpaidAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Amount must be greater than 0')));
      return;
    }

    // Construct payment data
    String? transactionId;
    if (_selectedMethod != 'cash' && _referenceController.text.isNotEmpty) {
      transactionId = _referenceController.text;
    }

    final paymentData = PaymentProcessRequest(
      method: _selectedMethod,
      amount: amount,
      notes: _notesController.text,
      transactionId: transactionId,
    );

    // Show loading? (The button can show loading)

    // Call generic pay method
    // Make sure 'paymentData' matches what the backend expects in 'payOrder'
    // Usually 'PaymentEntity' structure or 'PaymentData'

    // Based on previous createOrderWithPayment, it used PaymentData.
    // Based on dineIn completePayment, it used PaymentEntity.
    // OrderRepo.payOrder accepts generic Map<String, dynamic>.

    // Let's assume the body expects 'payment': {...} or just fields.
    // Standardizing on: { "payment": { "method": "...", "amount": ... } } seems safe if using generic endpoint.
    // If using dineIn logic, it was: { "method": ..., "amount": ... } directly in body or wrapped?
    // DineInRemoteDataSource.completePayment sends paymentDetails.toJson().
    // PaymentEntity.toJson() wraps in 'payment': {...}.

    final success = await ref
        .read(staffOrdersListNotifierProvider.notifier)
        .payOrder(widget.order.id, paymentData);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment processed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizing logic

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Take Payment',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Order Summary Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _summaryRow('Order ID', '#${widget.order.orderId}'),
                    const Divider(),
                    _summaryRow(
                      'Total Amount',
                      '\$${widget.order.orderFinalCharge.toStringAsFixed(2)}',
                    ),
                    _summaryRow(
                      'Paid So Far',
                      '\$${widget.order.payment.totalPaid.toStringAsFixed(2)}',
                    ),
                    const Divider(),
                    _summaryRow(
                      'Remaining Due',
                      '\$${(widget.order.orderFinalCharge - widget.order.payment.totalPaid).toStringAsFixed(2)}',
                      isBold: true,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Payment Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Payment Methods
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _paymentMethodChip('cash', 'Cash', Icons.money),
                  _paymentMethodChip('card', 'Card', Icons.credit_card),
                  _paymentMethodChip('upi', 'UPI', Icons.qr_code),
                  _paymentMethodChip('other', 'Other', Icons.more_horiz),
                ],
              ),
              const SizedBox(height: 24),

              // Amount Input
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount to Pay',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final v = double.tryParse(value);
                  if (v == null || v <= 0) return 'Invalid amount';
                  if (v >
                      (widget.order.orderFinalCharge -
                          widget.order.payment.totalPaid +
                          0.01)) {
                    // Allow small float margin if needed
                    // Optional: Prevent overpayment
                    // return 'Amount exceeds total due';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reference Input
              // Reference Input for transaction ID (Online/Card/UPI)
              if (_selectedMethod != 'cash') ...[
                TextFormField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Reference',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Notes Input
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Confirm Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodChip(String value, String label, IconData icon) {
    final isSelected = _selectedMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
