import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../features/authentication/presentation/providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../menu/presentation/widgets/user_header_card.dart';

class _DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final String permission;

  _DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    required this.permission,
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
        title: 'Tables & Orders',
        icon: Icons.table_restaurant,
        color: AppColors.primary,
        route: RouteConstants.dineInTables,
        permission: PermissionConstants.orderCreate,
      ),
      _DashboardItem(
        title: 'All Orders (History)',
        icon: Icons.history,
        color: Colors.brown,
        route: RouteConstants.staffOrders,
        permission: PermissionConstants.orderRead,
      ),
      _DashboardItem(
        title: 'Kitchen (KDS)',
        icon: Icons.restaurant,
        color: AppColors.secondary,
        route: RouteConstants.kds,
        permission: PermissionConstants.kdsView,
      ),
      _DashboardItem(
        title: 'Menu Management',
        icon: Icons.menu_book,
        color: AppColors.accent,
        route: RouteConstants.menuManagement,
        permission: PermissionConstants.menuRead,
      ),
      _DashboardItem(
        title: 'Reports',
        icon: Icons.bar_chart,
        color: Colors.blue,
        route: RouteConstants.reports,
        permission: PermissionConstants.reportRead,
      ),
      _DashboardItem(
        title: 'Items',
        icon: Icons.fastfood,
        color: Colors.orange,
        route: RouteConstants.itemsManagement,
        permission: PermissionConstants.itemRead,
      ),
      _DashboardItem(
        title: 'Categories',
        icon: Icons.category,
        color: Colors.teal,
        route: RouteConstants.categoriesManagement,
        permission: PermissionConstants.categoryRead,
      ),
      _DashboardItem(
        title: 'Customizations',
        icon: Icons.tune,
        color: Colors.purple,
        route: RouteConstants.customizationManagement,
        permission: PermissionConstants.customizationRead,
      ),
      _DashboardItem(
        title: 'Discounts',
        icon: Icons.local_offer,
        color: Colors.redAccent,
        route: RouteConstants.discountsManagement,
        permission: PermissionConstants.discountRead,
      ),
      _DashboardItem(
        title: 'Taxes',
        icon: Icons.receipt_long,
        color: Colors.green,
        route: RouteConstants.taxesManagement,
        permission: PermissionConstants.taxRead,
      ),
      _DashboardItem(
        title: 'Settings',
        icon: Icons.store,
        color: Colors.blueGrey,
        route: RouteConstants.restaurantSettings,
        permission: PermissionConstants.restaurantRead,
      ),
      _DashboardItem(
        title: 'Staff & Roles',
        icon: Icons.admin_panel_settings,
        color: Colors.indigo,
        route: RouteConstants.userManagement,
        permission: PermissionConstants.userRead,
      ),
      _DashboardItem(
        title: 'Role Mgmt',
        icon: Icons.security,
        color: Colors.deepPurple,
        route: RouteConstants.roleManagement,
        permission: PermissionConstants.roleRead,
      ),
      _DashboardItem(
        title: 'Permission',
        icon: Icons.security,
        color: Colors.deepPurple,
        route: RouteConstants.permissionManagement,
        permission: PermissionConstants.roleRead,
      ),
    ];

    final filteredItems = allItems.where((item) {
      if (authState is AuthAuthenticated) {
        return authState.user.hasPermission(item.permission);
      }
      return false;
    }).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.grey50,
              AppColors.white,
              AppColors.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              UserHeaderCard(
                user: user,
                onLogout: () async {
                  await storageService.clearUser();
                  if (context.mounted) {
                    context.go(RouteConstants.login);
                  }
                },
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'Staff Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _DashboardCard(
                      title: item.title,
                      icon: item.icon,
                      color: item.color,
                      onTap: () => context.push(item.route),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
