class PaymentProcessRequest {
  final String method;
  final double amount;
  final String? notes;
  final String? transactionId;
  final String? gateway;

  const PaymentProcessRequest({
    required this.method,
    required this.amount,
    this.notes,
    this.transactionId,
    this.gateway,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'method': method, 'amount': amount};
    if (notes != null && notes!.isNotEmpty) {
      data['notes'] = notes;
    }
    if (transactionId != null && transactionId!.isNotEmpty) {
      data['transactionId'] = transactionId;
    }
    if (gateway != null && gateway!.isNotEmpty) {
      data['gateway'] = gateway;
    }
    return data;
  }
}
