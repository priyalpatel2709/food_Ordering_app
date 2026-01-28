import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/loyalty_providers.dart';
import '../widgets/create_customer_dialog.dart';
import 'customer_detail_page.dart';

class LoyaltyManagementPage extends ConsumerStatefulWidget {
  const LoyaltyManagementPage({super.key});

  @override
  ConsumerState<LoyaltyManagementPage> createState() =>
      _LoyaltyManagementPageState();
}

class _LoyaltyManagementPageState extends ConsumerState<LoyaltyManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTier;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(loyaltyNotifierProvider.notifier).fetchAllCustomers();
      ref.read(loyaltyNotifierProvider.notifier).fetchUpcomingOccasions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    ref
        .read(loyaltyNotifierProvider.notifier)
        .fetchAllCustomers(
          search: value.isEmpty ? null : value,
          tier: _selectedTier,
        );
  }

  void _onTierFilter(String? tier) {
    setState(() => _selectedTier = tier);
    ref
        .read(loyaltyNotifierProvider.notifier)
        .fetchAllCustomers(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          tier: tier,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loyaltyNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Loyalty Management'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(loyaltyNotifierProvider.notifier).fetchAllCustomers();
              ref
                  .read(loyaltyNotifierProvider.notifier)
                  .fetchUpcomingOccasions();
            },
            icon: const Icon(Icons.refresh),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CreateCustomerDialog(
                    onCustomerCreated: (_) {
                      ref
                          .read(loyaltyNotifierProvider.notifier)
                          .fetchAllCustomers();
                    },
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Customers List
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Filter & Search Header
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by name, email, or phone...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          onChanged: (v) => _onSearch(v),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _selectedTier,
                          decoration: InputDecoration(
                            hintText: 'Filter by Tier',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Tiers'),
                            ),
                            ...[
                              'bronze',
                              'silver',
                              'gold',
                              'platinum',
                              'vip',
                            ].map(
                              (tier) => DropdownMenuItem(
                                value: tier,
                                child: Text(tier.toUpperCase()),
                              ),
                            ),
                          ],
                          onChanged: _onTierFilter,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: state.isLoading && state.allCustomers.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : state.allCustomers.isEmpty
                      ? _buildEmptyState()
                      : _buildCustomerGrid(state.allCustomers),
                ),
              ],
            ),
          ),

          // Sidebar for Upcoming Occasions
          VerticalDivider(width: 1, color: Colors.grey[200]),
          Container(
            width: 320,
            color: Colors.white,
            child: _buildUpcomingSidebar(state),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSidebar(LoyaltyState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.orange),
              const SizedBox(width: 12),
              const Text(
                'Upcoming Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.isLoading && state.upcomingOccasions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.upcomingOccasions.isEmpty
              ? Center(
                  child: Text(
                    'No upcoming events\nin the next 7 days ${state.upcomingOccasions.length}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.upcomingOccasions.length,
                  itemBuilder: (context, index) {
                    final customer = state.upcomingOccasions[index];
                    final isBirthday =
                        customer.dateOfBirth != null; // Simple check

                    return Card(
                      elevation: 0,
                      color: Colors.grey[50],
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        onTap: () => _navigateToCustomerDetail(customer.id),
                        leading: CircleAvatar(
                          backgroundColor:
                              (isBirthday ? Colors.pink : Colors.blue)
                                  .withOpacity(0.1),
                          child: Icon(
                            isBirthday ? Icons.cake : Icons.favorite,
                            size: 16,
                            color: isBirthday ? Colors.pink : Colors.blue,
                          ),
                        ),
                        title: Text(
                          customer.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          isBirthday ? 'Birthday coming up!' : 'Anniversary!',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCustomerGrid(List customers) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.5,
      ),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: InkWell(
            onTap: () => _navigateToCustomerDetail(customer.id),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          customer.name[0].toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              customer.phone,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTierBadge(customer.loyaltyTier, customer.tierEmoji),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${customer.loyaltyPoints.current}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.secondary,
                            ),
                          ),
                          const Text(
                            'Points',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToCustomerDetail(String customerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(customerId: customerId),
      ),
    );
  }

  Widget _buildTierBadge(String tier, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            tier.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No customers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Try adding your first loyalty member!'
                : 'Try a different search term',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
