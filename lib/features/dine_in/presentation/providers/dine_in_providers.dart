import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/datasources/dine_in_remote_datasource.dart';
import '../../data/repositories/dine_in_repository_impl.dart';
import '../../domain/repositories/dine_in_repository.dart';
import '../../domain/usecases/get_tables_usecase.dart';
import '../../domain/usecases/create_dine_in_order_usecase.dart';
import '../../domain/usecases/add_items_to_dine_in_order_usecase.dart';
import '../../domain/usecases/complete_dine_in_payment_usecase.dart';
import '../../domain/usecases/get_order_details_usecase.dart';
import '../../domain/usecases/remove_dine_in_order_usecase.dart';
import '../../domain/usecases/remove_dine_in_item_usecase.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/dine_in_order_entity.dart';
import '../../domain/entities/dine_in_session.dart';

// Data Source
final dineInRemoteDataSourceProvider = Provider<DineInRemoteDataSource>((ref) {
  return DineInRemoteDataSource(ref.watch(dioClientProvider));
});

// Repository
final dineInRepositoryProvider = Provider<DineInRepository>((ref) {
  return DineInRepositoryImpl(ref.watch(dineInRemoteDataSourceProvider));
});

// Use Cases
final getTablesUseCaseProvider = Provider<GetTablesUseCase>((ref) {
  return GetTablesUseCase(ref.watch(dineInRepositoryProvider));
});

final createDineInOrderUseCaseProvider = Provider<CreateDineInOrderUseCase>((
  ref,
) {
  return CreateDineInOrderUseCase(ref.watch(dineInRepositoryProvider));
});

final addItemsToDineInOrderUseCaseProvider =
    Provider<AddItemsToDineInOrderUseCase>((ref) {
      return AddItemsToDineInOrderUseCase(ref.watch(dineInRepositoryProvider));
    });

final completeDineInPaymentUseCaseProvider =
    Provider<CompleteDineInPaymentUseCase>((ref) {
      return CompleteDineInPaymentUseCase(ref.watch(dineInRepositoryProvider));
    });

final getDineInOrderDetailsUseCaseProvider =
    Provider<GetDineInOrderDetailsUseCase>((ref) {
      return GetDineInOrderDetailsUseCase(ref.watch(dineInRepositoryProvider));
    });

final removeDineInOrderUseCaseProvider = Provider<RemoveDineInOrderUseCase>((
  ref,
) {
  return RemoveDineInOrderUseCase(ref.watch(dineInRepositoryProvider));
});

final removeDineInItemUseCaseProvider = Provider<RemoveDineInItemUseCase>((
  ref,
) {
  return RemoveDineInItemUseCase(ref.watch(dineInRepositoryProvider));
});

// Controllers/State
final tablesProvider = FutureProvider.autoDispose<List<TableEntity>>((
  ref,
) async {
  final useCase = ref.watch(getTablesUseCaseProvider);
  final socketService = ref.watch(socketServiceProvider);

  // Initialize socket connection and join restaurant room
  final storageService = StorageService();
  final restaurantId = storageService.getRestaurantId();
  if (restaurantId != null) {
    socketService.joinRestaurant(restaurantId);
  }

  // Listen for table status updates
  final sub = socketService.tableStatusUpdateStream.listen((data) {
    ref.invalidateSelf();
  });

  // Listen for order deletions
  final delSub = socketService.orderDeletedStream.listen((data) {
    ref.invalidateSelf();
  });

  ref.onDispose(() {
    sub.cancel();
    delSub.cancel();
  });

  return await useCase.call();
});

final orderDetailsProvider = FutureProvider.family
    .autoDispose<DineInOrderEntity, String>((ref, orderId) async {
      final useCase = ref.watch(getDineInOrderDetailsUseCaseProvider);
      final socketService = ref.watch(socketServiceProvider);

      // Listen for order updates (Staff side)
      final sub = socketService.tableOrderUpdateStream.listen((data) {
        if (data['order'] != null && data['order']['_id'] == orderId) {
          ref.invalidateSelf();
        }
      });

      // Listen for group cart updates (Customer side/compatibility)
      final groupSub = socketService.groupCartUpdateStream.listen((data) {
        if (data['order'] != null && data['order']['_id'] == orderId) {
          ref.invalidateSelf();
        }
      });

      // Listen for order deletions
      final delSub = socketService.orderDeletedStream.listen((data) {
        if (data['orderId'] == orderId) {
          ref.invalidateSelf();
        }
      });

      ref.onDispose(() {
        sub.cancel();
        groupSub.cancel();
        delSub.cancel();
      });

      return await useCase.call(orderId);
    });

final dineInSessionProvider = StateProvider<DineInSession?>((ref) => null);
