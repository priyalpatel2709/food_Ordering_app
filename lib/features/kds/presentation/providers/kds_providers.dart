import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
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

// We might want an auto-polling provider
final kdsPollingProvider = StreamProvider<List<KdsOrder>>((ref) async* {
  while (true) {
    try {
      final orders = await ref.read(kdsRemoteDataSourceProvider).getOrders();
      yield orders;
    } catch (e) {
      // log error
    }
    await Future.delayed(const Duration(seconds: 20));
  }
});
