import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/cash_register.dart';
import '../../domain/entities/cash_history.dart';
import '../../domain/entities/cash_shift_summary.dart';

sealed class CashRegisterState {
  const CashRegisterState();
}

class CashRegisterInitial extends CashRegisterState {
  const CashRegisterInitial();
}

class CashRegisterLoading extends CashRegisterState {
  const CashRegisterLoading();
}

class CashRegisterLoaded extends CashRegisterState {
  final List<CashRegisterEntity> registers;
  const CashRegisterLoaded(this.registers);
}

class CashRegisterError extends CashRegisterState {
  final String message;
  const CashRegisterError(this.message);
}

class CashRegisterNotifier extends StateNotifier<CashRegisterState> {
  final Ref ref;

  CashRegisterNotifier(this.ref) : super(const CashRegisterInitial());

  Future<void> loadRegisters() async {
    state = const CashRegisterLoading();
    final result = await ref.read(getRegistersUseCaseProvider).execute();
    result.when(
      success: (registers) => state = CashRegisterLoaded(registers),
      failure: (failure) => state = CashRegisterError(failure.toString()),
    );
  }

  Future<bool> createRegister(String name) async {
    final result = await ref.read(createRegisterUseCaseProvider).execute(name);
    return result.when(
      success: (_) {
        loadRegisters();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> openShift(
    String id,
    double openingBalance, {
    String? notes,
  }) async {
    final result = await ref
        .read(openShiftUseCaseProvider)
        .execute(id, openingBalance, notes);
    return result.when(
      success: (_) {
        loadRegisters();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> addTransaction(
    String id,
    String type,
    double amount,
    String reason,
  ) async {
    final result = await ref
        .read(addTransactionUseCaseProvider)
        .execute(id, type, amount, reason);
    return result.when(
      success: (_) {
        loadRegisters();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<CashShiftSummaryEntity?> closeShift(
    String id,
    double actualCash, {
    String? notes,
  }) async {
    final result = await ref
        .read(closeShiftUseCaseProvider)
        .execute(id, actualCash, notes);
    return result.when(
      success: (summary) {
        loadRegisters();
        return summary;
      },
      failure: (failure) {
        return null;
      },
    );
  }

  Future<List<CashHistoryEntity>?> getHistory(String id) async {
    final result = await ref.read(getHistoryUseCaseProvider).execute(id);
    return result.when(success: (history) => history, failure: (_) => null);
  }
}

final cashRegisterNotifierProvider =
    StateNotifierProvider<CashRegisterNotifier, CashRegisterState>((ref) {
      return CashRegisterNotifier(ref);
    });
