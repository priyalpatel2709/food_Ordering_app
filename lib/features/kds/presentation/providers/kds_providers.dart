import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/kds_remote_datasource.dart';
import '../../domain/entities/kds_order.dart';

final kdsRemoteDataSourceProvider = Provider<KdsRemoteDataSource>((ref) {
  return KdsRemoteDataSource(ref.watch(dioClientProvider));
});

final kdsConfigProvider = FutureProvider<KdsConfig>((ref) async {
  return await ref.watch(kdsRemoteDataSourceProvider).getConfig();
});

// Using a StateNotifier or similar for polling might be better,
// but for now a simple FutureProvider that we can refresh.
final kdsOrdersProvider = FutureProvider<List<KdsOrder>>((ref) async {
  return await ref.watch(kdsRemoteDataSourceProvider).getOrders();
});

// Refresh the orders when an update is received from socket
final kdsSocketProvider = StreamProvider.autoDispose<List<KdsOrder>>((
  ref,
) async* {
  final socketService = ref.watch(socketServiceProvider);
  final authState = ref.watch(authNotifierProvider);

  if (authState is AuthAuthenticated) {
    final restaurantId = '123';

    if (restaurantId != null) {
      log(
        'KDS Page Monitoring Started: Connecting socket and joining room $restaurantId',
      );
      socketService.connect();
      socketService.joinRestaurant(restaurantId);
    }
  }

  // Initial fetch
  try {
    List<KdsOrder> currentOrders = await ref
        .read(kdsRemoteDataSourceProvider)
        .getOrders();
    yield currentOrders;
  } catch (e) {
    log('Error fetching initial KDS orders: $e');
  }

  // Listen for socket updates and re-fetch orders
  await for (final update in socketService.kdsUpdateStream) {
    log(
      'KDS socket update received (${update['operationType']}), re-fetching orders...',
    );
    try {
      final updatedOrders = await ref
          .read(kdsRemoteDataSourceProvider)
          .getOrders();
      yield updatedOrders;
    } catch (e) {
      log('Error re-fetching KDS orders after socket update: $e');
    }
  }
});
