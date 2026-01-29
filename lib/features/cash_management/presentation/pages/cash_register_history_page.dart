import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';
import '../viewmodels/cash_register_view_model.dart';
import '../../domain/entities/cash_history.dart';
import 'package:intl/intl.dart';

class CashRegisterHistoryPage extends ConsumerStatefulWidget {
  final String registerId;
  final String registerName;

  const CashRegisterHistoryPage({
    super.key,
    required this.registerId,
    required this.registerName,
  });

  @override
  ConsumerState<CashRegisterHistoryPage> createState() =>
      _CashRegisterHistoryPageState();
}

class _CashRegisterHistoryPageState
    extends ConsumerState<CashRegisterHistoryPage> {
  List<CashHistoryEntity>? _history;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final history = await ref
          .read(cashRegisterNotifierProvider.notifier)
          .getHistory(widget.registerId);

      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session History',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 19.sp,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              widget.registerName,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 2.w),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 22.sp,
              ),
              onPressed: _loadHistory,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 30.sp,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Failed to load history',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: _loadHistory,
                icon: Icon(Icons.refresh_rounded, size: 18.sp),
                label: Text('Try Again', style: TextStyle(fontSize: 16.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.5.h,
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

    if (_history == null || _history!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
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
                Icons.history_rounded,
                size: 35.sp,
                color: AppColors.grey300,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'No History Found',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Past sessions will appear here once closed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _history!.length,
      itemBuilder: (context, index) {
        final session = _history![index];
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildSessionCard(CashHistoryEntity session) {
    final status = session.status;
    final isOpen = status == 'open';

    // Convert to Local Time
    final formattedOpening = DateFormat(
      'MMM d, h:mm a',
    ).format(session.openedAt.toLocal());
    final formattedClosing = session.closedAt != null
        ? DateFormat('MMM d, h:mm a').format(session.closedAt!.toLocal())
        : 'Active Now';

    final totalSales = session.totalSales;
    final difference = session.difference ?? 0.0;
    final color = isOpen ? AppColors.success : AppColors.textSecondary;

    final openedBy = session.openedBy.name;
    final payIns = session.totalPayIns;
    final payOuts = session.totalPayOuts;
    final transactions = session.transactions;

    return Container(
      margin: EdgeInsets.only(bottom: 2.5.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            backgroundColor: AppColors.surface,
            collapsedBackgroundColor: AppColors.surface,
            tilePadding: EdgeInsets.all(4.w),
            childrenPadding: EdgeInsets.zero,
            leading: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                color: color,
                size: 22.sp,
              ),
            ),
            title: Text(
              isOpen ? 'Active Shift' : 'Completed Shift',
              style: TextStyle(
                fontSize: 16.5.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 0.5.h),
                Text(
                  '$formattedOpening → $formattedClosing',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14.sp,
                      color: AppColors.textHint,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Staff: $openedBy',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${totalSales.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 17.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Sales',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textHint,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            children: [
              const Divider(height: 1, color: AppColors.grey100),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(color: AppColors.grey50),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSessionStat(
                          'Opening',
                          '\$${session.openingBalance.toStringAsFixed(2)}',
                          AppColors.textSecondary,
                        ),
                        _buildSessionStat(
                          'Pay-Ins',
                          '+\$${payIns.toStringAsFixed(2)}',
                          AppColors.success,
                        ),
                        _buildSessionStat(
                          'Pay-Outs',
                          '-\$${payOuts.toStringAsFixed(2)}',
                          AppColors.error,
                        ),
                        if (!isOpen)
                          _buildSessionStat(
                            'Diff',
                            '\$${difference.toStringAsFixed(2)}',
                            difference < 0
                                ? AppColors.error
                                : (difference > 0
                                      ? AppColors.success
                                      : AppColors.textSecondary),
                          ),
                      ],
                    ),
                    if (session.openingNotes != null &&
                        session.openingNotes!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Opening Notes:',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textHint,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              session.openingNotes!,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: AppColors.textPrimary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (transactions.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 1.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 16.sp,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'TRANSACTIONS',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: AppColors.grey100,
                  ),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return _buildTransactionItem(tx);
                  },
                ),
                SizedBox(height: 2.h),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(CashTransactionEntity tx) {
    final type = tx.type;
    final amount = tx.amount;
    final timestamp = tx.timestamp;
    final isPositive = type == 'sale' || type == 'cash_in' || type == 'pay_in';

    IconData icon;
    Color color;
    switch (type) {
      case 'sale':
        icon = Icons.shopping_cart_rounded;
        color = AppColors.primary;
        break;
      case 'cash_in':
      case 'pay_in':
        icon = Icons.add_circle_rounded;
        color = AppColors.success;
        break;
      case 'cash_out':
      case 'pay_out':
        icon = Icons.remove_circle_rounded;
        color = AppColors.error;
        break;
      default:
        icon = Icons.swap_horiz_rounded;
        color = AppColors.textSecondary;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.reason,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('h:mm a').format(timestamp.toLocal()),
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textHint),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textHint,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}
