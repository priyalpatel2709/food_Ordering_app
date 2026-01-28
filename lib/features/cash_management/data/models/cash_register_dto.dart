import '../../domain/entities/cash_register.dart';

class CashRegisterDto {
  final String id;
  final String name;
  final String status;
  final CashSessionSummaryDto? currentSession;

  const CashRegisterDto({
    required this.id,
    required this.name,
    required this.status,
    this.currentSession,
  });

  factory CashRegisterDto.fromJson(Map<String, dynamic> json) {
    return CashRegisterDto(
      id: json['_id'] as String,
      name: json['name'] as String? ?? 'Unnamed Register',
      status: json['status'] as String? ?? 'closed',
      currentSession: json['currentSession'] != null
          ? CashSessionSummaryDto.fromJson(
              json['currentSession'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  CashRegisterEntity toEntity() {
    return CashRegisterEntity(
      id: id,
      name: name,
      status: status,
      currentSession: currentSession?.toEntity(),
    );
  }
}

class CashSessionSummaryDto {
  final double openingBalance;
  final double totalSales;
  final String status;

  const CashSessionSummaryDto({
    required this.openingBalance,
    required this.totalSales,
    required this.status,
  });

  factory CashSessionSummaryDto.fromJson(Map<String, dynamic> json) {
    return CashSessionSummaryDto(
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'unknown',
    );
  }

  CashSessionSummaryEntity toEntity() {
    return CashSessionSummaryEntity(
      openingBalance: openingBalance,
      totalSales: totalSales,
      status: status,
    );
  }
}
