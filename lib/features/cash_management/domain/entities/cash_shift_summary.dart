import 'package:equatable/equatable.dart';
import 'cash_history.dart';

class CashShiftSummaryEntity extends Equatable {
  final double expectedBalance;
  final double actualCash;
  final double difference;
  final CashHistoryEntity session;

  const CashShiftSummaryEntity({
    required this.expectedBalance,
    required this.actualCash,
    required this.difference,
    required this.session,
  });

  @override
  List<Object?> get props => [expectedBalance, actualCash, difference, session];
}
