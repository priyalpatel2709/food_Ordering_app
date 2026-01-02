import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/menu_entity.dart';

sealed class CustomizationsState {
  const CustomizationsState();
}

class CustomizationsInitial extends CustomizationsState {
  const CustomizationsInitial();
}

class CustomizationsLoading extends CustomizationsState {
  const CustomizationsLoading();
}

class CustomizationsLoaded extends CustomizationsState {
  final List<CustomizationOptionEntity> options;
  final int currentPage;
  final int totalPages;
  final int totalDocs;
  final bool isLoadingMore;

  const CustomizationsLoaded({
    required this.options,
    required this.currentPage,
    required this.totalPages,
    required this.totalDocs,
    this.isLoadingMore = false,
  });

  CustomizationsLoaded copyWith({
    List<CustomizationOptionEntity>? options,
    int? currentPage,
    int? totalPages,
    int? totalDocs,
    bool? isLoadingMore,
  }) {
    return CustomizationsLoaded(
      options: options ?? this.options,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalDocs: totalDocs ?? this.totalDocs,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class CustomizationsError extends CustomizationsState {
  final String message;
  const CustomizationsError(this.message);
}

class CustomizationsNotifier extends StateNotifier<CustomizationsState> {
  final Ref ref;

  CustomizationsNotifier(this.ref) : super(const CustomizationsInitial()) {
    loadOptions();
  }

  Future<void> loadOptions({int page = 1, int limit = 10}) async {
    if (page == 1) {
      state = const CustomizationsLoading();
    } else {
      final currentState = state;
      if (currentState is CustomizationsLoaded) {
        state = currentState.copyWith(isLoadingMore: true);
      }
    }

    final result = await ref
        .read(getAllCustomizationsUseCaseProvider)
        .call(page: page, limit: limit);

    result.when(
      success: (paginatedData) {
        if (page == 1) {
          state = CustomizationsLoaded(
            options: paginatedData.items,
            currentPage: paginatedData.page,
            totalPages: paginatedData.totalPages,
            totalDocs: paginatedData.totalDocs,
          );
        } else {
          final currentState = state;
          if (currentState is CustomizationsLoaded) {
            state = CustomizationsLoaded(
              options: [...currentState.options, ...paginatedData.items],
              currentPage: paginatedData.page,
              totalPages: paginatedData.totalPages,
              totalDocs: paginatedData.totalDocs,
            );
          }
        }
      },
      failure: (failure) => state = CustomizationsError(failure.toString()),
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is CustomizationsLoaded &&
        !currentState.isLoadingMore &&
        currentState.currentPage < currentState.totalPages) {
      await loadOptions(page: currentState.currentPage + 1);
    }
  }

  Future<bool> createOption(Map<String, dynamic> data) async {
    final result = await ref
        .read(createCustomizationUseCaseProvider)
        .call(data);
    return result.when(
      success: (_) {
        loadOptions();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> updateOption(String id, Map<String, dynamic> data) async {
    final result = await ref
        .read(updateCustomizationUseCaseProvider)
        .call(id, data);
    return result.when(
      success: (_) {
        loadOptions();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> deleteOption(String id) async {
    final result = await ref.read(deleteCustomizationUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        loadOptions();
        return true;
      },
      failure: (_) => false,
    );
  }
}

final customizationsNotifierProvider =
    StateNotifierProvider<CustomizationsNotifier, CustomizationsState>((ref) {
      return CustomizationsNotifier(ref);
    });
