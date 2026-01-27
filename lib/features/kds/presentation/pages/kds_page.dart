import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
    final bool isDesktop = Device.width > 900;
    final stations = config.stations.keys.toList();

    if (stations.isEmpty) {
      return Center(
        child: Text(
          'No stations configured.',
          style: TextStyle(fontSize: 16.sp),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isDesktop ? 60.w : 600),
        padding: EdgeInsets.all(isDesktop ? 2.w : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Station',
              style: TextStyle(
                fontSize: isDesktop ? 20.sp : 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Wrap(
              spacing: isDesktop ? 1.5.w : 16,
              runSpacing: isDesktop ? 1.5.w : 16,
              alignment: WrapAlignment.center,
              children: stations.map((station) {
                return InkWell(
                  onTap: () {
                    ref.read(selectedStationProvider.notifier).state = station;
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: isDesktop ? 12.w : 200,
                    height: isDesktop ? 10.w : 150,
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
                        Icon(
                          Icons.kitchen,
                          size: isDesktop ? 3.w : 48.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 1.5.h),
                        Text(
                          station,
                          style: TextStyle(
                            fontSize: isDesktop ? 13.sp : 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        Text(
                          '${config.stations[station]?.length ?? 0} Categories',
                          style: TextStyle(
                            fontSize: isDesktop ? 11.sp : 14.sp,
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
    final bool isDesktop = Device.width > 900;

    return Container(
      width: isDesktop ? 22.w : 320,
      margin: EdgeInsets.only(right: isDesktop ? 1.w : 16),
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
            padding: EdgeInsets.all(isDesktop ? 1.w : 16),
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
                    fontSize: isDesktop ? 14.sp : 16.sp,
                    color: _getStatusColor(stage),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.8.w,
                    vertical: 0.4.h,
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
                      fontSize: isDesktop ? 12.sp : 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(isDesktop ? 0.8.w : 12),
              itemCount: orders.length,
              separatorBuilder: (ctx, i) =>
                  SizedBox(height: isDesktop ? 0.8.h : 12),
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
    final bool isDesktop = Device.width > 900;
    final timeElapsed = DateTime.now().difference(order.createdAt).inMinutes;

    // ... (logic remains same)

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
        padding: EdgeInsets.all(isDesktop ? 0.8.w : 12),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 13.sp : 16.sp,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.6.w,
                    vertical: 0.2.h,
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
                      fontSize: isDesktop ? 10.sp : 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.8.h),
            const Divider(height: 1),
            SizedBox(height: 0.8.h),
            ...stationItems.map(
              (item) =>
                  _buildItemRow(context, ref, item, order.specialInstructions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(
    BuildContext context,
    WidgetRef ref,
    KdsOrderItem item,
    String? specialInstructions,
  ) {
    final bool isDesktop = Device.width > 900;
    final isCurrentStage = item.status == currentStage;

    return Opacity(
      opacity: isCurrentStage ? 1.0 : 0.5,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isDesktop ? 1.5.w : 24,
                  height: isDesktop ? 1.5.w : 24,
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
                      fontSize: isDesktop ? 11.sp : 13.sp,
                    ),
                  ),
                ),
                SizedBox(width: 0.8.w),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: isDesktop ? 12.sp : 14.sp,
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

            // if (item.s.isNotEmpty)
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
            //note
            if (item.specialInstructions?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 4),
                child: Text(
                  item.specialInstructions ?? '123',
                  style: TextStyle(
                    fontSize: isDesktop ? 12.sp : 14.sp,

                    // Maybe strikethrough if done?
                  ),
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
