import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/menu_entity.dart';
import 'items_view_model.dart';
import 'categories_view_model.dart';
import 'customizations_view_model.dart';

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
  final bool isLoadingMore;
  final int currentPage;
  final int totalPages;
  final int totalDocs;
  final String? searchQuery;

  const MenuLoaded(
    this.menus, {
    this.isLoadingMore = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalDocs = 0,
    this.searchQuery,
  });

  MenuLoaded copyWith({
    List<MenuEntity>? menus,
    bool? isLoadingMore,
    int? currentPage,
    int? totalPages,
    int? totalDocs,
    String? searchQuery,
  }) {
    return MenuLoaded(
      menus ?? this.menus,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalDocs: totalDocs ?? this.totalDocs,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
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

  /// Load current menu (Customer view)
  Future<void> loadCurrentMenu() async {
    state = const MenuLoading();

    final result = await ref.read(getCurrentMenuUseCaseProvider).execute();

    result.when(
      success: (menus) {
        state = MenuLoaded(menus, totalDocs: menus.length);
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

  /// Load all menus (Management view)
  Future<void> loadMenus({int page = 1, int limit = 10, String? search}) async {
    if (page == 1) {
      state = const MenuLoading();
    } else {
      if (state is MenuLoaded) {
        state = (state as MenuLoaded).copyWith(isLoadingMore: true);
      }
    }

    final result = await ref
        .read(getAllMenusUseCaseProvider)
        .call(page: page, limit: limit, search: search);

    result.when(
      success: (data) {
        if (page == 1) {
          state = MenuLoaded(
            data.items,
            currentPage: data.page,
            totalPages: data.totalPages,
            totalDocs: data.totalDocs,
            searchQuery: search,
          );
        } else {
          if (state is MenuLoaded) {
            final oldState = state as MenuLoaded;
            state = oldState.copyWith(
              menus: [...oldState.menus, ...data.items],
              isLoadingMore: false,
              currentPage: data.page,
              totalPages: data.totalPages,
              totalDocs: data.totalDocs,
              searchQuery: search ?? oldState.searchQuery,
            );
          }
        }
      },
      failure: (failure) {
        if (state is MenuLoaded) {
          state = (state as MenuLoaded).copyWith(isLoadingMore: false);
        } else {
          state = MenuError(failure.toString());
        }
      },
    );
  }

  /// Load more menus
  Future<void> loadMore() async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      if (currentState.isLoadingMore ||
          currentState.currentPage >= currentState.totalPages) {
        return;
      }
      await loadMenus(
        page: currentState.currentPage + 1,
        search: currentState.searchQuery,
      );
    }
  }

  /// Refresh current menu
  Future<void> refreshCurrentMenu() async {
    await loadCurrentMenu();
  }

  /// Add item to menu
  Future<bool> addItem(Map<String, dynamic> itemData) async {
    final result = await ref
        .read(addItemToMenuUseCaseProvider)
        .callV2(itemData);

    return result.when(
      success: (_) async {
        await ref.read(itemsNotifierProvider.notifier).loadItems();
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
        await ref.read(categoriesNotifierProvider.notifier).loadCategories();
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
        await ref.read(categoriesNotifierProvider.notifier).loadCategories();
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
        await ref.read(categoriesNotifierProvider.notifier).loadCategories();
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
        await ref.read(customizationsNotifierProvider.notifier).loadOptions();
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
        await ref.read(customizationsNotifierProvider.notifier).loadOptions();
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
        await ref.read(customizationsNotifierProvider.notifier).loadOptions();
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
        await ref.read(itemsNotifierProvider.notifier).loadItems();
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Delete menu item
  /// Delete menu item
  Future<bool> deleteItem(String id) async {
    final result = await ref.read(deleteItemUseCaseProvider).call(id);
    return result.when(
      success: (_) async {
        await ref.read(itemsNotifierProvider.notifier).loadItems();
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Create menu
  Future<bool> createMenu(Map<String, dynamic> data) async {
    final result = await ref.read(createMenuUseCaseProvider).call(data);
    return result.when(
      success: (_) async {
        await loadMenus();
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Update menu
  Future<bool> updateMenu(String id, Map<String, dynamic> data) async {
    final result = await ref.read(updateMenuUseCaseProvider).call(id, data);
    return result.when(
      success: (_) async {
        await loadMenus();
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Delete menu
  Future<bool> deleteMenu(String id) async {
    final result = await ref.read(deleteMenuUseCaseProvider).call(id);
    return result.when(
      success: (_) async {
        await loadMenus();
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
