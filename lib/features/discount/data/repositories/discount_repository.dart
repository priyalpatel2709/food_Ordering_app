import '../../domain/entities/discount_entity.dart';
import '../datasources/discount_remote_data_source.dart';

/// Discount Repository Implementation
class DiscountRepository {
  final DiscountRemoteDataSource _remoteDataSource;

  DiscountRepository(this._remoteDataSource);

  Future<List<DiscountEntity>> getAllDiscounts() async {
    return await _remoteDataSource.getAllDiscounts();
  }

  /// Get only valid discounts (active and within date range)
  Future<List<DiscountEntity>> getValidDiscounts() async {
    final allDiscounts = await getAllDiscounts();
    return allDiscounts.where((discount) => discount.isValidNow()).toList();
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
