import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../core/models/user.dart';
import '../../../../shared/theme/app_colors.dart';

class UserHeaderCard extends StatelessWidget {
  final User? user;
  final VoidCallback onLogout;

  const UserHeaderCard({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Device.width > 900;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 1.5.w : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 4.w : 60,
            height: isDesktop ? 4.w : 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.person,
              color: AppColors.white,
              size: isDesktop ? 2.w : 30,
            ),
          ),
          SizedBox(width: isDesktop ? 1.w : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back,',
                  style: TextStyle(
                    fontSize: isDesktop ? 12.sp : 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  user?.name ?? 'User',
                  style: TextStyle(
                    fontSize: isDesktop ? 15.sp : 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onLogout,
            icon: Icon(Icons.logout, size: isDesktop ? 1.8.w : 28),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
