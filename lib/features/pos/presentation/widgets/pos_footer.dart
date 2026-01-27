import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/pos_provider.dart';
import '../providers/pos_state.dart';

import '../widgets/table_selection_dialog.dart';
import '../widgets/held_orders_dialog.dart';

class PosFooter extends ConsumerWidget {
  const PosFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final bool isDesktop = Device.width > 1000;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Order Type Selector
          _FooterActionButton(
            label: state.orderType.name.toUpperCase(),
            icon: _getOrderTypeIcon(state.orderType),
            color: AppColors.primary,
            onTap: () => _showOrderTypeDialog(context, ref, state),
          ),
          const SizedBox(width: 12),

          if (state.orderType == OrderType.dineIn) ...[
            _FooterActionButton(
              label: 'TABLES',
              icon: Icons.table_restaurant_outlined,
              color: AppColors.primary,
              onTap: () => showDialog(
                context: context,
                builder: (context) => const TableSelectionDialog(),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Action Buttons
          _FooterActionButton(
            label: 'HOLD',
            icon: Icons.pause_circle_outline,
            color: Colors.orange,
            onTap: () {
              if (state.cartItems.isNotEmpty) {
                ref.read(posNotifierProvider.notifier).holdCurrentOrder();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order held successfully'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 12),

          Stack(
            children: [
              _FooterActionButton(
                label: 'OPEN ORDERS',
                icon: Icons.receipt_long_outlined,
                color: AppColors.secondary,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => const HeldOrdersDialog(),
                ),
              ),
              if (state.heldOrders.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${state.heldOrders.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          _FooterActionButton(
            label: 'CLEAR',
            icon: Icons.delete_sweep_outlined,
            color: AppColors.error,
            onTap: () => ref.read(posNotifierProvider.notifier).clearCart(),
          ),

          const Spacer(),

          // Current Cashier Info (Desktop only)
          if (isDesktop)
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.grey100,
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cashier: Admin',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                    Text(
                      'ID: #1002',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  IconData _getOrderTypeIcon(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return Icons.restaurant;
      case OrderType.takeaway:
        return Icons.local_mall;
      case OrderType.delivery:
        return Icons.delivery_dining;
    }
  }

  void _showOrderTypeDialog(
    BuildContext context,
    WidgetRef ref,
    PosState state,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Order Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderType.values.map((type) {
            final isSelected = state.orderType == type;
            return ListTile(
              leading: Icon(
                _getOrderTypeIcon(type),
                color: isSelected ? AppColors.primary : null,
              ),
              title: Text(type.name.toUpperCase()),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(posNotifierProvider.notifier).setOrderType(type);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FooterActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FooterActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
