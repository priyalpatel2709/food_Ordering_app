import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/tax_entity.dart';

abstract class TaxRemoteDataSource {
  Future<List<TaxEntity>> getAllTaxes();
  Future<void> createTax(Map<String, dynamic> data);
  Future<void> updateTax(String id, Map<String, dynamic> data);
  Future<void> deleteTax(String id);
}

class TaxRemoteDataSourceImpl implements TaxRemoteDataSource {
  final DioClient _dioClient;

  TaxRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<TaxEntity>> getAllTaxes() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.taxEndpoint}',
    );
    final data = response.data;

    // Handle both {status: success, data: [...]} and direct list
    List<dynamic> list;
    if (data is Map && data['data'] is List) {
      list = data['data'];
    } else if (data is List) {
      list = data;
    } else {
      return [];
    }

    return list
        .map((json) => TaxEntity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createTax(Map<String, dynamic> data) async {
    await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.taxEndpoint}',
      data: data,
    );
  }

  @override
  Future<void> updateTax(String id, Map<String, dynamic> data) async {
    await _dioClient.patch(
      '${ApiConstants.v1}${ApiConstants.taxEndpoint}/$id',
      data: data,
    );
  }

  @override
  Future<void> deleteTax(String id) async {
    await _dioClient.delete(
      '${ApiConstants.v1}${ApiConstants.taxEndpoint}/$id',
    );
  }
}
