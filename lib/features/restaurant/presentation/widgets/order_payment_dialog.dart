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
    // Check if responsive_sizer is available via context or use MediaQuery
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isDesktop = screenWidth > 900;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : (isDesktop ? 60 : 40),
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? screenWidth : (isDesktop ? 900 : 500),
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fixed Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Take Payment',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  physics: isDesktop
                      ? const ClampingScrollPhysics()
                      : const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Summary
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _sectionHeader('Order Summary'),
                                  _orderSummaryInfo(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            // Right Column: Payment Details
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _sectionHeader('Payment Details'),
                                  _paymentMethodSelection(),
                                  const SizedBox(height: 24),
                                  _paymentInputs(),
                                  const SizedBox(height: 32),
                                  _confirmButton(),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _orderSummaryInfo(),
                            const SizedBox(height: 24),
                            _sectionHeader('Payment Method'),
                            _paymentMethodSelection(),
                            const SizedBox(height: 24),
                            _paymentInputs(),
                            const SizedBox(height: 32),
                            _confirmButton(),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _orderSummaryInfo() {
    return Container(
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
    );
  }

  Widget _paymentMethodSelection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _paymentMethodChip('cash', 'Cash', Icons.money),
        _paymentMethodChip('card', 'Card', Icons.credit_card),
        _paymentMethodChip('upi', 'UPI', Icons.qr_code),
        _paymentMethodChip('other', 'Other', Icons.more_horiz),
      ],
    );
  }

  Widget _paymentInputs() {
    return Column(
      children: [
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: 'Amount to Pay',
            prefixText: '\$',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            final v = double.tryParse(value);
            if (v == null || v <= 0) return 'Invalid amount';
            return null;
          },
        ),
        const SizedBox(height: 16),
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
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes (Optional)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _confirmButton() {
    return ElevatedButton(
      onPressed: _processPayment,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Confirm Payment'),
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
