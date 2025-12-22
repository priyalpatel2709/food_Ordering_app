import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/menu_entity.dart';

/// Menu State
/// TODO: When build_runner is fixed, restore Freezed code generation
sealed class MenuState {
  const MenuState();
}

class MenuInitial extends MenuState {
  const MenuInitial();
}

class MenuLoading extends MenuState {
  const MenuLoading();
}

class MenuLoaded extends MenuState {
  final List<MenuEntity> menus;
  const MenuLoaded(this.menus);
}

class MenuError extends MenuState {
  final String message;
  const MenuError(this.message);
}

/// Menu State Notifier
/// TODO: When build_runner is fixed, restore @riverpod annotation
class MenuNotifier extends StateNotifier<MenuState> {
  final Ref ref;

  MenuNotifier(this.ref) : super(const MenuInitial());

  /// Load current menu
  Future<void> loadCurrentMenu() async {
    state = const MenuLoading();

    final result = await ref.read(getCurrentMenuUseCaseProvider).execute();

    result.when(
      success: (menus) {
        state = MenuLoaded(menus);
      },
      failure: (failure) {
        state = MenuError(
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

  /// Refresh menu
  Future<void> refresh() async {
    await loadCurrentMenu();
  }
}

/// Menu Provider
/// Manual provider definition (replaces @riverpod code generation)
final menuNotifierProvider = StateNotifierProvider<MenuNotifier, MenuState>((
  ref,
) {
  return MenuNotifier(ref);
});
