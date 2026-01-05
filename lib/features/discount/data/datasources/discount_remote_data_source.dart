import '../../../menu/data/dto/menu_dto.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/discount_entity.dart';

/// Remote data source for discounts
abstract class DiscountRemoteDataSource {
  Future<PaginatedResponseDto<DiscountEntity>> getAllDiscounts({
    int page = 1,
    int limit = 10,
    String? search,
  });
  Future<void> createDiscount(Map<String, dynamic> data);
  Future<void> updateDiscount(String id, Map<String, dynamic> data);
  Future<void> deleteDiscount(String id);
}

class DiscountRemoteDataSourceImpl implements DiscountRemoteDataSource {
  final DioClient _dioClient;

  DiscountRemoteDataSourceImpl(this._dioClient);

  @override
  Future<PaginatedResponseDto<DiscountEntity>> getAllDiscounts({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.discount}',
      queryParameters: queryParams,
    );

    return PaginatedResponseDto.fromJson(
      response.data as Map<String, dynamic>,
      (json) => DiscountEntity.fromJson(json),
    );
  }

  @override
  Future<void> createDiscount(Map<String, dynamic> data) async {
    await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.discount}',
      data: data,
    );
  }

  @override
  Future<void> updateDiscount(String id, Map<String, dynamic> data) async {
    await _dioClient.patch(
      '${ApiConstants.v1}${ApiConstants.discount}/$id',
      data: data,
    );
  }

  @override
  Future<void> deleteDiscount(String id) async {
    await _dioClient.delete('${ApiConstants.v1}${ApiConstants.discount}/$id');
  }
}
