import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/menu_entity.dart';

sealed class ItemsState {
  const ItemsState();
}

class ItemsInitial extends ItemsState {
  const ItemsInitial();
}

class ItemsLoading extends ItemsState {
  const ItemsLoading();
}

class ItemsLoaded extends ItemsState {
  final List<MenuItemEntity> items;
  final int currentPage;
  final int totalPages;
  final int totalDocs;
  final bool isLoadingMore;
  final String? searchQuery;

  const ItemsLoaded({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalDocs,
    this.isLoadingMore = false,
    this.searchQuery,
  });

  ItemsLoaded copyWith({
    List<MenuItemEntity>? items,
    int? currentPage,
    int? totalPages,
    int? totalDocs,
    bool? isLoadingMore,
    String? searchQuery,
  }) {
    return ItemsLoaded(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalDocs: totalDocs ?? this.totalDocs,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ItemsError extends ItemsState {
  final String message;
  const ItemsError(this.message);
}

class ItemsNotifier extends StateNotifier<ItemsState> {
  final Ref ref;

  ItemsNotifier(this.ref) : super(const ItemsInitial()) {
    loadItems();
  }

  Future<void> loadItems({int page = 1, int limit = 10, String? search}) async {
    if (page == 1) {
      state = const ItemsLoading();
    } else {
      final currentState = state;
      if (currentState is ItemsLoaded) {
        state = currentState.copyWith(isLoadingMore: true);
      }
    }

    final result = await ref
        .read(getAllItemsUseCaseProvider)
        .call(page: page, limit: limit, search: search);

    result.when(
      success: (paginatedData) {
        if (page == 1) {
          state = ItemsLoaded(
            items: paginatedData.items,
            currentPage: paginatedData.page,
            totalPages: paginatedData.totalPages,
            totalDocs: paginatedData.totalDocs,
            searchQuery: search,
          );
        } else {
          final currentState = state;
          if (currentState is ItemsLoaded) {
            state = ItemsLoaded(
              items: [...currentState.items, ...paginatedData.items],
              currentPage: paginatedData.page,
              totalPages: paginatedData.totalPages,
              totalDocs: paginatedData.totalDocs,
              searchQuery: search ?? currentState.searchQuery,
            );
          }
        }
      },
      failure: (failure) => state = ItemsError(failure.toString()),
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is ItemsLoaded &&
        !currentState.isLoadingMore &&
        currentState.currentPage < currentState.totalPages) {
      await loadItems(
        page: currentState.currentPage + 1,
        search: currentState.searchQuery,
      );
    }
  }

  Future<bool> updateItem(String id, Map<String, dynamic> data) async {
    final result = await ref.read(updateItemUseCaseProvider).call(id, data);
    return result.when(
      success: (_) {
        loadItems();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> deleteItem(String id) async {
    final result = await ref.read(deleteItemUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        loadItems();
        return true;
      },
      failure: (_) => false,
    );
  }
}

final itemsNotifierProvider = StateNotifierProvider<ItemsNotifier, ItemsState>((
  ref,
) {
  return ItemsNotifier(ref);
});
