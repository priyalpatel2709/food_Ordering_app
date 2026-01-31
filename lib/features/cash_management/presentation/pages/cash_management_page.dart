import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../viewmodels/cash_register_view_model.dart';
import '../../domain/entities/cash_register.dart';
import '../../domain/entities/cash_shift_summary.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Registers',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              onPressed: () => ref
                  .read(cashRegisterNotifierProvider.notifier)
                  .loadRegisters(),
            ),
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRegisterDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Register',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildBody(CashRegisterState state) {
    if (state is CashRegisterLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is CashRegisterError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(cashRegisterNotifierProvider.notifier)
                    .loadRegisters(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is CashRegisterLoaded) {
      if (state.registers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.point_of_sale_outlined,
                  size: 80,
                  color: AppColors.grey300,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Registers Setup',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add your first cash register to start\ntracking cash movements.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
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
    final statusColor = isOpen ? AppColors.success : AppColors.grey600;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.point_of_sale_rounded,
                      color: statusColor,
                      size: 28,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOpen ? 'OPEN' : 'CLOSED',
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildIconButton(
                    Icons.history_rounded,
                    AppColors.primary,
                    () => context.pushNamed(
                      RouteConstants.cashHistoryName,
                      extra: {
                        'registerId': register.id,
                        'registerName': register.name,
                      },
                    ),
                    'History',
                  ),
                ],
              ),
            ),
            if (isOpen && register.currentSession != null) ...[
              const Divider(height: 1, color: AppColors.grey100),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(color: AppColors.grey50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatPill(
                      'Opening',
                      '\$${register.currentSession!.openingBalance.toStringAsFixed(2)}',
                      AppColors.textSecondary,
                    ),
                    _buildStatPill(
                      'Sales',
                      '\$${register.currentSession!.totalSales.toStringAsFixed(2)}',
                      AppColors.success,
                    ),
                    _buildStatPill(
                      'Current',
                      '\$${(register.currentSession!.openingBalance + register.currentSession!.totalSales).toStringAsFixed(2)}',
                      AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (!isOpen)
                    Expanded(
                      child: _buildPrimaryButton(
                        'OPEN SHIFT',
                        Icons.login_rounded,
                        AppColors.primary,
                        () => _showOpenShiftDialog(register),
                      ),
                    ),
                  if (isOpen) ...[
                    Expanded(
                      child: _buildSecondaryButton(
                        'TRANSACTION',
                        Icons.swap_horiz_rounded,
                        AppColors.textSecondary,
                        () => _showTransactionDialog(register),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPrimaryButton(
                        'CLOSE SHIFT',
                        Icons.logout_rounded,
                        AppColors.error,
                        () => _showCloseShiftDialog(register),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    Color color,
    VoidCallback onTap,
    String tooltip,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onTap,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.textHint,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSecondaryButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.2), width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showCreateRegisterDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _buildStyledDialog(
        title: 'New Register',
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'e.g. Counter 1, Drive-thru',
            labelText: 'Register Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        onConfirm: () async {
          if (controller.text.isNotEmpty) {
            final success = await ref
                .read(cashRegisterNotifierProvider.notifier)
                .createRegister(controller.text);
            if (success && mounted) Navigator.pop(context);
          }
        },
        confirmLabel: 'CREATE',
      ),
    );
  }

  void _showOpenShiftDialog(CashRegisterEntity register) {
    final balanceController = TextEditingController();
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _buildStyledDialog(
        title: 'Open Shift',
        subtitle: register.name,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0.00',
                labelText: 'Opening Balance',
                prefixIcon: const Icon(Icons.attach_money_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'e.g. Starting float from safe',
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        onConfirm: () async {
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
        confirmLabel: 'OPEN SHIFT',
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
        builder: (context, setState) => _buildStyledDialog(
          title: 'Cash Movement',
          subtitle: register.name,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: type,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'cash_in',
                        child: Text('Cash In (+)'),
                      ),
                      DropdownMenuItem(
                        value: 'cash_out',
                        child: Text('Cash Out (-)'),
                      ),
                      DropdownMenuItem(
                        value: 'pay_in',
                        child: Text('Pay In (+)'),
                      ),
                      DropdownMenuItem(
                        value: 'pay_out',
                        child: Text('Pay Out (-)'),
                      ),
                    ],
                    onChanged: (val) => setState(() => type = val!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0.00',
                  labelText: 'Amount',
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'e.g. Petty cash refill',
                  labelText: 'Reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          onConfirm: () async {
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
          confirmLabel: 'RECORD',
        ),
      ),
    );
  }

  void _showCloseShiftDialog(CashRegisterEntity register) {
    final cashController = TextEditingController();
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _buildStyledDialog(
        title: 'Close Shift',
        subtitle: register.name,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Expected Cash:',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    '\$${(register.currentSession!.openingBalance + register.currentSession!.totalSales).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: cashController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                labelText: 'Actual Cash Counted',
                prefixIcon: const Icon(Icons.attach_money_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'Any discrepancies?',
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        onConfirm: () async {
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
        confirmLabel: 'CLOSE & RECONCILE',
        confirmColor: AppColors.error,
      ),
    );
  }

  Widget _buildStyledDialog({
    required String title,
    String? subtitle,
    required Widget content,
    required VoidCallback onConfirm,
    required String confirmLabel,
    Color confirmColor = AppColors.primary,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 24),
            content,
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSummaryDialog(CashShiftSummaryEntity summary) {
    final diff = summary.difference;
    final diffColor = diff < 0
        ? AppColors.error
        : (diff > 0 ? AppColors.success : AppColors.textSecondary);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: diff == 0 ? AppColors.success : AppColors.warning,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    diff == 0
                        ? Icons.check_circle_outline_rounded
                        : Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    diff == 0
                        ? 'Perfect Reconciliation!'
                        : 'Session Reconciled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'EXPECTED',
                    '\$${summary.expectedBalance.toStringAsFixed(2)}',
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'ACTUAL',
                    '\$${summary.actualCash.toStringAsFixed(2)}',
                    color: AppColors.textPrimary,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  _buildSummaryRow(
                    'DIFFERENCE',
                    '${diff >= 0 ? '+' : ''}\$${diff.toStringAsFixed(2)}',
                    color: diffColor,
                    isTotal: true,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'DONE',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
            color: AppColors.textHint,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.w900,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
