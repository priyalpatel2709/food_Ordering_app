import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cash_register_dto.dart';
import '../models/cash_history_dto.dart';
import '../models/cash_shift_summary_dto.dart';

abstract class CashRegisterRemoteDataSource {
  Future<List<CashRegisterDto>> getRegisters();
  Future<void> createRegister(String name);
  Future<void> openShift(String id, double openingBalance, String? notes);
  Future<void> addTransaction(
    String id,
    String type,
    double amount,
    String reason,
  );
  Future<CashShiftSummaryDto> closeShift(
    String id,
    double actualCash,
    String? notes,
  );
  Future<List<CashHistoryDto>> getHistory(String id);
}

class CashRegisterRemoteDataSourceImpl implements CashRegisterRemoteDataSource {
  final DioClient _dioClient;

  CashRegisterRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<CashRegisterDto>> getRegisters() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.cashRegisterEndpoint}',
    );
    final List<dynamic> data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => CashRegisterDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createRegister(String name) async {
    await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.cashRegisterEndpoint}',
      data: {'name': name},
    );
  }

  @override
  Future<void> openShift(
    String id,
    double openingBalance,
    String? notes,
  ) async {
    await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.cashRegisterEndpoint}/$id${ApiConstants.openShiftEndpoint}',
      data: {
        'openingBalance': openingBalance,
        if (notes != null) 'notes': notes,
      },
    );
  }

  @override
  Future<void> addTransaction(
    String id,
    String type,
    double amount,
    String reason,
  ) async {
    await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.cashRegisterEndpoint}/$id${ApiConstants.transactionEndpoint}',
      data: {'type': type, 'amount': amount, 'reason': reason},
    );
  }

  @override
  Future<CashShiftSummaryDto> closeShift(
    String id,
    double actualCash,
    String? notes,
  ) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.cashRegisterEndpoint}/$id${ApiConstants.closeShiftEndpoint}',
      data: {'actualCash': actualCash, if (notes != null) 'notes': notes},
    );
    return CashShiftSummaryDto.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<CashHistoryDto>> getHistory(String id) async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.cashRegisterEndpoint}/$id${ApiConstants.historyEndpoint}',
    );
    final List<dynamic> data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => CashHistoryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
