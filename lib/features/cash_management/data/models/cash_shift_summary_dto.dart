import '../../domain/entities/cash_shift_summary.dart';
import 'cash_history_dto.dart';

class CashShiftSummaryDto {
  final double expectedBalance;
  final double actualCash;
  final double difference;
  final CashHistoryDto session;

  const CashShiftSummaryDto({
    required this.expectedBalance,
    required this.actualCash,
    required this.difference,
    required this.session,
  });

  factory CashShiftSummaryDto.fromJson(Map<String, dynamic> json) {
    return CashShiftSummaryDto(
      expectedBalance: (json['expectedBalance'] as num?)?.toDouble() ?? 0.0,
      actualCash: (json['actualCash'] as num?)?.toDouble() ?? 0.0,
      difference: (json['difference'] as num?)?.toDouble() ?? 0.0,
      session: CashHistoryDto.fromJson(json['session'] as Map<String, dynamic>),
    );
  }

  CashShiftSummaryEntity toEntity() {
    return CashShiftSummaryEntity(
      expectedBalance: expectedBalance,
      actualCash: actualCash,
      difference: difference,
      session: session.toEntity(),
    );
  }
}
