import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../features/authentication/presentation/providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';

class _DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final String permission;
  final String description;

  _DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    required this.permission,
    required this.description,
  });
}

class StaffHomePage extends ConsumerWidget {
  const StaffHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageService = StorageService();
    final user = storageService.getUser();
    final authState = ref.watch(authNotifierProvider);

    final List<_DashboardItem> allItems = [
      _DashboardItem(
        title: 'POS Terminal',
        icon: Icons.point_of_sale_rounded,
        color: const Color(0xFF6366F1),
        route: RouteConstants.pos,
        permission: PermissionConstants.orderCreate,
        description: 'New billing & fast checkout',
      ),
      _DashboardItem(
        title: 'Orders',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF10B981),
        route: RouteConstants.staffOrders,
        permission: PermissionConstants.orderRead,
        description: 'Manage & track live orders',
      ),
      _DashboardItem(
        title: 'Kitchen (KDS)',
        icon: Icons.restaurant_menu_rounded,
        color: const Color(0xFFF59E0B),
        route: RouteConstants.kds,
        permission: PermissionConstants.kdsView,
        description: 'Monitor kitchen preparations',
      ),
      _DashboardItem(
        title: 'Inventory',
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFFEC4899),
        route: RouteConstants.itemsManagement,
        permission: PermissionConstants.itemRead,
        description: 'Stock & menu item control',
      ),
      _DashboardItem(
        title: 'Categories',
        icon: Icons.category_rounded,
        color: const Color(0xFF8B5CF6),
        route: RouteConstants.categoriesManagement,
        permission: PermissionConstants.categoryRead,
        description: 'Organize your menu structure',
      ),
      _DashboardItem(
        title: 'Reports',
        icon: Icons.analytics_rounded,
        color: const Color(0xFF3B82F6),
        route: RouteConstants.reports,
        permission: PermissionConstants.reportRead,
        description: 'Sales & performance analytics',
      ),
      _DashboardItem(
        title: 'Discounts',
        icon: Icons.confirmation_number_rounded,
        color: const Color(0xFFEF4444),
        route: RouteConstants.discountsManagement,
        permission: PermissionConstants.discountRead,
        description: 'Promo codes & special offers',
      ),
      _DashboardItem(
        title: 'Staff & Roles',
        icon: Icons.admin_panel_settings_rounded,
        color: const Color(0xFF0F172A),
        route: RouteConstants.userManagement,
        permission: PermissionConstants.userRead,
        description: 'Team management & security',
      ),
      _DashboardItem(
        title: 'Settings',
        icon: Icons.settings_suggest_rounded,
        color: const Color(0xFF64748B),
        route: RouteConstants.restaurantSettings,
        permission: PermissionConstants.restaurantRead,
        description: 'Store profile & configurations',
      ),
    ];

    final filteredItems = allItems.where((item) {
      if (authState is AuthAuthenticated) {
        return authState.user.hasPermission(item.permission);
      }
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, user, storageService),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildGreeting(user?.name ?? 'Admin'),
                        const SizedBox(height: 24),
                        _buildQuickStats(context),
                        const SizedBox(height: 32),
                        const Text(
                          'Business Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = filteredItems[index];
                      return _ManagementCard(item: item);
                    }, childCount: filteredItems.length),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    dynamic user,
    StorageService storage,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png', // Fallback to icon if asset missing
                height: 32,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
            Row(
              children: [
                _buildAppBarAction(
                  icon: Icons.notifications_none_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _buildAppBarAction(
                  icon: Icons.logout_rounded,
                  onTap: () => _showLogoutDialog(context, storage),
                  color: const Color(0xFFEF4444),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFF64748B),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Icon(icon, size: 24, color: color),
      ),
    );
  }

  Widget _buildGreeting(String name) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Welcome back, $name!',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            'Today\'s Sales',
            '\$420.50',
            Icons.trending_up,
            Colors.greenAccent,
          ),
          Container(height: 40, width: 1, color: Colors.white24),
          _buildStatItem('Orders', '24', Icons.receipt_long, Colors.blueAccent),
          Container(height: 40, width: 1, color: Colors.white24),
          _buildStatItem('Active', '6', Icons.timelapse, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, StorageService storage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await storage.clearUser();
              if (context.mounted) {
                context.go(RouteConstants.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final _DashboardItem item;

  const _ManagementCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(item.route),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64748B).withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: item.color, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF64748B).withOpacity(0.8),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
