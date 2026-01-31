import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../features/rbac/presentation/widgets/permission_guard.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../domain/entities/menu_entity.dart';
import '../viewmodels/menu_view_model.dart';

class MenuManagementPage extends ConsumerStatefulWidget {
  const MenuManagementPage({super.key});

  @override
  ConsumerState<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends ConsumerState<MenuManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(menuNotifierProvider.notifier).loadMenus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(menuNotifierProvider.notifier).loadMenus(search: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search menus...',
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 22,
                    color: Colors.black87,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: switch (menuState) {
                MenuInitial() || MenuLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                MenuError(:final message) => Center(
                  child: Text(
                    'Error: $message',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                MenuLoaded(:final menus) => _buildMenuList(menus),
              },
            ),
          ],
        ),
      ),
      floatingActionButton: PermissionGuard(
        permission: PermissionConstants.menuCreate,
        child: FloatingActionButton(
          onPressed: () => context.push(RouteConstants.addMenu),
          backgroundColor: const Color(0xFFFF7043),
          elevation: 3,
          mini: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMenuList(List<MenuEntity> menus) {
    if (menus.isEmpty) {
      return const Center(
        child: Text('No menus found.', style: TextStyle(fontSize: 15)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: crossAxisCount > 1 ? 2.0 : 2.0,
          ),
          itemCount: menus.length,
          itemBuilder: (context, index) => _buildMenuCard(menus[index]),
        );
      },
    );
  }

  Widget _buildMenuCard(MenuEntity menu) {
    final isActiveNow = _isMenuCurrent(menu);

    // Get time range for today if available
    String timeRange = '';
    try {
      final days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final currentDay = DateTime.now().weekday - 1; // 0-indexed for list
      if (currentDay >= 0 && currentDay < days.length) {
        final dayName = days[currentDay];
        final dayConfig = menu.availableDays.firstWhere(
          (d) => d.day == dayName,
        );
        if (dayConfig.timeSlots.isNotEmpty) {
          final slot = dayConfig.timeSlots.first;
          timeRange = 'Available from ${slot.openTime} - ${slot.closeTime}';
        } else {
          timeRange = 'No time slots today';
        }
      } else {
        timeRange = 'Invalid day';
      }
    } catch (_) {
      timeRange = 'Not available today';
    }

    return GestureDetector(
      onTap: () => context.push(RouteConstants.addMenu, extra: menu),
      child: Container(
        decoration: BoxDecoration(
          color: isActiveNow
              ? const Color(0xFFF8FAF8)
              : const Color(0xFFFFF7F6),
          borderRadius: BorderRadius.circular(15),
          border: isActiveNow
              ? Border.all(color: const Color(0xFF4CAF50), width: 1.5)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Menu Book Icon at bottom left
            Positioned(
              left: -4,
              bottom: 8,
              child: Opacity(
                opacity: 0.3,
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: isActiveNow
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Content
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(flex: 3),
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                menu.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (isActiveNow)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Text(
                                timeRange,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                menu.isActive ? 'Enabled' : 'Disabled',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: menu.isActive
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Delete Button
                  PermissionGuard(
                    permission: PermissionConstants.menuDelete,
                    child: GestureDetector(
                      onTap: () {
                        // Stop propagation of tap
                        _confirmDelete(menu.id);
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Color(0xFFEF4444),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
