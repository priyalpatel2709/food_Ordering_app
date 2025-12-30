class DineInSession {
  final String tableNumber;
  final String? orderId;

  const DineInSession({required this.tableNumber, this.orderId});

  DineInSession copyWith({String? tableNumber, String? orderId}) {
    return DineInSession(
      tableNumber: tableNumber ?? this.tableNumber,
      orderId: orderId ?? this.orderId,
    );
  }
}
