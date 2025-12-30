import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../data/datasources/dine_in_remote_datasource.dart';
import '../../data/repositories/dine_in_repository_impl.dart';
import '../../domain/repositories/dine_in_repository.dart';
import '../../domain/usecases/get_tables_usecase.dart';
import '../../domain/usecases/create_dine_in_order_usecase.dart';
import '../../domain/usecases/add_items_to_dine_in_order_usecase.dart';
import '../../domain/usecases/complete_dine_in_payment_usecase.dart';
import '../../domain/usecases/get_order_details_usecase.dart';
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

// Controllers/State
final tablesProvider = FutureProvider.autoDispose<List<TableEntity>>((
  ref,
) async {
  final useCase = ref.watch(getTablesUseCaseProvider);
  return await useCase.call();
});

final orderDetailsProvider = FutureProvider.family
    .autoDispose<DineInOrderEntity, String>((ref, orderId) async {
      final useCase = ref.watch(getDineInOrderDetailsUseCaseProvider);
      return await useCase.call(orderId);
    });

final dineInSessionProvider = StateProvider<DineInSession?>((ref) => null);
