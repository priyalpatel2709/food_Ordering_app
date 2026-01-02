import '../../../../core/error/result.dart';
import '../repositories/restaurant_repository.dart';

class ExportDashboardReportUseCase {
  final RestaurantRepository _repository;

  ExportDashboardReportUseCase(this._repository);

  Future<Result<List<int>>> execute({String? startDate, String? endDate}) {
    return _repository.exportDashboardReport(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
