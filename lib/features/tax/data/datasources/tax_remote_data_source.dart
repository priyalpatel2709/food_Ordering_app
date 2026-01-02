import '../../../menu/data/dto/menu_dto.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/tax_entity.dart';

abstract class TaxRemoteDataSource {
  Future<PaginatedResponseDto<TaxEntity>> getAllTaxes({
    int page = 1,
    int limit = 10,
  });
  Future<void> createTax(Map<String, dynamic> data);
  Future<void> updateTax(String id, Map<String, dynamic> data);
  Future<void> deleteTax(String id);
}

class TaxRemoteDataSourceImpl implements TaxRemoteDataSource {
  final DioClient _dioClient;

  TaxRemoteDataSourceImpl(this._dioClient);

  @override
  Future<PaginatedResponseDto<TaxEntity>> getAllTaxes({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.taxEndpoint}',
      queryParameters: {'page': page, 'limit': limit},
    );

    return PaginatedResponseDto.fromJson(
      response.data as Map<String, dynamic>,
      (json) => TaxEntity.fromJson(json),
    );
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
