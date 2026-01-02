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
  const CustomizationsLoaded(this.options);
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

  Future<void> loadOptions() async {
    state = const CustomizationsLoading();
    final result = await ref.read(getAllCustomizationsUseCaseProvider).call();
    result.when(
      success: (options) => state = CustomizationsLoaded(options),
      failure: (failure) => state = CustomizationsError(failure.toString()),
    );
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
