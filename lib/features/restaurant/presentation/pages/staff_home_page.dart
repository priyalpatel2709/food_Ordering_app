import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
        title: 'Dine In Tables',
        icon: Icons.table_bar_outlined,
        color: const Color.fromARGB(255, 222, 241, 99),
        route: RouteConstants.dineInTables,
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
        title: 'Tables',
        icon: Icons.table_bar_rounded,
        color: const Color(0xFF14B8A6),
        route: RouteConstants.tableManagement,
        permission: PermissionConstants.kdsView,
        description: 'Manage dining area & layout',
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
        title: 'Menu Management',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFF97316),
        route: RouteConstants.menuManagement,
        permission: PermissionConstants.menuRead,
        description: 'Manage active menus & schedules',
      ),
      _DashboardItem(
        title: 'Item Management',
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFFEC4899),
        route: RouteConstants.itemsManagement,
        permission: PermissionConstants.itemRead,
        description: 'Item control',
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
        title: 'Customizations',
        icon: Icons.tune_rounded,
        color: const Color(0xFF6366F1),
        route: RouteConstants.customizationManagement,
        permission: PermissionConstants.customizationRead,
        description: 'Manage add-ons & extras',
      ),
      _DashboardItem(
        title: 'Taxes',
        icon: Icons.account_balance_rounded,
        color: const Color(0xFF14B8A6),
        route: RouteConstants.taxesManagement,
        permission: PermissionConstants.taxRead,
        description: 'Configure tax rates & rules',
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
        title: 'Users & Staff',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF475569),
        route: RouteConstants.userManagement,
        permission: PermissionConstants.userRead,
        description: 'Team member accounts',
      ),
      _DashboardItem(
        title: 'Roles & Access',
        icon: Icons.admin_panel_settings_rounded,
        color: const Color(0xFF0F172A),
        route: RouteConstants.roleManagement,
        permission: PermissionConstants.roleRead,
        description: 'RBAC & security permissions',
      ),
      _DashboardItem(
        title: 'Loyalty Members',
        icon: Icons.star_rounded,
        color: const Color(0xFFF59E0B),
        route: RouteConstants.loyaltyManagement,
        permission: PermissionConstants.roleRead,
        description: 'Customer profiles & points',
      ),
      _DashboardItem(
        title: 'Settings',
        icon: Icons.settings_suggest_rounded,
        color: const Color(0xFF64748B),
        route: RouteConstants.restaurantSettings,
        permission: PermissionConstants.restaurantRead,
        description: 'Store profile & configurations',
      ),
      _DashboardItem(
        title: 'App Settings',
        icon: Icons.settings_suggest_rounded,
        color: const Color(0xFF64748B),
        route: RouteConstants.settings,
        permission: PermissionConstants.restaurantRead,
        description: 'App profile & configurations',
      ),
    ];

    final filteredItems = allItems.where((item) {
      if (authState is AuthAuthenticated) {
        return authState.user.hasPermission(item.permission);
      }
      return false;
    }).toList();

    // Responsive grid column count and ratio
    final bool isDesktop = Device.width > 900;
    final bool isTablet = Device.width > 600 && Device.width <= 900;

    final int crossAxisCount = isDesktop ? 5 : (isTablet ? 3 : 2);
    final double childAspectRatio = isDesktop ? 1.2 : 1.1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildGreeting(user?.name ?? 'Admin'),
                        const SizedBox(height: 24),
                        const Text(
                          'Business Management',
                          style: TextStyle(
                            fontSize: 22,
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
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 24 : 20,
                    0,
                    isDesktop ? 24 : 20,
                    40,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: isDesktop ? 16 : 12,
                      mainAxisSpacing: isDesktop ? 16 : 12,
                      childAspectRatio: childAspectRatio,
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
    final bool isDesktop = Device.width > 900;
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 20,
        vertical: 16,
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 8 : 10),
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
              // child: Image.asset(
              //   'assets/images/logo.png',
              //   height: isDesktop ? 32 : 28,
              //   errorBuilder: (context, error, stackTrace) => Icon(
              //     Icons.restaurant_rounded,
              //     color: AppColors.primary,
              //     size: isDesktop ? 24 : 24,
              //   ),
              // ),
            ),
            Row(
              children: [
                _buildAppBarAction(
                  icon: Icons.notifications_none_rounded,
                  onTap: () {},
                ),
                SizedBox(width: isDesktop ? 8 : 8),
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
    final bool isDesktop = Device.width > 900;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 8 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Icon(icon, size: isDesktop ? 20 : 24, color: color),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, StorageService storage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout', style: TextStyle(fontSize: 20)),
        content: const Text(
          'Are you sure you want to exit?',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 15)),
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
            child: const Text('Logout', style: TextStyle(fontSize: 15)),
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
    final bool isDesktop = Device.width > 900;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(item.route),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 12 : 12),
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
                padding: EdgeInsets.all(isDesktop ? 10 : 10),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: isDesktop ? 24 : 28,
                ),
              ),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF64748B).withOpacity(0.8),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
