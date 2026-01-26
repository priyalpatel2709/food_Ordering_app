import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/table_entity.dart';
import 'dine_in_providers.dart';

class TableManagementState {
  final bool isLoading;
  final String? error;
  final List<TableEntity> tables;

  TableManagementState({
    this.isLoading = false,
    this.error,
    this.tables = const [],
  });

  TableManagementState copyWith({
    bool? isLoading,
    String? error,
    List<TableEntity>? tables,
  }) {
    return TableManagementState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tables: tables ?? this.tables,
    );
  }
}

class TableManagementNotifier extends StateNotifier<TableManagementState> {
  final Ref _ref;

  TableManagementNotifier(this._ref) : super(TableManagementState()) {
    loadTables();
  }

  Future<void> loadTables() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tables = await _ref.read(getTablesUseCaseProvider).call();
      state = state.copyWith(isLoading: false, tables: tables);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createTable(String tableNumber, int capacity) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _ref.read(createTableUseCaseProvider).call(tableNumber, capacity);
      await loadTables();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateTable(
    String id,
    String tableNumber,
    int capacity,
    TableStatus status,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _ref
          .read(updateTableUseCaseProvider)
          .call(id, tableNumber, capacity, status);
      await loadTables();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteTable(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _ref.read(deleteTableUseCaseProvider).call(id);
      await loadTables();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final tableManagementProvider =
    StateNotifierProvider<TableManagementNotifier, TableManagementState>((ref) {
      return TableManagementNotifier(ref);
    });
