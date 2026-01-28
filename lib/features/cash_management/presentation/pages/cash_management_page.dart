import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../features/rbac/presentation/widgets/permission_guard.dart';
import '../viewmodels/cash_register_view_model.dart';
import '../../domain/entities/cash_register.dart';

class CashManagementPage extends ConsumerStatefulWidget {
  const CashManagementPage({super.key});

  @override
  ConsumerState<CashManagementPage> createState() => _CashManagementPageState();
}

class _CashManagementPageState extends ConsumerState<CashManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cashRegisterNotifierProvider.notifier).loadRegisters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashRegisterNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Cash Register Management',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 24),
            onPressed: () =>
                ref.read(cashRegisterNotifierProvider.notifier).loadRegisters(),
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton:
          // PermissionGuard(
          //   permission: PermissionConstants.cashRegisterCreate,
          //   child:
          FloatingActionButton(
            onPressed: () => _showCreateRegisterDialog(),
            backgroundColor: const Color(0xFF6366F1),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
      // ),
    );
  }

  Widget _buildBody(CashRegisterState state) {
    if (state is CashRegisterLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CashRegisterError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(cashRegisterNotifierProvider.notifier)
                  .loadRegisters(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is CashRegisterLoaded) {
      if (state.registers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.point_of_sale_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'No cash registers found',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.registers.length,
        itemBuilder: (context, index) {
          final register = state.registers[index];
          return _buildRegisterCard(register);
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRegisterCard(CashRegisterEntity register) {
    final isOpen = register.isOpen;
    final color = isOpen ? const Color(0xFF10B981) : const Color(0xFF94A3B8);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.point_of_sale_rounded,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        register.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOpen ? 'Open Session' : 'Closed',
                            style: TextStyle(
                              fontSize: 13,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isOpen && register.currentSession != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFFF8FAFC),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Opening',
                    '\$${register.currentSession!.openingBalance.toStringAsFixed(2)}',
                  ),
                  _buildStatItem(
                    'Sales',
                    '\$${register.currentSession!.totalSales.toStringAsFixed(2)}',
                  ),
                  _buildStatItem(
                    'Current',
                    '\$${(register.currentSession!.openingBalance + register.currentSession!.totalSales).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isOpen)
                  _buildActionButton(
                    'Open Shift',
                    Icons.login_rounded,
                    const Color(0xFF6366F1),
                    () => _showOpenShiftDialog(register),
                  ),
                if (isOpen) ...[
                  _buildActionButton(
                    'Transaction',
                    Icons.swap_horiz_rounded,
                    const Color(0xFF64748B),
                    () => _showTransactionDialog(register),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    'Close Shift',
                    Icons.logout_rounded,
                    const Color(0xFFF43F5E),
                    () => _showCloseShiftDialog(register),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateRegisterDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Register'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Register Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final success = await ref
                    .read(cashRegisterNotifierProvider.notifier)
                    .createRegister(controller.text);
                if (success && mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showOpenShiftDialog(CashRegisterEntity register) {
    final balanceController = TextEditingController();
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Open Shift: ${register.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Opening Balance'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(hintText: 'Notes (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final balance = double.tryParse(balanceController.text) ?? 0.0;
              final success = await ref
                  .read(cashRegisterNotifierProvider.notifier)
                  .openShift(
                    register.id,
                    balance,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                  );
              if (success && mounted) Navigator.pop(context);
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDialog(CashRegisterEntity register) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    String type = 'cash_in';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Manual Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: type,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'cash_in', child: Text('Cash In')),
                  DropdownMenuItem(value: 'cash_out', child: Text('Cash Out')),
                ],
                onChanged: (val) => setState(() => type = val!),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Amount'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(hintText: 'Reason'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount > 0 && reasonController.text.isNotEmpty) {
                  final success = await ref
                      .read(cashRegisterNotifierProvider.notifier)
                      .addTransaction(
                        register.id,
                        type,
                        amount,
                        reasonController.text,
                      );
                  if (success && mounted) Navigator.pop(context);
                }
              },
              child: const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCloseShiftDialog(CashRegisterEntity register) {
    final cashController = TextEditingController();
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Shift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cashController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Actual Cash in Drawer',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(hintText: 'Notes (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final cash = double.tryParse(cashController.text) ?? 0.0;
              final summary = await ref
                  .read(cashRegisterNotifierProvider.notifier)
                  .closeShift(
                    register.id,
                    cash,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                  );
              if (summary != null && mounted) {
                Navigator.pop(context);
                _showSummaryDialog(summary);
              }
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSummaryDialog(Map<String, dynamic> summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shift Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('Opening:', '\$${summary['openingBalance']}'),
            _buildSummaryRow('Sales:', '\$${summary['totalSales']}'),
            _buildSummaryRow('Expected:', '\$${summary['expectedCash']}'),
            _buildSummaryRow('Actual:', '\$${summary['actualCash']}'),
            const Divider(),
            _buildSummaryRow(
              'Difference:',
              '\$${summary['difference']}',
              color: (summary['difference'] as num) < 0
                  ? Colors.red
                  : Colors.green,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
