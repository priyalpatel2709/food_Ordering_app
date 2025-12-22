import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/dio_client.dart';
import '../../data/datasources/local/menu_local_data_source.dart';
import '../../data/datasources/local/user_local_data_source.dart';
import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/datasources/remote/menu_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/menu_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../domain/usecases/get_current_menu_use_case.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';

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
