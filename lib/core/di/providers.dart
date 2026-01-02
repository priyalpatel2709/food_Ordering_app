import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/dio_client.dart';
import '../services/socket_service.dart';
import '../../features/menu/data/datasources/menu_local_data_source.dart';
import '../../features/authentication/data/datasources/local/user_local_data_source.dart';
import '../../features/authentication/data/datasources/remote/auth_remote_data_source.dart';
import '../../features/menu/data/datasources/menu_remote_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/restaurant/data/datasources/restaurant_remote_data_source.dart';
import '../../features/tax/data/datasources/tax_remote_data_source.dart';
import '../network/crud_remote_data_source.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/restaurant/domain/repositories/restaurant_repository.dart';
import '../../features/tax/domain/repositories/tax_repository.dart';
import '../../features/restaurant/data/repositories/restaurant_repository_impl.dart';
import '../../features/tax/data/repositories/tax_repository_impl.dart';
import '../../features/restaurant/domain/usecases/get_dashboard_stats_use_case.dart';
import '../../features/restaurant/domain/usecases/export_dashboard_report_use_case.dart';
import '../../features/restaurant/domain/usecases/restaurant_settings_use_cases.dart';
import '../../features/menu/domain/usecases/get_current_menu_use_case.dart';
import '../../features/authentication/domain/usecases/get_current_user_use_case.dart';
import '../../features/authentication/domain/usecases/login_use_case.dart';
import '../../features/authentication/domain/usecases/logout_use_case.dart';
import '../../features/authentication/domain/usecases/sign_up_use_case.dart';
import '../../features/menu/domain/usecases/update_menu_use_case.dart';
import '../../features/menu/domain/usecases/update_menu_advanced_use_case.dart';
import '../../features/menu/domain/usecases/get_menu_by_id_use_case.dart';
import '../../features/menu/domain/usecases/create_menu_use_case.dart';
import '../../features/menu/domain/usecases/add_item_to_menu_use_case.dart';
import '../../features/menu/domain/usecases/create_category_use_case.dart';
import '../../features/menu/domain/usecases/update_category_use_case.dart';
import '../../features/menu/domain/usecases/delete_category_use_case.dart';
import '../../features/menu/domain/usecases/create_customization_use_case.dart';
import '../../features/menu/domain/usecases/update_customization_use_case.dart';
import '../../features/menu/domain/usecases/delete_customization_use_case.dart';
import '../../features/menu/domain/usecases/update_item_use_case.dart';
import '../../features/menu/domain/usecases/delete_item_use_case.dart';
import '../../features/menu/domain/usecases/get_all_items_use_case.dart';
import '../../features/menu/domain/usecases/get_all_categories_use_case.dart';
import '../../features/menu/domain/usecases/get_all_customizations_use_case.dart';
import '../../features/menu/domain/usecases/get_all_menus_use_case.dart';
import '../../features/tax/domain/usecases/tax_use_cases.dart';

/// Manual Provider Definitions
/// TODO: When build_runner is fixed, restore @riverpod code generation

// ============================================================================
// Core Providers
// ============================================================================

/// Hive Box Provider (replaces AppDatabase)
final hiveBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('Hive box must be initialized in main.dart');
});

/// DioClient Provider
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Socket Service Provider
final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ============================================================================
// Data Source Providers
// ============================================================================

/// Auth Remote Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

/// User Local Data Source Provider
final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  return UserLocalDataSourceImpl(ref.watch(hiveBoxProvider));
});

/// Menu Remote Data Source Provider
final menuRemoteDataSourceProvider = Provider<MenuRemoteDataSource>((ref) {
  return MenuRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

/// Menu Local Data Source Provider
final menuLocalDataSourceProvider = Provider<MenuLocalDataSource>((ref) {
  return MenuLocalDataSourceImpl(ref.watch(hiveBoxProvider));
});

/// CRUD Remote Data Source Provider
final crudRemoteDataSourceProvider = Provider<CrudRemoteDataSource>((ref) {
  return CrudRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

/// Restaurant Remote Data Source Provider
final restaurantRemoteDataSourceProvider = Provider<RestaurantRemoteDataSource>(
  (ref) {
    return RestaurantRemoteDataSourceImpl(ref.watch(dioClientProvider));
  },
);

/// Tax Remote Data Source Provider
final taxRemoteDataSourceProvider = Provider<TaxRemoteDataSource>((ref) {
  return TaxRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

// ============================================================================
// Repository Providers
// ============================================================================

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(userLocalDataSourceProvider),
    ref.watch(dioClientProvider),
  );
});

/// Menu Repository Provider
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepositoryImpl(
    ref.watch(menuRemoteDataSourceProvider),
    ref.watch(menuLocalDataSourceProvider),
  );
});

/// Restaurant Repository Provider
final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return RestaurantRepositoryImpl(
    ref.watch(restaurantRemoteDataSourceProvider),
  );
});

/// Tax Repository Provider
final taxRepositoryProvider = Provider<TaxRepository>((ref) {
  return TaxRepositoryImpl(ref.watch(taxRemoteDataSourceProvider));
});

// ============================================================================
// Use Case Providers
// ============================================================================

/// Login Use Case Provider
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

/// Sign Up Use Case Provider
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

/// Logout Use Case Provider
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

/// Get Current User Use Case Provider
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

/// Get Current Menu Use Case Provider
final getCurrentMenuUseCaseProvider = Provider<GetCurrentMenuUseCase>((ref) {
  return GetCurrentMenuUseCase(ref.watch(menuRepositoryProvider));
});

/// Update Menu Use Case Provider
final updateMenuUseCaseProvider = Provider<UpdateMenuUseCase>((ref) {
  return UpdateMenuUseCase(ref.watch(menuRepositoryProvider));
});

/// Update Menu Advanced Use Case Provider
final updateMenuAdvancedUseCaseProvider = Provider<UpdateMenuAdvancedUseCase>((
  ref,
) {
  return UpdateMenuAdvancedUseCase(ref.watch(menuRepositoryProvider));
});

/// Get Menu By Id Use Case Provider
final getMenuByIdUseCaseProvider = Provider<GetMenuByIdUseCase>((ref) {
  return GetMenuByIdUseCase(ref.watch(menuRepositoryProvider));
});

/// Get All Menus Use Case Provider
final getAllMenusUseCaseProvider = Provider<GetAllMenusUseCase>((ref) {
  return GetAllMenusUseCase(ref.watch(menuRepositoryProvider));
});

/// Create Menu Use Case Provider
final createMenuUseCaseProvider = Provider<CreateMenuUseCase>((ref) {
  return CreateMenuUseCase(ref.watch(menuRepositoryProvider));
});

/// Add Item To Menu Use Case Provider
final addItemToMenuUseCaseProvider = Provider<AddItemToMenuUseCase>((ref) {
  return AddItemToMenuUseCase(ref.watch(menuRepositoryProvider));
});

/// Get Dashboard Stats Use Case Provider
final getDashboardStatsUseCaseProvider = Provider<GetDashboardStatsUseCase>((
  ref,
) {
  return GetDashboardStatsUseCase(ref.watch(restaurantRepositoryProvider));
});

/// Export Dashboard Report Use Case Provider
final exportDashboardReportUseCaseProvider =
    Provider<ExportDashboardReportUseCase>((ref) {
      return ExportDashboardReportUseCase(
        ref.watch(restaurantRepositoryProvider),
      );
    });

/// Get Restaurant Settings Use Case Provider
final getRestaurantSettingsUseCaseProvider =
    Provider<GetRestaurantSettingsUseCase>((ref) {
      return GetRestaurantSettingsUseCase(
        ref.watch(restaurantRepositoryProvider),
      );
    });

/// Update Restaurant Settings Use Case Provider
final updateRestaurantSettingsUseCaseProvider =
    Provider<UpdateRestaurantSettingsUseCase>((ref) {
      return UpdateRestaurantSettingsUseCase(
        ref.watch(restaurantRepositoryProvider),
      );
    });

/// Create Category Use Case Provider
final createCategoryUseCaseProvider = Provider<CreateCategoryUseCase>((ref) {
  return CreateCategoryUseCase(ref.watch(menuRepositoryProvider));
});

/// Update Category Use Case Provider
final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  return UpdateCategoryUseCase(ref.watch(menuRepositoryProvider));
});

/// Delete Category Use Case Provider
final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  return DeleteCategoryUseCase(ref.watch(menuRepositoryProvider));
});

/// Create Customization Use Case Provider
final createCustomizationUseCaseProvider = Provider<CreateCustomizationUseCase>(
  (ref) {
    return CreateCustomizationUseCase(ref.watch(menuRepositoryProvider));
  },
);

/// Update Customization Use Case Provider
final updateCustomizationUseCaseProvider = Provider<UpdateCustomizationUseCase>(
  (ref) {
    return UpdateCustomizationUseCase(ref.watch(menuRepositoryProvider));
  },
);

/// Delete Customization Use Case Provider
final deleteCustomizationUseCaseProvider = Provider<DeleteCustomizationUseCase>(
  (ref) {
    return DeleteCustomizationUseCase(ref.watch(menuRepositoryProvider));
  },
);

/// Update Item Use Case Provider
final updateItemUseCaseProvider = Provider<UpdateItemUseCase>((ref) {
  return UpdateItemUseCase(ref.watch(menuRepositoryProvider));
});

/// Delete Item Use Case Provider
final deleteItemUseCaseProvider = Provider<DeleteItemUseCase>((ref) {
  return DeleteItemUseCase(ref.watch(menuRepositoryProvider));
});

/// Get All Items Use Case Provider
final getAllItemsUseCaseProvider = Provider<GetAllItemsUseCase>((ref) {
  return GetAllItemsUseCase(ref.watch(menuRepositoryProvider));
});

/// Get All Categories Use Case Provider
final getAllCategoriesUseCaseProvider = Provider<GetAllCategoriesUseCase>((
  ref,
) {
  return GetAllCategoriesUseCase(ref.watch(menuRepositoryProvider));
});

/// Get All Customizations Use Case Provider
final getAllCustomizationsUseCaseProvider =
    Provider<GetAllCustomizationsUseCase>((ref) {
      return GetAllCustomizationsUseCase(ref.watch(menuRepositoryProvider));
    });

/// Tax Use Case Providers
final getAllTaxesUseCaseProvider = Provider<GetAllTaxesUseCase>((ref) {
  return GetAllTaxesUseCase(ref.watch(taxRepositoryProvider));
});

final createTaxUseCaseProvider = Provider<CreateTaxUseCase>((ref) {
  return CreateTaxUseCase(ref.watch(taxRepositoryProvider));
});

final updateTaxUseCaseProvider = Provider<UpdateTaxUseCase>((ref) {
  return UpdateTaxUseCase(ref.watch(taxRepositoryProvider));
});

final deleteTaxUseCaseProvider = Provider<DeleteTaxUseCase>((ref) {
  return DeleteTaxUseCase(ref.watch(taxRepositoryProvider));
});
