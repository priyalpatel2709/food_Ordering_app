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
import '../network/crud_remote_data_source.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
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

/// Create Menu Use Case Provider
final createMenuUseCaseProvider = Provider<CreateMenuUseCase>((ref) {
  return CreateMenuUseCase(ref.watch(menuRepositoryProvider));
});

/// Add Item To Menu Use Case Provider
final addItemToMenuUseCaseProvider = Provider<AddItemToMenuUseCase>((ref) {
  return AddItemToMenuUseCase(ref.watch(menuRepositoryProvider));
});
