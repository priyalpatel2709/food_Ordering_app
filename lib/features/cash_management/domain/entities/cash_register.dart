import 'package:equatable/equatable.dart';

class CashRegisterEntity extends Equatable {
  final String id;
  final String name;
  final String status; // 'open' or 'closed'
  final CashSessionSummaryEntity? currentSession;

  const CashRegisterEntity({
    required this.id,
    required this.name,
    required this.status,
    this.currentSession,
  });

  bool get isOpen => status == 'open';

  @override
  List<Object?> get props => [id, name, status, currentSession];
}

class CashSessionSummaryEntity extends Equatable {
  final double openingBalance;
  final double totalSales;
  final String status;

  const CashSessionSummaryEntity({
    required this.openingBalance,
    required this.totalSales,
    required this.status,
  });

  @override
  List<Object?> get props => [openingBalance, totalSales, status];
}
