import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../features/rbac/presentation/widgets/permission_guard.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../domain/entities/table_entity.dart';
import '../providers/table_management_provider.dart';

class TableManagementPage extends ConsumerStatefulWidget {
  const TableManagementPage({super.key});

  @override
  ConsumerState<TableManagementPage> createState() =>
      _TableManagementPageState();
}

class _TableManagementPageState extends ConsumerState<TableManagementPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tableManagementProvider);
    final bool isDesktop = Device.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Table Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 15.sp : 18.sp,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(tableManagementProvider.notifier).loadTables(),
            icon: const Icon(Icons.refresh),
          ),
          SizedBox(width: 1.w),
        ],
      ),
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
        child: state.isLoading && state.tables.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 10.w,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 2.h),
                    Text(state.error!, style: TextStyle(fontSize: 14.sp)),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(tableManagementProvider.notifier)
                          .loadTables(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _buildTableGrid(state.tables, isDesktop),
      ),
      floatingActionButton: PermissionGuard(
        permission: PermissionConstants.tableCreate,
        child: FloatingActionButton.extended(
          onPressed: () => _showAddEditTableDialog(context, ref),
          label: const Text('Add Table'),
          icon: const Icon(Icons.add),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTableGrid(List<TableEntity> tables, bool isDesktop) {
    return GridView.builder(
      padding: EdgeInsets.all(isDesktop ? 2.w : 4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: isDesktop ? 1.5.w : 4.w,
        mainAxisSpacing: isDesktop ? 1.5.w : 4.w,
        childAspectRatio: 1.1,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        return _buildTableCard(table, isDesktop);
      },
    );
  }

  Widget _buildTableCard(TableEntity table, bool isDesktop) {
    Color statusColor;
    switch (table.status) {
      case TableStatus.available:
        statusColor = AppColors.success;
        break;
      case TableStatus.occupied:
        statusColor = AppColors.error;
        break;
      case TableStatus.ongoing:
        statusColor = Colors.orange;
        break;
    }

    return Card(
      elevation: 4,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showAddEditTableDialog(context, ref, table: table),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 1.w : 3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 0.6.w : 1.5.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.table_restaurant,
                      color: AppColors.primary,
                      size: isDesktop ? 1.5.w : 5.w,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showAddEditTableDialog(context, ref, table: table);
                      } else if (value == 'delete') {
                        _showDeleteConfirmDialog(context, ref, table);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Table ${table.tableNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 13.sp : 16.sp,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Capacity: ${table.capacity}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isDesktop ? 11.sp : 13.sp,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  table.status.name.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 10.sp : 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEditTableDialog(
    BuildContext context,
    WidgetRef ref, {
    TableEntity? table,
  }) {
    showDialog(
      context: context,
      builder: (context) => _AddEditTableDialog(table: table),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    TableEntity table,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Table'),
        content: Text(
          'Are you sure you want to delete Table ${table.tableNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(tableManagementProvider.notifier)
                  .deleteTable(table.id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Table deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AddEditTableDialog extends ConsumerStatefulWidget {
  final TableEntity? table;

  const _AddEditTableDialog({this.table});

  @override
  ConsumerState<_AddEditTableDialog> createState() =>
      _AddEditTableDialogState();
}

class _AddEditTableDialogState extends ConsumerState<_AddEditTableDialog> {
  late TextEditingController _numberController;
  late TextEditingController _capacityController;
  TableStatus _status = TableStatus.available;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(
      text: widget.table?.tableNumber ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.table?.capacity.toString() ?? '4',
    );
    _status = widget.table?.status ?? TableStatus.available;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.table != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Table' : 'Add New Table'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Table Number/Name',
                hintText: 'e.g. 10 or A1',
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capacity',
                hintText: 'e.g. 4',
              ),
            ),
            if (isEditing) ...[
              SizedBox(height: 2.h),
              DropdownButtonFormField<TableStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: TableStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final number = _numberController.text;
            final capacity = int.tryParse(_capacityController.text) ?? 1;

            if (number.isEmpty) return;

            bool success;
            if (isEditing) {
              success = await ref
                  .read(tableManagementProvider.notifier)
                  .updateTable(widget.table!.id, number, capacity, _status);
            } else {
              success = await ref
                  .read(tableManagementProvider.notifier)
                  .createTable(number, capacity);
            }

            if (success && context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing ? 'Table updated' : 'Table created'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
