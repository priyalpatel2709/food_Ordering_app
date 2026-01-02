import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/discount_entity.dart';

/// Remote data source for discounts
abstract class DiscountRemoteDataSource {
  Future<List<DiscountEntity>> getAllDiscounts();
  Future<void> createDiscount(Map<String, dynamic> data);
  Future<void> updateDiscount(String id, Map<String, dynamic> data);
  Future<void> deleteDiscount(String id);
}

class DiscountRemoteDataSourceImpl implements DiscountRemoteDataSource {
  final DioClient _dioClient;

  DiscountRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<DiscountEntity>> getAllDiscounts() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.discount}',
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'success') {
      final discounts = (data['data'] as List)
          .map(
            (discount) =>
                DiscountEntity.fromJson(discount as Map<String, dynamic>),
          )
          .toList();
      return discounts;
    } else {
      throw Exception(data['message'] ?? 'Failed to get discounts');
    }
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
