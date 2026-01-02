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
  const CategoriesLoaded(this.categories);
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

  Future<void> loadCategories() async {
    state = const CategoriesLoading();
    final result = await ref.read(getAllCategoriesUseCaseProvider).call();
    result.when(
      success: (categories) => state = CategoriesLoaded(categories),
      failure: (failure) => state = CategoriesError(failure.toString()),
    );
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
