import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/table_entity.dart';

class TableCard extends StatelessWidget {
  final TableEntity table;

  const TableCard({super.key, required this.table});

  Color get _statusColor {
    switch (table.status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.ongoing:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Device.width > 900;

    return GestureDetector(
      onTap: () {
        // Pass the table object as extra, but also use ID in path
        context.push('/dine-in/table/${table.tableNumber}', extra: table);
      },
      child: Card(
        color: _statusColor.withOpacity(0.05),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _statusColor.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 0.4.w : 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_restaurant_outlined,
                size: isDesktop ? 1.5.w : 22.sp,
                color: _statusColor,
              ),
              SizedBox(height: 0.5.h),
              Text(
                'T-${table.tableNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 12.sp : 14.sp,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 0.2.h),
              Text(
                table.status.name.toUpperCase(),
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 9.sp : 11.sp,
                  letterSpacing: 0.5,
                ),
              ),
              if (table.capacity > 0) ...[
                SizedBox(height: 0.4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: isDesktop ? 0.8.w : 12.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${table.capacity}',
                      style: TextStyle(
                        fontSize: isDesktop ? 9.sp : 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
