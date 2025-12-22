import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/user_entity.dart';

/// Auth State
/// TODO: When build_runner is fixed, restore Freezed code generation
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

/// Auth State Notifier
/// TODO: When build_runner is fixed, restore @riverpod annotation
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthInitial()) {
    _checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    final result = await ref.read(getCurrentUserUseCaseProvider).execute();

    result.when(
      success: (user) {
        if (user != null) {
          // Set token in DioClient
          ref.read(dioClientProvider).setAuthToken(user.token);
          state = AuthAuthenticated(user);
        } else {
          state = const AuthUnauthenticated();
        }
      },
      failure: (_) {
        state = const AuthUnauthenticated();
      },
    );
  }

  /// Login
  Future<void> login(String email, String password) async {
    state = const AuthLoading();

    final result = await ref
        .read(loginUseCaseProvider)
        .execute(email, password);

    result.when(
      success: (user) {
        state = AuthAuthenticated(user);
      },
      failure: (failure) {
        state = AuthError(
          failure.when(
            server: (message, statusCode) => message,
            network: (message) => message,
            cache: (message) => message,
            validation: (message) => message,
            unauthorized: (message) => message,
            notFound: (message) => message,
            unknown: (message) => message,
          ),
        );
      },
    );
  }

  /// Sign Up
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String restaurantId,
  }) async {
    state = const AuthLoading();

    final result = await ref
        .read(signUpUseCaseProvider)
        .execute(
          name: name,
          email: email,
          password: password,
          restaurantId: restaurantId,
        );

    result.when(
      success: (user) {
        state = AuthAuthenticated(user);
      },
      failure: (failure) {
        state = AuthError(
          failure.when(
            server: (message, statusCode) => message,
            network: (message) => message,
            cache: (message) => message,
            validation: (message) => message,
            unauthorized: (message) => message,
            notFound: (message) => message,
            unknown: (message) => message,
          ),
        );
      },
    );
  }

  /// Logout
  Future<void> logout() async {
    state = const AuthLoading();

    final result = await ref.read(logoutUseCaseProvider).execute();

    result.when(
      success: (_) {
        state = const AuthUnauthenticated();
      },
      failure: (failure) {
        // Even if logout fails, set to unauthenticated
        state = const AuthUnauthenticated();
      },
    );
  }
}

/// Auth Provider
/// Manual provider definition (replaces @riverpod code generation)
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(ref);
});
