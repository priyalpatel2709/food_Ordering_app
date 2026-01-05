import '../../../../core/domain/entities/paginated_data.dart';
import '../../domain/entities/discount_entity.dart';
import '../datasources/discount_remote_data_source.dart';

/// Discount Repository Implementation
class DiscountRepository {
  final DiscountRemoteDataSource _remoteDataSource;

  DiscountRepository(this._remoteDataSource);

  Future<PaginatedData<DiscountEntity>> getAllDiscounts({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final responseDto = await _remoteDataSource.getAllDiscounts(
      page: page,
      limit: limit,
      search: search,
    );
    return responseDto.toPaginatedData((e) => e);
  }

  Future<void> createDiscount(Map<String, dynamic> data) async {
    await _remoteDataSource.createDiscount(data);
  }

  Future<void> updateDiscount(String id, Map<String, dynamic> data) async {
    await _remoteDataSource.updateDiscount(id, data);
  }

  Future<void> deleteDiscount(String id) async {
    await _remoteDataSource.deleteDiscount(id);
  }
}
