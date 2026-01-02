import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/discount_remote_data_source.dart';
import '../../data/repositories/discount_repository.dart';
import '../../domain/entities/discount_entity.dart';
import '../../domain/usecases/create_discount_use_case.dart';
import '../../domain/usecases/update_discount_use_case.dart';
import '../../domain/usecases/delete_discount_use_case.dart';

/// Discount Remote Data Source Provider
final discountRemoteDataSourceProvider = Provider<DiscountRemoteDataSource>((
  ref,
) {
  return DiscountRemoteDataSourceImpl(DioClient());
});

/// Discount Repository Provider
final discountRepositoryProvider = Provider<DiscountRepository>((ref) {
  return DiscountRepository(ref.watch(discountRemoteDataSourceProvider));
});

/// Discount State
sealed class DiscountState {}

class DiscountInitial extends DiscountState {}

class DiscountLoading extends DiscountState {}

class DiscountLoaded extends DiscountState {
  final List<DiscountEntity> discounts;
  final int currentPage;
  final int totalPages;
  final int totalDocs;
  final bool isLoadingMore;

  DiscountLoaded({
    required this.discounts,
    required this.currentPage,
    required this.totalPages,
    required this.totalDocs,
    this.isLoadingMore = false,
  });

  DiscountLoaded copyWith({
    List<DiscountEntity>? discounts,
    int? currentPage,
    int? totalPages,
    int? totalDocs,
    bool? isLoadingMore,
  }) {
    return DiscountLoaded(
      discounts: discounts ?? this.discounts,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalDocs: totalDocs ?? this.totalDocs,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class DiscountError extends DiscountState {
  final String message;
  DiscountError(this.message);
}

/// Discount Notifier
class DiscountNotifier extends StateNotifier<DiscountState> {
  final DiscountRepository _repository;

  DiscountNotifier(this._repository) : super(DiscountInitial());

  /// Get discounts with pagination
  Future<void> loadDiscounts({int page = 1, int limit = 10}) async {
    if (page == 1) {
      state = DiscountLoading();
    } else {
      final currentState = state;
      if (currentState is DiscountLoaded) {
        state = currentState.copyWith(isLoadingMore: true);
      }
    }

    try {
      final paginatedData = await _repository.getAllDiscounts(
        page: page,
        limit: limit,
      );

      if (page == 1) {
        state = DiscountLoaded(
          discounts: paginatedData.items,
          currentPage: paginatedData.page,
          totalPages: paginatedData.totalPages,
          totalDocs: paginatedData.totalDocs,
        );
      } else {
        final currentState = state;
        if (currentState is DiscountLoaded) {
          state = DiscountLoaded(
            discounts: [...currentState.discounts, ...paginatedData.items],
            currentPage: paginatedData.page,
            totalPages: paginatedData.totalPages,
            totalDocs: paginatedData.totalDocs,
          );
        }
      }
    } catch (e, st) {
      log('get discounts error: $e $st');
      state = DiscountError(e.toString());
    }
  }

  /// Alias for compatibility
  Future<void> getValidDiscounts() async => loadDiscounts();

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is DiscountLoaded &&
        !currentState.isLoadingMore &&
        currentState.currentPage < currentState.totalPages) {
      await loadDiscounts(page: currentState.currentPage + 1);
    }
  }

  /// Reset state
  void reset() {
    state = DiscountInitial();
  }

  /// Create discount
  Future<bool> createDiscount(Map<String, dynamic> data) async {
    try {
      await CreateDiscountUseCase(_repository).call(data);
      await getValidDiscounts();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update discount
  Future<bool> updateDiscount(String id, Map<String, dynamic> data) async {
    try {
      await UpdateDiscountUseCase(_repository).call(id, data);
      await getValidDiscounts();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete discount
  Future<bool> deleteDiscount(String id) async {
    try {
      await DeleteDiscountUseCase(_repository).call(id);
      await getValidDiscounts();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Discount Notifier Provider
final discountNotifierProvider =
    StateNotifierProvider<DiscountNotifier, DiscountState>((ref) {
      final repository = ref.watch(discountRepositoryProvider);
      return DiscountNotifier(repository);
    });

/// Selected Discount Provider (for cart page)
final selectedDiscountProvider = StateProvider<DiscountEntity?>((ref) => null);
