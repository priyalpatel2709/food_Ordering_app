import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/customer_loyalty_entity.dart';
import '../providers/loyalty_providers.dart';
import './create_customer_dialog.dart';

/// Dialog for looking up customer loyalty information
class CustomerLookupDialog extends ConsumerStatefulWidget {
  final Function(CustomerLoyaltyEntity)? onCustomerFound;

  const CustomerLookupDialog({super.key, this.onCustomerFound});

  @override
  ConsumerState<CustomerLookupDialog> createState() =>
      _CustomerLookupDialogState();
}

class _CustomerLookupDialogState extends ConsumerState<CustomerLookupDialog> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Start with a clean state to avoid showing previous searches
    Future.microtask(() {
      if (mounted) {
        ref.read(loyaltyNotifierProvider.notifier).clearCustomer();
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    // Clean up the search state when the dialog is closed
    // This ensures that the global state is reset for the next time the dialog is opened.
    Future.microtask(() {
      // Check mounted is not enough here as the state is defunct,
      // but we use a microtask to ensure we are out of the dispose frame.
      // ref.read(loyaltyNotifierProvider.notifier).clearCustomer();
    });
    super.dispose();
  }

  Future<void> _lookupCustomer() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() => _isSearching = true);

    await ref.read(loyaltyNotifierProvider.notifier).lookupCustomer(phone);

    setState(() => _isSearching = false);

    // No longer automatically calling onCustomerFound here.
    // The user must explicitly click "Use This Customer" or select from the list.
  }

  void _showCreateCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateCustomerDialog(
        initialPhone: _phoneController.text.trim(),
        onCustomerCreated: (customer) {
          if (widget.onCustomerFound != null) {
            widget.onCustomerFound!(customer);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loyaltyState = ref.watch(loyaltyNotifierProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.person_search, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Customer Lookup',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Phone Input
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number or Email',
                hintText: '+1234567890',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              keyboardType: TextInputType.phone,
              onSubmitted: (_) => _lookupCustomer(),
            ),
            const SizedBox(height: 16),

            // Search Button
            ElevatedButton.icon(
              onPressed: _isSearching ? null : _lookupCustomer,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Error Message
            // if (loyaltyState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Customer not found',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _showCreateCustomerDialog,
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Register New Customer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary.withOpacity(0.1),
                        foregroundColor: AppColors.secondary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // ],

            // Multiple Results Found
            if (loyaltyState.customer == null &&
                loyaltyState.searchResults.length > 1) ...[
              const SizedBox(height: 24),
              Text(
                'Multiple matches found:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: loyaltyState.searchResults.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final customer = loyaltyState.searchResults[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            customer.name[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(customer.phone),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.stars,
                              size: 12,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${customer.loyaltyPoints.current} pts',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      onTap: () {
                        ref
                            .read(loyaltyNotifierProvider.notifier)
                            .selectCustomer(customer);
                        if (widget.onCustomerFound != null) {
                          widget.onCustomerFound!(customer);
                        }
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],

            // Customer Info
            if (loyaltyState.customer != null) ...[
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: _CustomerInfoCard(customer: loyaltyState.customer!),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (widget.onCustomerFound != null) {
                        widget.onCustomerFound!(loyaltyState.customer!);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Use This Customer'),
                  ),
                  SizedBox(width: 2.w),
                  ElevatedButton(
                    onPressed: () {
                      // Just clear the selection within the dialog to allow a new search
                      _phoneController.clear();
                      ref
                          .read(loyaltyNotifierProvider.notifier)
                          .clearCustomer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Clear Search'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomerInfoCard extends StatelessWidget {
  final CustomerLoyaltyEntity customer;

  const _CustomerInfoCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Name & Tier
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  customer.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          customer.tierEmoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${customer.loyaltyTier.toUpperCase()} Member',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Points Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Points',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${customer.loyaltyPoints.current}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Worth',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${customer.availableDiscount}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      label: 'Lifetime',
                      value: '${customer.loyaltyPoints.lifetime}',
                    ),
                    _StatItem(
                      label: 'Redeemed',
                      value: '${customer.loyaltyPoints.redeemed}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Visit Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visit Statistics',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      label: 'Total Visits',
                      value: '${customer.visitStats.totalVisits}',
                    ),
                    _StatItem(
                      label: 'Avg Order',
                      value:
                          '\$${customer.visitStats.averageOrderValue.toStringAsFixed(2)}',
                    ),
                    _StatItem(
                      label: 'Total Spent',
                      value:
                          '\$${customer.visitStats.totalSpent.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Allergies & Preferences
          if (customer.preferences != null &&
              (customer.preferences!.allergies.isNotEmpty ||
                  customer.preferences!.dietaryRestrictions.isNotEmpty)) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important Notes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  if (customer.preferences!.allergies.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Allergies: ${customer.preferences!.allergies.join(", ")}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                  if (customer.preferences!.dietaryRestrictions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Dietary: ${customer.preferences!.dietaryRestrictions.join(", ")}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Notes
          if (customer.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.note, color: Colors.amber[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Staff Notes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...customer.notes
                      .take(2)
                      .map(
                        (note) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• ${note.note}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
