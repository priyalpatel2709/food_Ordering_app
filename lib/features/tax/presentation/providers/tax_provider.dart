import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/tax_entity.dart';

sealed class TaxState {}

class TaxInitial extends TaxState {}

class TaxLoading extends TaxState {}

class TaxLoaded extends TaxState {
  final List<TaxEntity> taxes;
  TaxLoaded(this.taxes);
}

class TaxError extends TaxState {
  final String message;
  TaxError(this.message);
}

class TaxNotifier extends StateNotifier<TaxState> {
  final Ref _ref;

  TaxNotifier(this._ref) : super(TaxInitial());

  Future<void> loadTaxes() async {
    state = TaxLoading();
    final result = await _ref.read(getAllTaxesUseCaseProvider).call();
    result.when(
      success: (taxes) => state = TaxLoaded(taxes),
      failure: (failure) => state = TaxError(failure.message),
    );
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
