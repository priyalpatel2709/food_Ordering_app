import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';

class RestaurantSettingsState {
  final bool isLoading;
  final Map<String, dynamic>? settings;
  final String? error;

  RestaurantSettingsState({this.isLoading = false, this.settings, this.error});

  RestaurantSettingsState copyWith({
    bool? isLoading,
    Map<String, dynamic>? settings,
    String? error,
  }) {
    return RestaurantSettingsState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      error: error ?? this.error,
    );
  }
}

class RestaurantSettingsNotifier
    extends StateNotifier<RestaurantSettingsState> {
  final Ref _ref;

  RestaurantSettingsNotifier(this._ref) : super(RestaurantSettingsState());

  Future<void> loadSettings(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _ref
        .read(getRestaurantSettingsUseCaseProvider)
        .execute(id);
    result.when(
      success: (settings) =>
          state = state.copyWith(isLoading: false, settings: settings),
      failure: (f) =>
          state = state.copyWith(isLoading: false, error: f.toString()),
    );
  }

  Future<bool> updateSettings(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _ref
        .read(updateRestaurantSettingsUseCaseProvider)
        .execute(id, data);
    return result.when(
      success: (_) {
        loadSettings(id);
        return true;
      },
      failure: (f) {
        state = state.copyWith(isLoading: false, error: f.toString());
        return false;
      },
    );
  }
}

final restaurantSettingsProvider =
    StateNotifierProvider<RestaurantSettingsNotifier, RestaurantSettingsState>((
      ref,
    ) {
      return RestaurantSettingsNotifier(ref);
    });
