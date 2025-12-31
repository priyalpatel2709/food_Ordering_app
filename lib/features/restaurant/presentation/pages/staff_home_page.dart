import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../menu/presentation/widgets/user_header_card.dart';

class StaffHomePage extends StatelessWidget {
  const StaffHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    final user = storageService.getUser();

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
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(24),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _DashboardCard(
                      title: 'Tables & Orders',
                      icon: Icons.table_restaurant,
                      color: AppColors.primary,
                      onTap: () => context.push(RouteConstants.dineInTables),
                    ),
                    _DashboardCard(
                      title: 'Kitchen (KDS)',
                      icon: Icons.restaurant,
                      color: AppColors.secondary,
                      onTap: () => context.push(RouteConstants.kds),
                    ),
                    _DashboardCard(
                      title: 'Menu Management',
                      icon: Icons.menu_book,
                      color: AppColors.accent,
                      onTap: () => context.push(RouteConstants.menuManagement),
                    ),
                    _DashboardCard(
                      title: 'Reports',
                      icon: Icons.bar_chart,
                      color: Colors.blue,
                      onTap: () => context.push(RouteConstants.reports),
                    ),
                    _DashboardCard(
                      title: 'Items',
                      icon: Icons.fastfood,
                      color: Colors.orange,
                      onTap: () => context.push(RouteConstants.itemsManagement),
                    ),
                    _DashboardCard(
                      title: 'Categories',
                      icon: Icons.category,
                      color: Colors.teal,
                      onTap: () =>
                          context.push(RouteConstants.categoriesManagement),
                    ),
                    _DashboardCard(
                      title: 'Customizations',
                      icon: Icons.tune,
                      color: Colors.purple,
                      onTap: () =>
                          context.push(RouteConstants.customizationManagement),
                    ),
                    _DashboardCard(
                      title: 'Discounts',
                      icon: Icons.local_offer,
                      color: Colors.redAccent,
                      onTap: () =>
                          context.push(RouteConstants.discountsManagement),
                    ),
                    _DashboardCard(
                      title: 'Taxes',
                      icon: Icons.receipt_long,
                      color: Colors.green,
                      onTap: () => context.push(RouteConstants.taxesManagement),
                    ),
                    _DashboardCard(
                      title: 'Settings',
                      icon: Icons.store,
                      color: Colors.blueGrey,
                      onTap: () =>
                          context.push(RouteConstants.restaurantSettings),
                    ),
                  ],
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
