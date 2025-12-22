import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_local_data_source.dart';
import '../datasources/menu_remote_data_source.dart';

/// Menu Repository Implementation with caching strategy
class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource _remoteDataSource;
  final MenuLocalDataSource _localDataSource;

  MenuRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Result<List<MenuEntity>>> getCurrentMenu() async {
    try {
      // Try to fetch from remote
      final menuResponseDto = await _remoteDataSource.getCurrentMenu();
      final menus = menuResponseDto.menus.map((m) => m.toEntity()).toList();

      // Cache the response
      try {
        await _localDataSource.cacheMenu(menuResponseDto);
      } catch (e) {
        // Ignore cache errors, we still have the data
      }

      return Result.success(menus);
    } on NetworkException catch (e) {
      // Try to get from cache if network fails
      try {
        final cachedMenu = await _localDataSource.getCachedMenu();
        if (cachedMenu != null) {
          final menus = cachedMenu.menus.map((m) => m.toEntity()).toList();
          return Result.success(menus);
        }
      } catch (_) {
        // Ignore cache errors
      }
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } on CacheException catch (e) {
      return Result.failure(Failure.cache(e.message));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
