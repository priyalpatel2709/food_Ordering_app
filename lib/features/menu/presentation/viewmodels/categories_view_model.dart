import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/menu_entity.dart';

sealed class CategoriesState {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryEntity> categories;
  final int currentPage;
  final int totalPages;
  final int totalDocs;
  final bool isLoadingMore;

  const CategoriesLoaded({
    required this.categories,
    required this.currentPage,
    required this.totalPages,
    required this.totalDocs,
    this.isLoadingMore = false,
  });

  CategoriesLoaded copyWith({
    List<CategoryEntity>? categories,
    int? currentPage,
    int? totalPages,
    int? totalDocs,
    bool? isLoadingMore,
  }) {
    return CategoriesLoaded(
      categories: categories ?? this.categories,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalDocs: totalDocs ?? this.totalDocs,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class CategoriesError extends CategoriesState {
  final String message;
  const CategoriesError(this.message);
}

class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final Ref ref;

  CategoriesNotifier(this.ref) : super(const CategoriesInitial()) {
    loadCategories();
  }

  Future<void> loadCategories({int page = 1, int limit = 10}) async {
    if (page == 1) {
      state = const CategoriesLoading();
    } else {
      final currentState = state;
      if (currentState is CategoriesLoaded) {
        state = currentState.copyWith(isLoadingMore: true);
      }
    }

    final result = await ref
        .read(getAllCategoriesUseCaseProvider)
        .call(page: page, limit: limit);

    result.when(
      success: (paginatedData) {
        if (page == 1) {
          state = CategoriesLoaded(
            categories: paginatedData.items,
            currentPage: paginatedData.page,
            totalPages: paginatedData.totalPages,
            totalDocs: paginatedData.totalDocs,
          );
        } else {
          final currentState = state;
          if (currentState is CategoriesLoaded) {
            state = CategoriesLoaded(
              categories: [...currentState.categories, ...paginatedData.items],
              currentPage: paginatedData.page,
              totalPages: paginatedData.totalPages,
              totalDocs: paginatedData.totalDocs,
            );
          }
        }
      },
      failure: (failure) => state = CategoriesError(failure.toString()),
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is CategoriesLoaded &&
        !currentState.isLoadingMore &&
        currentState.currentPage < currentState.totalPages) {
      await loadCategories(page: currentState.currentPage + 1);
    }
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    final result = await ref.read(createCategoryUseCaseProvider).call(data);
    return result.when(
      success: (_) {
        loadCategories();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> updateCategory(String id, Map<String, dynamic> data) async {
    final result = await ref.read(updateCategoryUseCaseProvider).call(id, data);
    return result.when(
      success: (_) {
        loadCategories();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> deleteCategory(String id) async {
    final result = await ref.read(deleteCategoryUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        loadCategories();
        return true;
      },
      failure: (_) => false,
    );
  }
}

final categoriesNotifierProvider =
    StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
      return CategoriesNotifier(ref);
    });
