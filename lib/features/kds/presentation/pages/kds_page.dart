import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/kds_providers.dart';
import '../../domain/entities/kds_order.dart';

class KdsPage extends ConsumerWidget {
  const KdsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(kdsConfigProvider);
    final ordersAsync = ref.watch(kdsSocketProvider);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text('Kitchen Display System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(kdsSocketProvider);
              ref.invalidate(kdsConfigProvider);
            },
          ),
        ],
      ),
      body: configAsync.when(
        data: (config) => ordersAsync.when(
          data: (orders) =>
              _buildKdsBoard(context, ref, config.workflow, orders),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error orders: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error config: $e')),
      ),
    );
  }

  Widget _buildKdsBoard(
    BuildContext context,
    WidgetRef ref,
    List<String> workflow,
    List<KdsOrder> orders,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: workflow.map((stage) {
          final stageOrders = orders
              .where((o) => o.kdsStatus == stage)
              .toList();
          return _buildKdsColumn(context, ref, stage, stageOrders, workflow);
        }).toList(),
      ),
    );
  }

  Widget _buildKdsColumn(
    BuildContext context,
    WidgetRef ref,
    String stage,
    List<KdsOrder> orders,
    List<String> workflow,
  ) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stage.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _OrderCard(order: orders[index], workflow: workflow);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final KdsOrder order;
  final List<String> workflow;

  const _OrderCard({required this.order, required this.workflow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeElapsed = DateTime.now().difference(order.createdAt).inMinutes;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.tableNumber != null
                      ? 'Table ${order.tableNumber}'
                      : 'Order #${order.orderId.split('-').last}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${timeElapsed}m ago',
                  style: TextStyle(
                    color: timeElapsed > 15 ? Colors.red : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${item.quantity}x ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(child: Text(item.name)),
                        GestureDetector(
                          onTap: () => _advanceItemStatus(context, ref, item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.status,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.modifiers.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 24, top: 2),
                        child: Text(
                          item.modifiers.map((m) => '+ $m').join(', '),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _advanceItemStatus(
    BuildContext context,
    WidgetRef ref,
    KdsOrderItem item,
  ) async {
    final currentIndex = workflow.indexOf(item.status);
    if (currentIndex == -1 || currentIndex == workflow.length - 1) return;

    final nextStatus = workflow[currentIndex + 1];

    try {
      await ref
          .read(kdsRemoteDataSourceProvider)
          .updateItemStatus(order.id, item.id, nextStatus);
      ref.invalidate(kdsOrdersProvider);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }
}
