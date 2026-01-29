import '../../domain/entities/cash_history.dart';

class CashHistoryDto {
  final String id;
  final String registerId;
  final OpenedByDto openedBy;
  final double openingBalance;
  final String? openingNotes;
  final String businessDate;
  final String status;
  final double totalSales;
  final double totalRefunds;
  final double totalPayIns;
  final double totalPayOuts;
  final String openedAt;
  final String? closedAt;
  final List<CashTransactionDto> transactions;
  final double? actualCash;
  final double? expectedCash;
  final double? difference;
  final String? closingNotes;

  const CashHistoryDto({
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

  factory CashHistoryDto.fromJson(Map<String, dynamic> json) {
    return CashHistoryDto(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      registerId: json['registerId'] as String? ?? '',
      openedBy: OpenedByDto.fromJson(json['openedBy']),
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      openingNotes: json['openingNotes'] as String?,
      businessDate: json['businessDate'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0.0,
      totalRefunds: (json['totalRefunds'] as num?)?.toDouble() ?? 0.0,
      totalPayIns: (json['totalPayIns'] as num?)?.toDouble() ?? 0.0,
      totalPayOuts: (json['totalPayOuts'] as num?)?.toDouble() ?? 0.0,
      openedAt: json['openedAt'] as String? ?? '',
      closedAt: json['closedAt'] as String?,
      transactions:
          (json['transactions'] as List<dynamic>?)
              ?.map(
                (e) => CashTransactionDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      actualCash: (json['actualCash'] as num?)?.toDouble(),
      expectedCash: (json['expectedCash'] as num?)?.toDouble(),
      difference: (json['difference'] as num?)?.toDouble(),
      closingNotes: json['closingNotes'] as String?,
    );
  }

  CashHistoryEntity toEntity() {
    return CashHistoryEntity(
      id: id,
      registerId: registerId,
      openedBy: openedBy.toEntity(),
      openingBalance: openingBalance,
      openingNotes: openingNotes,
      businessDate: businessDate,
      status: status,
      totalSales: totalSales,
      totalRefunds: totalRefunds,
      totalPayIns: totalPayIns,
      totalPayOuts: totalPayOuts,
      openedAt: openedAt.isNotEmpty ? DateTime.parse(openedAt) : DateTime.now(),
      closedAt: closedAt != null ? DateTime.parse(closedAt!) : null,
      transactions: transactions.map((e) => e.toEntity()).toList(),
      actualCash: actualCash,
      expectedCash: expectedCash,
      difference: difference,
      closingNotes: closingNotes,
    );
  }
}

class OpenedByDto {
  final String id;
  final String name;

  const OpenedByDto({required this.id, required this.name});

  factory OpenedByDto.fromJson(dynamic json) {
    if (json is String) {
      return OpenedByDto(id: json, name: 'Staff');
    }
    if (json is Map<String, dynamic>) {
      return OpenedByDto(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Staff',
      );
    }
    return const OpenedByDto(id: '', name: 'Staff');
  }

  OpenedByEntity toEntity() {
    return OpenedByEntity(id: id, name: name);
  }
}

class CashTransactionDto {
  final String id;
  final String type;
  final double amount;
  final String reason;
  final String? orderId;
  final String timestamp;
  final String performedBy;

  const CashTransactionDto({
    required this.id,
    required this.type,
    required this.amount,
    required this.reason,
    this.orderId,
    required this.timestamp,
    required this.performedBy,
  });

  factory CashTransactionDto.fromJson(Map<String, dynamic> json) {
    return CashTransactionDto(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String? ?? '',
      orderId: json['orderId'] as String?,
      timestamp: json['timestamp'] as String? ?? '',
      performedBy: json['performedBy'] as String? ?? '',
    );
  }

  CashTransactionEntity toEntity() {
    return CashTransactionEntity(
      id: id,
      type: type,
      amount: amount,
      reason: reason,
      orderId: orderId,
      timestamp: timestamp.isNotEmpty
          ? DateTime.parse(timestamp)
          : DateTime.now(),
      performedBy: performedBy,
    );
  }
}
