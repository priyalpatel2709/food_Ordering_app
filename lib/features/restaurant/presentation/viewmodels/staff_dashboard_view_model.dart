import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';

/// Restaurant Staff State
class StaffDashboardState {
  final bool isLoading;
  final Map<String, dynamic>? stats;
  final String? error;

  StaffDashboardState({this.isLoading = false, this.stats, this.error});

  StaffDashboardState copyWith({
    bool? isLoading,
    Map<String, dynamic>? stats,
    String? error,
  }) {
    return StaffDashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      error: error ?? this.error,
    );
  }
}

class StaffDashboardNotifier extends StateNotifier<StaffDashboardState> {
  final Ref _ref;

  StaffDashboardNotifier(this._ref) : super(StaffDashboardState());

  Future<void> loadDashboard({String? startDate, String? endDate}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _ref
        .read(getDashboardStatsUseCaseProvider)
        .execute(startDate: startDate, endDate: endDate);
    result.when(
      success: (stats) =>
          state = state.copyWith(isLoading: false, stats: stats),
      failure: (f) =>
          state = state.copyWith(isLoading: false, error: f.toString()),
    );
  }

  Future<List<int>?> exportReport({String? startDate, String? endDate}) async {
    final result = await _ref
        .read(exportDashboardReportUseCaseProvider)
        .execute(startDate: startDate, endDate: endDate);
    return result.when(success: (bytes) => bytes, failure: (_) => null);
  }
}

final staffDashboardProvider =
    StateNotifierProvider<StaffDashboardNotifier, StaffDashboardState>((ref) {
      return StaffDashboardNotifier(ref);
    });
