import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../viewmodels/staff_dashboard_view_model.dart';
import 'package:fl_chart/fl_chart.dart';

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
          IconButton(
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
    final totalRevenue = stats['totalRevenue'] ?? 0.0;
    final totalOrders = stats['totalOrders'] ?? 0;
    final averageOrderValue = stats['averageOrderValue'] ?? 0.0;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildStatCards(totalRevenue, totalOrders, averageOrderValue),
        const SizedBox(height: 32),
        const Text(
          'Revenue Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildRevenueChart(stats['revenueHistory'] ?? []),
        const SizedBox(height: 32),
        const Text(
          'Popular Items',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildPopularItems(stats['popularItems'] ?? []),
      ],
    );
  }

  Widget _buildStatCards(double revenue, int orders, double aov) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Revenue',
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
    );
  }

  Widget _buildRevenueChart(List<dynamic> history) {
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
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: history.asMap().entries.map((e) {
                return FlSpot(
                  e.key.toDouble(),
                  (e.value['amount'] as num).toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItems(List<dynamic> items) {
    return Column(
      children: items.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.fastfood)),
            title: Text(item['name'] ?? 'Unknown Item'),
            subtitle: Text('${item['count']} orders'),
            trailing: Text(
              '\$${(item['revenue'] as num).toDouble().toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
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
