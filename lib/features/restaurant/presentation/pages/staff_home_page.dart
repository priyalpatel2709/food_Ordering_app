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
            top: -10.h,
            right: -10.h,
            child: Container(
              width: 30.h,
              height: 30.h,
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
                      horizontal: isDesktop ? 3.w : 5.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2.h),
                        _buildGreeting(user?.name ?? 'Admin'),
                        SizedBox(height: 3.h),
                        Text(
                          'Business Management',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 3.w : 5.w,
                    0,
                    isDesktop ? 3.w : 5.w,
                    5.h,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: isDesktop ? 1.5.w : 3.w,
                      mainAxisSpacing: isDesktop ? 1.5.w : 3.w,
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
        horizontal: isDesktop ? 3.w : 5.w,
        vertical: 2.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 0.8.w : 2.w),
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
                'assets/images/logo.png',
                height: isDesktop ? 4.h : 3.5.h,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.primary,
                  size: isDesktop ? 2.5.w : 5.w,
                ),
              ),
            ),
            Row(
              children: [
                _buildAppBarAction(
                  icon: Icons.notifications_none_rounded,
                  onTap: () {},
                ),
                SizedBox(width: isDesktop ? 1.w : 2.w),
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
        padding: EdgeInsets.all(isDesktop ? 0.8.w : 2.5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Icon(icon, size: isDesktop ? 1.5.w : 5.w, color: color),
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
          style: TextStyle(
            fontSize: 15.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Welcome back, $name!',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, StorageService storage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: TextStyle(fontSize: 18.sp)),
        content: Text(
          'Are you sure you want to exit?',
          style: TextStyle(fontSize: 16.sp),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 15.sp)),
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
            child: Text('Logout', style: TextStyle(fontSize: 15.sp)),
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
          padding: EdgeInsets.all(isDesktop ? 1.2.w : 3.w),
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
                padding: EdgeInsets.all(isDesktop ? 0.8.w : 2.5.w),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: isDesktop ? 1.8.w : 6.w,
                ),
              ),
              const Spacer(),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 13.sp,
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
