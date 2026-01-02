import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
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

  /// Add item to menu
  Future<bool> addItem(String menuId, Map<String, dynamic> itemData) async {
    final result = await ref
        .read(addItemToMenuUseCaseProvider)
        .call(menuId, itemData);

    return result.when(
      success: (_) async {
        await loadCurrentMenu(); // Reload to show new item
        return true;
      },
      failure: (failure) {
        return false;
      },
    );
  }

  /// Create category
  Future<bool> createCategory(Map<String, dynamic> data) async {
    final result = await ref.read(createCategoryUseCaseProvider).call(data);
    return result.when(
      success: (_) async {
        await loadCurrentMenu();
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Update category
  Future<bool> updateCategory(String id, Map<String, dynamic> data) async {
    final result = await ref.read(updateCategoryUseCaseProvider).call(id, data);
    return result.when(
      success: (_) async {
        await loadCurrentMenu();
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Delete category
  Future<bool> deleteCategory(String id) async {
    final result = await ref.read(deleteCategoryUseCaseProvider).call(id);
    return result.when(
      success: (_) async {
        await loadCurrentMenu();
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Create customization option
  Future<bool> createCustomizationOption(Map<String, dynamic> data) async {
    final result = await ref
        .read(createCustomizationUseCaseProvider)
        .call(data);
    return result.when(
      success: (_) async {
        await loadCurrentMenu();
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Update customization option
  Future<bool> updateCustomizationOption(
    String id,
    Map<String, dynamic> data,
  ) async {
    final result = await ref
        .read(updateCustomizationUseCaseProvider)
        .call(id, data);
    return result.when(
      success: (_) async {
        await loadCurrentMenu();
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Delete customization option
  Future<bool> deleteCustomizationOption(String id) async {
    final result = await ref.read(deleteCustomizationUseCaseProvider).call(id);
    return result.when(
      success: (_) async {
        await loadCurrentMenu();
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Update menu item
  Future<bool> updateItem(String id, Map<String, dynamic> data) async {
    final result = await ref.read(updateItemUseCaseProvider).call(id, data);
    return result.when(
      success: (_) async {
        await loadCurrentMenu();
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Delete menu item
  Future<bool> deleteItem(String id) async {
    final result = await ref.read(deleteItemUseCaseProvider).call(id);
    return result.when(
      success: (_) async {
        await loadCurrentMenu();
        return true;
      },
      failure: (_) => false,
    );
  }
}

/// Menu Provider
/// Manual provider definition (replaces @riverpod code generation)
final menuNotifierProvider = StateNotifierProvider<MenuNotifier, MenuState>((
  ref,
) {
  return MenuNotifier(ref);
});
