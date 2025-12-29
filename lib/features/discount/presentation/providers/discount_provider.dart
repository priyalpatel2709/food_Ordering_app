import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/discount_remote_data_source.dart';
import '../../data/repositories/discount_repository.dart';
import '../../domain/entities/discount_entity.dart';

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
  DiscountLoaded(this.discounts);
}

class DiscountError extends DiscountState {
  final String message;
  DiscountError(this.message);
}

/// Discount Notifier
class DiscountNotifier extends StateNotifier<DiscountState> {
  final DiscountRepository _repository;

  DiscountNotifier(this._repository) : super(DiscountInitial());

  /// Get all valid discounts
  Future<void> getValidDiscounts() async {
    state = DiscountLoading();
    try {
      final discounts = await _repository.getValidDiscounts();
      state = DiscountLoaded(discounts);
    } catch (e) {
      log('get discounts error: $e');
      state = DiscountError(e.toString());
    }
  }

  /// Reset state
  void reset() {
    state = DiscountInitial();
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
