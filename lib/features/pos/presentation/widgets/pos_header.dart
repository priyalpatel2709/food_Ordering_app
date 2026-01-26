import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';

class PosHeader extends StatefulWidget {
  const PosHeader({super.key});

  @override
  State<PosHeader> createState() => _PosHeaderState();
}

class _PosHeaderState extends State<PosHeader> {
  late DateTime _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Device.width > 900;
    final bool isTablet = Device.width > 600 && Device.width <= 900;

    return Container(
      height: isDesktop ? 10.h : (isTablet ? 9.h : 70),
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Store Name & Logo
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 0.6.w : 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: AppColors.white,
                  size: isDesktop ? 1.4.w : 22,
                ),
              ),
              SizedBox(width: 1.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POS',
                    style: TextStyle(
                      fontSize: isDesktop ? 15.sp : 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  if (isDesktop || isTablet)
                    Text(
                      'Branch: Downtown Terminal 1',
                      style: TextStyle(
                        fontSize: isDesktop ? 11.sp : 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Date & Time
          if (isDesktop || isTablet)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: isDesktop ? 1.1.w : 14,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 0.5.w),
                  Text(
                    DateFormat(
                      isDesktop
                          ? 'EEE, MMM d, yyyy  •  hh:mm:ss a'
                          : 'hh:mm:ss a',
                    ).format(_currentTime),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isDesktop ? 13.sp : 13.sp,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(width: 1.5.w),

          // Cashier Info
          Row(
            children: [
              CircleAvatar(
                radius: isDesktop ? 1.1.w : 16,
                backgroundColor: AppColors.secondaryContainer,
                child: Icon(
                  Icons.person,
                  color: AppColors.secondary,
                  size: isDesktop ? 1.4.w : 18,
                ),
              ),
              if (isDesktop) SizedBox(width: 0.6.w),
              if (isDesktop)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        height: 1.1,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Shift Active',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),

          SizedBox(width: 0.8.w),

          // Settings Icon
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
              size: isDesktop ? 1.4.w : 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.grey100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
