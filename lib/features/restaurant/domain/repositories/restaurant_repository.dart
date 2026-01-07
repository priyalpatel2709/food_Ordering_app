import '../../../../core/error/result.dart';

abstract class RestaurantRepository {
  Future<Result<Map<String, dynamic>>> getDashboardStats({
    String? startDate,
    String? endDate,
  });
  Future<Result<List<int>>> exportDashboardReport({
    String? startDate,
    String? endDate,
  });
  Future<Result<Map<String, dynamic>?>> getRestaurantSettings(String id);
  Future<Result<void>> createRestaurantSettings(Map<String, dynamic> data);
  Future<Result<void>> updateRestaurantSettings(
    String id,
    Map<String, dynamic> data,
  );
}
