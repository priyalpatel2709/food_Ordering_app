import 'package:flutter/material.dart';
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
    return GestureDetector(
      onTap: () {
        // Pass the table object as extra, but also use ID in path
        context.push('/dine-in/table/${table.tableNumber}', extra: table);
      },
      child: Card(
        color: _statusColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _statusColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Table ${table.tableNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              table.status.name.replaceAll('_', ' '),
              style: TextStyle(
                color: _statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (table.capacity > 0) ...[
              const SizedBox(height: 4),
              Text('Capacity: ${table.capacity}'),
            ],
          ],
        ),
      ),
    );
  }
}
