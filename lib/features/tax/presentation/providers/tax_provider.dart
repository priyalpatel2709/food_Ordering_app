import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/tax_entity.dart';

sealed class TaxState {}

class TaxInitial extends TaxState {}

class TaxLoading extends TaxState {}

class TaxLoaded extends TaxState {
  final List<TaxEntity> taxes;
  final int currentPage;
  final int totalPages;
  final int totalDocs;
  final bool isLoadingMore;

  TaxLoaded({
    required this.taxes,
    required this.currentPage,
    required this.totalPages,
    required this.totalDocs,
    this.isLoadingMore = false,
  });

  TaxLoaded copyWith({
    List<TaxEntity>? taxes,
    int? currentPage,
    int? totalPages,
    int? totalDocs,
    bool? isLoadingMore,
  }) {
    return TaxLoaded(
      taxes: taxes ?? this.taxes,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalDocs: totalDocs ?? this.totalDocs,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class TaxError extends TaxState {
  final String message;
  TaxError(this.message);
}

class TaxNotifier extends StateNotifier<TaxState> {
  final Ref _ref;

  TaxNotifier(this._ref) : super(TaxInitial());

  Future<void> loadTaxes({int page = 1, int limit = 10}) async {
    if (page == 1) {
      state = TaxLoading();
    } else {
      final currentState = state;
      if (currentState is TaxLoaded) {
        state = currentState.copyWith(isLoadingMore: true);
      }
    }

    final result = await _ref
        .read(getAllTaxesUseCaseProvider)
        .call(page: page, limit: limit);

    result.when(
      success: (paginatedData) {
        if (page == 1) {
          state = TaxLoaded(
            taxes: paginatedData.items,
            currentPage: paginatedData.page,
            totalPages: paginatedData.totalPages,
            totalDocs: paginatedData.totalDocs,
          );
        } else {
          final currentState = state;
          if (currentState is TaxLoaded) {
            state = TaxLoaded(
              taxes: [...currentState.taxes, ...paginatedData.items],
              currentPage: paginatedData.page,
              totalPages: paginatedData.totalPages,
              totalDocs: paginatedData.totalDocs,
            );
          }
        }
      },
      failure: (failure) => state = TaxError(failure.message),
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is TaxLoaded &&
        !currentState.isLoadingMore &&
        currentState.currentPage < currentState.totalPages) {
      await loadTaxes(page: currentState.currentPage + 1);
    }
  }

  Future<bool> createTax(Map<String, dynamic> data) async {
    final result = await _ref.read(createTaxUseCaseProvider).call(data);
    return result.when(
      success: (_) {
        loadTaxes();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> updateTax(String id, Map<String, dynamic> data) async {
    final result = await _ref.read(updateTaxUseCaseProvider).call(id, data);
    return result.when(
      success: (_) {
        loadTaxes();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> deleteTax(String id) async {
    final result = await _ref.read(deleteTaxUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        loadTaxes();
        return true;
      },
      failure: (_) => false,
    );
  }
}

// These providers will be registered in collectors later, but for now we put them here for use in UI
final taxNotifierProvider = StateNotifierProvider<TaxNotifier, TaxState>((ref) {
  return TaxNotifier(ref);
});
