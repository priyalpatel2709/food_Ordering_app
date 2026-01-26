import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../providers/dine_in_providers.dart';
import '../widgets/table_card.dart';

class DineInTablesPage extends ConsumerWidget {
  const DineInTablesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tablesProvider);
    final bool isDesktop = Device.width > 900;
    final bool isTablet = Device.width > 600 && Device.width <= 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dine-In Tables',
          style: TextStyle(
            fontSize: isDesktop ? 14.sp : 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: tablesAsync.when(
        data: (tables) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(tablesProvider.future),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 2.w : 4.w,
                    vertical: 1.h,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: isDesktop ? 1.w : 14.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Total Tables: ${tables.length}',
                        style: TextStyle(
                          fontSize: isDesktop ? 11.sp : 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 2.w : 3.w,
                      vertical: 1.h,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 8 : (isTablet ? 5 : 3),
                      childAspectRatio: 0.85,
                      crossAxisSpacing: isDesktop ? 1.w : 2.w,
                      mainAxisSpacing: isDesktop ? 1.w : 2.w,
                    ),
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      return TableCard(table: tables[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
        error: (err, stack) => Center(
          child: Text('Error: $err', style: TextStyle(fontSize: 14.sp)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
