import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/discount_entity.dart';

/// Remote data source for discounts
abstract class DiscountRemoteDataSource {
  Future<List<DiscountEntity>> getAllDiscounts();
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
}
