import 'dart:developer';

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
    } on NetworkException catch (e, stackTrace) {
      log('stackTrace $stackTrace');
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
    } on ServerException catch (e, stackTrace) {
      log('stackTrace $stackTrace');
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } on CacheException catch (e, stackTrace) {
      log('stackTrace $stackTrace');
      return Result.failure(Failure.cache(e.message));
    } catch (e, stackTrace) {
      log('stackTrace $stackTrace');
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateMenu(String id, Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.updateMenu(id, data);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateMenuAdvanced(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _remoteDataSource.updateMenuAdvanced(id, data);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<MenuEntity>> getMenuById(String id) async {
    try {
      final menuDto = await _remoteDataSource.getMenuById(id);
      return Result.success(menuDto.toEntity());
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> createMenu(Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.createMenu(data);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> addItemToMenu(
    String menuId,
    Map<String, dynamic> itemData,
  ) async {
    try {
      await _remoteDataSource.addItemToMenu(menuId, itemData);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> createCategory(Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.createCategory(data);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _remoteDataSource.updateCategory(id, data);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    try {
      await _remoteDataSource.deleteCategory(id);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> createCustomizationOption(
    Map<String, dynamic> data,
  ) async {
    try {
      await _remoteDataSource.createCustomizationOption(data);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateCustomizationOption(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _remoteDataSource.updateCustomizationOption(id, data);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteCustomizationOption(String id) async {
    try {
      await _remoteDataSource.deleteCustomizationOption(id);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateItem(String id, Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.updateItem(id, data);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteItem(String id) async {
    try {
      await _remoteDataSource.deleteItem(id);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<List<MenuItemEntity>>> getAllItems() async {
    try {
      final dtos = await _remoteDataSource.getAllItems();
      return Result.success(dtos.map((e) => e.toEntity()).toList());
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<List<CategoryEntity>>> getAllCategories() async {
    try {
      final dtos = await _remoteDataSource.getAllCategories();
      return Result.success(dtos.map((e) => e.toEntity()).toList());
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<List<CustomizationOptionEntity>>>
  getAllCustomizationOptions() async {
    try {
      final dtos = await _remoteDataSource.getAllCustomizationOptions();
      return Result.success(dtos.map((e) => e.toEntity()).toList());
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
