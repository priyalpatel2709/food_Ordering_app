import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/kds_providers.dart';
import '../../../../features/rbac/presentation/widgets/permission_guard.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../domain/entities/kds_order.dart';

class KdsPage extends ConsumerWidget {
  const KdsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(kdsConfigProvider);
    final selectedStation = ref.watch(selectedStationProvider);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text(
          selectedStation != null
              ? 'KDS - $selectedStation'
              : 'Kitchen Display System',
        ),
        actions: [
          if (selectedStation != null)
            TextButton.icon(
              onPressed: () {
                ref.read(selectedStationProvider.notifier).state = null;
              },
              icon: const Icon(Icons.change_circle, color: Colors.white),
              label: const Text(
                'Switch Station',
                style: TextStyle(color: Colors.white),
              ),
            ),
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
        data: (config) {
          if (selectedStation == null) {
            return _buildStationSelector(context, ref, config);
          }
          return _buildKdsContent(context, ref, config, selectedStation);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error config: $e')),
      ),
    );
  }

  Widget _buildStationSelector(
    BuildContext context,
    WidgetRef ref,
    KdsConfig config,
  ) {
    final stations = config.stations.keys.toList();

    if (stations.isEmpty) {
      return const Center(child: Text('No stations configured.'));
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Station',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: stations.map((station) {
                return InkWell(
                  onTap: () {
                    ref.read(selectedStationProvider.notifier).state = station;
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.kitchen, size: 48, color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text(
                          station,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${config.stations[station]?.length ?? 0} Categories',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKdsContent(
    BuildContext context,
    WidgetRef ref,
    KdsConfig config,
    String selectedStation,
  ) {
    final ordersAsync = ref.watch(kdsSocketProvider);
    final allowedCategories = config.stations[selectedStation] ?? [];

    return ordersAsync.when(
      data: (allOrders) {
        // Filter orders that have at least one item in the allowed categories
        final filteredOrders = allOrders.where((order) {
          return order.items.any((item) {
            // Check if item category matches one of the allowed categories
            // Case insensitive comparison mostly safer
            return item.category != null &&
                allowedCategories.any(
                  (c) => c.toLowerCase() == item.category!.toLowerCase(),
                );
          });
        }).toList();

        return _buildKdsBoard(
          context,
          ref,
          config.workflow,
          filteredOrders,
          allowedCategories,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error orders: $e')),
    );
  }

  Widget _buildKdsBoard(
    BuildContext context,
    WidgetRef ref,
    List<String> workflow,
    List<KdsOrder> orders,
    List<String> allowedCategories,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: workflow.map((stage) {
          // KDS Status is on Order level, but we are moving items now?
          // The prompt says "Item-Level Status Updates".
          // However, the column logic typically groups by "Order Status" or "Item Status".
          // If items move individually, an order might have items in different columns.
          // TRICKY: KDS usually displays ORDERS. If we display items individually, we change the board to be "Item Cards".
          // BUT KdsOrder has 'id'. The _OrderCard takes 'KdsOrder'.
          // AND `KdsOrder.kdsStatus` exists.

          // Strategy:
          // The columns represent the ITEM workflow status.
          // We will find all ITEMS that are in this stage (and match category).
          // And group them by Order? Or just display distinct Orders that have ANY item in this stage?

          // Common KDS approach:
          // Display the ORDER card in the column corresponding to the "Least Advanced" item status?
          // OR: Display the entire order in every column where it has items?
          // OR: The columns are purely Order status, but we update items inside?
          // The USER says "Instead of moving the whole order, you now move specific items".
          // This implies the columns might represent Item Status.

          // Let's try displaying Orders in columns if they contain items in that status.
          // An order can appear in multiple columns if it has items in different statuses.

          final relevantOrders = orders.where((o) {
            return o.items.any(
              (i) =>
                  i.status == stage &&
                  allowedCategories.any(
                    (c) => c.toLowerCase() == (i.category ?? '').toLowerCase(),
                  ),
            );
          }).toList();

          return _buildKdsColumn(
            context,
            ref,
            stage,
            relevantOrders,
            workflow,
            allowedCategories,
          );
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
    List<String> allowedCategories,
  ) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(stage).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stage.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getStatusColor(stage),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: TextStyle(
                      color: _getStatusColor(stage),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _OrderCard(
                  order: orders[index],
                  workflow: workflow,
                  allowedCategories: allowedCategories,
                  currentStage: stage,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'start':
        return Colors.orange;
      case 'prepared':
        return Colors.green;
      case 'ready':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }
}

class _OrderCard extends ConsumerWidget {
  final KdsOrder order;
  final List<String> workflow;
  final List<String> allowedCategories;
  final String currentStage;

  const _OrderCard({
    required this.order,
    required this.workflow,
    required this.allowedCategories,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeElapsed = DateTime.now().difference(order.createdAt).inMinutes;

    // Filter items to show only those in this stage AND allowed categories
    // Actually, usually in KDS one wants to see ALL relevant items for context, but HIGHLIGHT the ones in this stage?
    // Or just show the ones in this stage?
    // If we only show items in 'new', and the order has 'prepared' items, the chef might get confused.
    // Better approach: Show ALL items relevant to this Station, but clearly mark their status.
    // BUT we are in a column for `currentStage`. Showing items for other stages might be confusing if they look actionable.

    // Let's show ONLY items that belong to `allowedCategories`.
    // And visually emphasize items that are in `currentStage`.

    final stationItems = order.items.where((i) {
      return allowedCategories.any(
        (c) => c.toLowerCase() == (i.category ?? '').toLowerCase(),
      );
    }).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
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
                      ? 'T-${order.tableNumber}'
                      : '#${order.orderId.substring(order.orderId.length - 4)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: timeElapsed > 15
                        ? Colors.red.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: timeElapsed > 15
                          ? Colors.red.shade200
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '${timeElapsed}m',
                    style: TextStyle(
                      color: timeElapsed > 15 ? Colors.red : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...stationItems.map((item) => _buildItemRow(context, ref, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, WidgetRef ref, KdsOrderItem item) {
    final isCurrentStage = item.status == currentStage;

    return Opacity(
      opacity: isCurrentStage ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrentStage
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isCurrentStage
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '${item.quantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCurrentStage ? AppColors.primary : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: isCurrentStage
                          ? FontWeight.w600
                          : FontWeight.normal,
                      decoration:
                          item.status == 'ready' || item.status == 'served'
                          ? TextDecoration.none
                          : null, // Maybe strikethrough if done?
                    ),
                  ),
                ),
              ],
            ),
            if (item.modifiers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 4),
                child: Wrap(
                  spacing: 4,
                  children: item.modifiers
                      .map(
                        (m) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            m,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

            // Action Button
            if (isCurrentStage)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 32),
                child: SizedBox(
                  height: 28,
                  child: PermissionGuard(
                    permission: PermissionConstants.kdsManage,
                    child: ElevatedButton(
                      onPressed: () => _advanceItemStatus(context, ref, item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getActionColor(item.status),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: Text(_getNextActionLabel(item.status)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(String status) {
    final index = workflow.indexOf(status);
    if (index < workflow.length - 1) {
      return AppColors.primary;
    }
    return Colors.green;
  }

  String _getNextActionLabel(String status) {
    final index = workflow.indexOf(status);
    if (index != -1 && index < workflow.length - 1) {
      return 'Mark ${workflow[index + 1].toUpperCase()}'; // Next stage
    }
    return 'Complete';
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
      // Socket will update the UI automatically or manual invalidation
      // The old code invalidated manually:
      ref.invalidate(
        kdsOrdersProvider,
      ); // Invalidate to fetch new state immediately
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }
}
