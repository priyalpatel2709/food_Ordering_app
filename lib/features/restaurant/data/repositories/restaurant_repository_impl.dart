import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource _remoteDataSource;

  RestaurantRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<Map<String, dynamic>>> getDashboardStats({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final stats = await _remoteDataSource.getDashboardStats(
        startDate: startDate,
        endDate: endDate,
      );
      return Result.success(stats);
    } on AppException catch (e) {
      return Result.failure(Failure.server(e.message));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<List<int>>> exportDashboardReport({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final bytes = await _remoteDataSource.exportDashboardReport(
        startDate: startDate,
        endDate: endDate,
      );
      return Result.success(bytes);
    } on AppException catch (e) {
      return Result.failure(Failure.server(e.message));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getRestaurantSettings(String id) async {
    try {
      final settings = await _remoteDataSource.getRestaurantSettings(id);
      return Result.success(settings);
    } on AppException catch (e) {
      return Result.failure(Failure.server(e.message));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> createRestaurantSettings(
    Map<String, dynamic> data,
  ) async {
    try {
      await _remoteDataSource.createRestaurantSettings(data);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(Failure.server(e.message));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateRestaurantSettings(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _remoteDataSource.updateRestaurantSettings(id, data);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(Failure.server(e.message));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
