import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../data/datasources/rbac_remote_data_source.dart';
import '../../data/repositories/rbac_repository_impl.dart';
import '../../domain/entities/permission_entity.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/repositories/rbac_repository.dart';
import '../../domain/usecases/rbac_usecases.dart';
import '../../../authentication/domain/entities/user_entity.dart';

// --- Data Source & Repository ---

final rbacRemoteDataSourceProvider = Provider<RbacRemoteDataSource>((ref) {
  return RbacRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final rbacRepositoryProvider = Provider<RbacRepository>((ref) {
  return RbacRepositoryImpl(ref.watch(rbacRemoteDataSourceProvider));
});

// --- Use Cases ---

final getRolesUseCaseProvider = Provider<GetRolesUseCase>((ref) {
  return GetRolesUseCase(ref.watch(rbacRepositoryProvider));
});

final getPermissionsUseCaseProvider = Provider<GetPermissionsUseCase>((ref) {
  return GetPermissionsUseCase(ref.watch(rbacRepositoryProvider));
});

final createRoleUseCaseProvider = Provider<CreateRoleUseCase>((ref) {
  return CreateRoleUseCase(ref.watch(rbacRepositoryProvider));
});

final updateRoleUseCaseProvider = Provider<UpdateRoleUseCase>((ref) {
  return UpdateRoleUseCase(ref.watch(rbacRepositoryProvider));
});

final assignRoleUseCaseProvider = Provider<AssignRoleUseCase>((ref) {
  return AssignRoleUseCase(ref.watch(rbacRepositoryProvider));
});

final getStaffUsersUseCaseProvider = Provider<GetStaffUsersUseCase>((ref) {
  return GetStaffUsersUseCase(ref.watch(rbacRepositoryProvider));
});

// --- Notifiers ---

// Roles Notifier
class RolesNotifier extends StateNotifier<AsyncValue<List<RoleEntity>>> {
  final GetRolesUseCase _getRolesUseCase;

  RolesNotifier(this._getRolesUseCase) : super(const AsyncValue.loading()) {
    getRoles();
  }

  Future<void> getRoles() async {
    state = const AsyncValue.loading();
    try {
      final roles = await _getRolesUseCase();
      state = AsyncValue.data(roles);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addRole(RoleEntity role) {
    state.whenData((roles) => state = AsyncValue.data([...roles, role]));
  }

  void updateRole(RoleEntity updatedRole) {
    state.whenData((roles) {
      final newRoles = roles
          .map((r) => r.id == updatedRole.id ? updatedRole : r)
          .toList();
      state = AsyncValue.data(newRoles);
    });
  }
}

final rolesProvider =
    StateNotifierProvider<RolesNotifier, AsyncValue<List<RoleEntity>>>((ref) {
      return RolesNotifier(ref.watch(getRolesUseCaseProvider));
    });

final createPermissionUseCaseProvider = Provider<CreatePermissionUseCase>((
  ref,
) {
  return CreatePermissionUseCase(ref.watch(rbacRepositoryProvider));
});

// Permissions Notifier
class PermissionsNotifier
    extends StateNotifier<AsyncValue<List<PermissionEntity>>> {
  final GetPermissionsUseCase _getPermissionsUseCase;

  PermissionsNotifier(this._getPermissionsUseCase)
    : super(const AsyncValue.loading()) {
    getPermissions();
  }

  Future<void> getPermissions() async {
    state = const AsyncValue.loading();
    try {
      final perms = await _getPermissionsUseCase();
      state = AsyncValue.data(perms);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addPermission(PermissionEntity permission) {
    state.whenData((perms) => state = AsyncValue.data([...perms, permission]));
  }
}

final permissionsProvider =
    StateNotifierProvider<
      PermissionsNotifier,
      AsyncValue<List<PermissionEntity>>
    >((ref) {
      return PermissionsNotifier(ref.watch(getPermissionsUseCaseProvider));
    });

// Staff Users Notifier
class StaffUsersNotifier extends StateNotifier<AsyncValue<List<UserEntity>>> {
  final GetStaffUsersUseCase _getStaffUsersUseCase;

  StaffUsersNotifier(this._getStaffUsersUseCase)
    : super(const AsyncValue.loading()) {
    getStaffUsers();
  }

  Future<void> getStaffUsers() async {
    state = const AsyncValue.loading();
    try {
      final users = await _getStaffUsersUseCase();
      state = AsyncValue.data(users);
    } catch (e, st) {
      log(' Error getting staff users: $e ,$st');
      state = AsyncValue.error(e, st);
    }
  }

  void updateUser(UserEntity updatedUser) {
    state.whenData((users) {
      final newUsers = users
          .map((u) => u.id == updatedUser.id ? updatedUser : u)
          .toList();
      state = AsyncValue.data(newUsers);
    });
  }
}

final staffUsersProvider =
    StateNotifierProvider<StaffUsersNotifier, AsyncValue<List<UserEntity>>>((
      ref,
    ) {
      return StaffUsersNotifier(ref.watch(getStaffUsersUseCaseProvider));
    });
