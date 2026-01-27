import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../providers/pos_provider.dart';
import '../providers/pos_state.dart';
import './table_selection_dialog.dart';

class PosHeader extends ConsumerStatefulWidget {
  const PosHeader({super.key});

  @override
  ConsumerState<PosHeader> createState() => _PosHeaderState();
}

class _PosHeaderState extends ConsumerState<PosHeader> {
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
          InkWell(
            onTap: () {
              context.go(RouteConstants.staffHome);
            },
            child: Row(
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
                        fontSize: isDesktop ? 13.sp : 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    if (isDesktop || isTablet)
                      Text(
                        'Branch: Downtown',
                        style: TextStyle(
                          fontSize: isDesktop ? 9.sp : 10.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),
          const VerticalDivider(width: 1, indent: 20, endIndent: 20),
          const SizedBox(width: 24),

          // Menu Switcher
          _buildMenuSwitcher(ref),

          const Spacer(),

          // Order Type Selector
          if (isDesktop || isTablet) _buildOrderTypeSelector(ref),

          SizedBox(width: 2.w),

          // Table Selector (Only for Dine-In)
          _buildTableSelector(context, ref),

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
                      fontSize: isDesktop ? 11.sp : 12.sp,
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
              // if (isDesktop) SizedBox(width: 0.6.w),
              // if (isDesktop)
              //   Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'John Doe',
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 11.sp,
              //           height: 1.1,
              //         ),
              //       ),
              //       Row(
              //         children: [
              //           Container(
              //             width: 4,
              //             height: 4,
              //             decoration: const BoxDecoration(
              //               color: AppColors.success,
              //               shape: BoxShape.circle,
              //             ),
              //           ),
              //           const SizedBox(width: 4),
              //           Text(
              //             'Shift Active',
              //             style: TextStyle(
              //               fontSize: 9.sp,
              //               color: AppColors.textSecondary,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
            ],
          ),

          SizedBox(width: 0.8.w),

          // Settings Icon
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(
          //     Icons.settings_outlined,
          //     color: AppColors.textSecondary,
          //     size: isDesktop ? 1.4.w : 22,
          //   ),
          //   padding: EdgeInsets.zero,
          //   constraints: const BoxConstraints(),
          //   style: IconButton.styleFrom(
          //     backgroundColor: AppColors.grey100,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildMenuSwitcher(WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final selectedMenu = state.selectedMenu;
    final menus = state.availableMenus;

    if (menus.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<MenuEntity>(
      initialValue: selectedMenu,
      onSelected: (menu) {
        ref.read(posNotifierProvider.notifier).selectMenu(menu);
      },
      itemBuilder: (context) => menus.map((menu) {
        return PopupMenuItem<MenuEntity>(
          value: menu,
          child: Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 18,
                color: selectedMenu?.id == menu.id
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                menu.name,
                style: TextStyle(
                  fontWeight: selectedMenu?.id == menu.id
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACTIVE MENU',
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  selectedMenu?.name ?? 'Select Menu',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeSelector(WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    return SegmentedButton<OrderType>(
      segments: const [
        ButtonSegment(
          value: OrderType.dineIn,
          label: Text('Dine-In'),
          icon: Icon(Icons.restaurant),
        ),
        ButtonSegment(
          value: OrderType.takeaway,
          label: Text('Takeaway'),
          icon: Icon(Icons.takeout_dining),
        ),
        ButtonSegment(
          value: OrderType.delivery,
          label: Text('Delivery'),
          icon: Icon(Icons.delivery_dining),
        ),
      ],
      selected: {state.orderType},
      onSelectionChanged: (newSelection) {
        ref.read(posNotifierProvider.notifier).setOrderType(newSelection.first);
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: AppColors.grey100,
        selectedBackgroundColor: AppColors.primary,
        selectedForegroundColor: AppColors.white,
        visualDensity: VisualDensity.compact,
        side: BorderSide(color: AppColors.border),
      ),
    );
  }

  Widget _buildTableSelector(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final isDineIn = state.orderType == OrderType.dineIn;

    if (!isDineIn) return const SizedBox.shrink();

    final bool isDesktop = Device.width > 900;

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const TableSelectionDialog(),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: state.tableNumber != null
              ? AppColors.primaryContainer
              : AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: state.tableNumber != null
                ? AppColors.primary
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.table_restaurant,
              size: isDesktop ? 1.2.w : 18,
              color: state.tableNumber != null
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            SizedBox(width: 0.5.w),
            Text(
              state.tableNumber != null
                  ? 'Table: ${state.tableNumber}'
                  : 'Select Table',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 10.5.sp : 11.sp,
                color: state.tableNumber != null
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
            if (state.ongoingOrderId != null) ...[
              SizedBox(width: 0.5.w),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
