import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/menu_entity.dart';
import '../viewmodels/menu_view_model.dart';

class MenuManagementPage extends ConsumerStatefulWidget {
  const MenuManagementPage({super.key});

  @override
  ConsumerState<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends ConsumerState<MenuManagementPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(menuNotifierProvider.notifier).loadMenus());
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: switch (menuState) {
        MenuInitial() ||
        MenuLoading() => const Center(child: CircularProgressIndicator()),
        MenuError(:final message) => Center(child: Text('Error: $message')),
        MenuLoaded(:final menus) => _buildMenuList(menus),
      },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteConstants.addMenu),
        label: const Text('Add Menu'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildMenuList(List<MenuEntity> menus) {
    if (menus.isEmpty) {
      return const Center(child: Text('No menus found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        final isActiveNow = _isMenuCurrent(menu);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isActiveNow
                ? const BorderSide(color: Colors.green, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isActiveNow
                  ? Colors.green.shade100
                  : Colors.grey.shade100,
              child: Icon(
                Icons.menu_book,
                color: isActiveNow ? Colors.green : Colors.grey,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    menu.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (isActiveNow)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  menu.isActive ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: menu.isActive ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(menu.id),
            ),
            onTap: () => context.push(RouteConstants.addMenu, extra: menu),
          ),
        );
      },
    );
  }

  bool _isMenuCurrent(MenuEntity menu) {
    if (!menu.isActive) return false;

    final now = DateTime.now();
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final currentDay = days[now.weekday - 1];

    // Check if available today
    // Note: availableDays might be null if not populated correctly in some legacy data, but Entity says required non-nullable.
    // However, the list might be empty.

    try {
      final availability = menu.availableDays.firstWhere(
        (a) => a.day == currentDay,
      );

      // Check time slots
      for (final slot in availability.timeSlots) {
        if (_isTimeInRange(slot.openTime, slot.closeTime, now)) {
          return true;
        }
      }
    } catch (e) {
      // firstWhere throws StateError if not found
      return false;
    }

    return false;
  }

  bool _isTimeInRange(String start, String end, DateTime now) {
    try {
      final currentTime = now.hour * 60 + now.minute;

      final startParts = start.split(':');
      final startMinutes =
          int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

      final endParts = end.split(':');
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      // Handle overnight? Assuming strict daily slots for now based on schema comments (e.g. 08:00 - 12:00)
      return currentTime >= startMinutes && currentTime <= endMinutes;
    } catch (e) {
      return false;
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu'),
        content: const Text('Are you sure you want to delete this menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(menuNotifierProvider.notifier)
                  .deleteMenu(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Menu deleted successfully'
                          : 'Failed to delete menu',
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
