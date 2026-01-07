import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../viewmodels/staff_dashboard_view_model.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../features/rbac/presentation/widgets/permission_guard.dart';
import '../../../../core/constants/permission_constants.dart';

class ReportsAnalyticsPage extends ConsumerStatefulWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  ConsumerState<ReportsAnalyticsPage> createState() =>
      _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends ConsumerState<ReportsAnalyticsPage> {
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(staffDashboardProvider.notifier).loadDashboard(),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      ref
          .read(staffDashboardProvider.notifier)
          .loadDashboard(
            startDate: picked.start.toIso8601String(),
            endDate: picked.end.toIso8601String(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(staffDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          PermissionGuard(
            permission: PermissionConstants.reportExport,
            child: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                final bytes = await ref
                    .read(staffDashboardProvider.notifier)
                    .exportReport(
                      startDate: _dateRange?.start.toIso8601String(),
                      endDate: _dateRange?.end.toIso8601String(),
                    );
                if (bytes != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report downloaded (simulated)'),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.error != null
          ? Center(child: Text('Error: ${dashboardState.error}'))
          : _buildDashboard(dashboardState.stats ?? {}),
    );
  }

  Widget _buildDashboard(Map<String, dynamic> stats) {
    final summary = stats['summary'] ?? {};
    final totalNetSales = (summary['netSales'] as num?)?.toDouble() ?? 0.0;
    final totalOrderCount = (summary['orderCount'] as num?)?.toInt() ?? 0;
    final avgOrderValue = (summary['avgOrderValue'] as num?)?.toDouble() ?? 0.0;
    final totalRefunds = (summary['totalRefunds'] as num?)?.toDouble() ?? 0.0;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildStatCards(
          totalNetSales,
          totalOrderCount,
          avgOrderValue,
          totalRefunds,
        ),
        const SizedBox(height: 32),
        const Text(
          'Daily Sales Trend',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildSalesChart(stats['salesChart'] ?? []),
        const SizedBox(height: 32),
        const Text(
          'Peak Hours (Orders)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildPeakHoursChart(stats['peakHours'] ?? []),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildPopularItems(stats['topItems'] ?? []),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Methods',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentStats(stats['paymentStats'] ?? []),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Staff Performance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildStaffPerformance(stats['staffPerformance'] ?? []),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStatCards(
    double revenue,
    int orders,
    double aov,
    double refunds,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Net Sales',
                value: '\$${revenue.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Orders',
                value: orders.toString(),
                icon: Icons.shopping_bag,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Avg Order Value',
                value: '\$${aov.toStringAsFixed(2)}',
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Total Refunds',
                value: '\$${refunds.toStringAsFixed(2)}',
                icon: Icons.money_off,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesChart(List<dynamic> salesChart) {
    if (salesChart.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No sales data available")),
      );
    }

    // Sort by date just in case
    // Assuming _id is YYYY-MM-DD
    final sortedChart = List<Map<String, dynamic>>.from(salesChart);
    sortedChart.sort((a, b) => (a['_id'] ?? '').compareTo(b['_id'] ?? ''));

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 50,
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < sortedChart.length) {
                    final dateStr = sortedChart[index]['_id'].toString();
                    // Show only MM-DD for brevity
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dateStr.length >= 10 ? dateStr.substring(5) : dateStr,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
                interval: 1,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade200),
          ),
          lineBarsData: [
            // Sales Line
            LineChartBarData(
              spots: sortedChart.asMap().entries.map((e) {
                return FlSpot(
                  e.key.toDouble(),
                  (e.value['sales'] as num).toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeakHoursChart(List<dynamic> peakHours) {
    if (peakHours.isEmpty)
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No peak hours data')),
      );

    final sortedHours = List<Map<String, dynamic>>.from(peakHours);
    sortedHours.sort((a, b) => (a['_id'] as num).compareTo(b['_id'] as num));

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}h',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: sortedHours.map((e) {
            return BarChartGroupData(
              x: (e['_id'] as num).toInt(),
              barRods: [
                BarChartRodData(
                  toY: (e['count'] as num).toDouble(),
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPopularItems(List<dynamic> items) {
    if (items.isEmpty) return const Text('No data');

    return Column(
      children: items.map((item) {
        return Card(
          elevation: 0,
          color: Colors.grey.shade50,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            dense: true,
            title: Text(
              item['name'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${item['quantitySold'] ?? 0} sold'),
            trailing: Text(
              '\$${(item['revenue'] as num).toDouble().toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentStats(List<dynamic> stats) {
    if (stats.isEmpty) return const Text('No data');

    return Column(
      children: stats.map((stat) {
        return Card(
          elevation: 0,
          color: Colors.grey.shade50,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.payment, color: Colors.grey),
            title: Text(
              (stat['_id'] ?? 'Unknown').toString().toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${stat['count']} txns'),
            trailing: Text(
              '\$${(stat['volume'] as num).toDouble().toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStaffPerformance(List<dynamic> stats) {
    if (stats.isEmpty) return const Center(child: Text('No staff data'));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Staff')),
          DataColumn(label: Text('Orders')),
          DataColumn(label: Text('Sales')),
          DataColumn(label: Text('Avg Tip')),
        ],
        rows: stats.map((s) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  s['_id'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(Text('${s['ordersHandled']}')),
              DataCell(
                Text(
                  '\$${(s['totalSales'] as num).toDouble().toStringAsFixed(2)}',
                ),
              ),
              DataCell(
                Text('\$${(s['avgTip'] as num).toDouble().toStringAsFixed(2)}'),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
