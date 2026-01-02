import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/menu_entity.dart';

sealed class ItemsState {
  const ItemsState();
}

class ItemsInitial extends ItemsState {
  const ItemsInitial();
}

class ItemsLoading extends ItemsState {
  const ItemsLoading();
}

class ItemsLoaded extends ItemsState {
  final List<MenuItemEntity> items;
  const ItemsLoaded(this.items);
}

class ItemsError extends ItemsState {
  final String message;
  const ItemsError(this.message);
}

class ItemsNotifier extends StateNotifier<ItemsState> {
  final Ref ref;

  ItemsNotifier(this.ref) : super(const ItemsInitial()) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = const ItemsLoading();
    final result = await ref.read(getAllItemsUseCaseProvider).call();
    result.when(
      success: (items) => state = ItemsLoaded(items),
      failure: (failure) => state = ItemsError(failure.toString()),
    );
  }

  Future<bool> updateItem(String id, Map<String, dynamic> data) async {
    final result = await ref.read(updateItemUseCaseProvider).call(id, data);
    return result.when(
      success: (_) {
        loadItems();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> deleteItem(String id) async {
    final result = await ref.read(deleteItemUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        loadItems();
        return true;
      },
      failure: (_) => false,
    );
  }
}

final itemsNotifierProvider = StateNotifierProvider<ItemsNotifier, ItemsState>((
  ref,
) {
  return ItemsNotifier(ref);
});
