class CashHistoryEntity {
  final String id;
  final String registerId;
  final OpenedByEntity openedBy;
  final double openingBalance;
  final String? openingNotes;
  final String businessDate;
  final String status;
  final double totalSales;
  final double totalRefunds;
  final double totalPayIns;
  final double totalPayOuts;
  final DateTime openedAt;
  final DateTime? closedAt;
  final List<CashTransactionEntity> transactions;
  final double? actualCash;
  final double? expectedCash;
  final double? difference;
  final String? closingNotes;

  const CashHistoryEntity({
    required this.id,
    required this.registerId,
    required this.openedBy,
    required this.openingBalance,
    this.openingNotes,
    required this.businessDate,
    required this.status,
    required this.totalSales,
    required this.totalRefunds,
    required this.totalPayIns,
    required this.totalPayOuts,
    required this.openedAt,
    this.closedAt,
    required this.transactions,
    this.actualCash,
    this.expectedCash,
    this.difference,
    this.closingNotes,
  });

  bool get isOpen => status == 'open';
}

class OpenedByEntity {
  final String id;
  final String name;

  const OpenedByEntity({required this.id, required this.name});
}

class CashTransactionEntity {
  final String id;
  final String type;
  final double amount;
  final String reason;
  final String? orderId;
  final DateTime timestamp;
  final String performedBy;

  const CashTransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.reason,
    this.orderId,
    required this.timestamp,
    required this.performedBy,
  });
}
