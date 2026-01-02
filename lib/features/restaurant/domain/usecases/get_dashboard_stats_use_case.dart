import '../../../../core/error/result.dart';
import '../repositories/restaurant_repository.dart';

class GetDashboardStatsUseCase {
  final RestaurantRepository _repository;

  GetDashboardStatsUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> execute({
    String? startDate,
    String? endDate,
  }) {
    return _repository.getDashboardStats(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
