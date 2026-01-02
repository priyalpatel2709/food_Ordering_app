import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../tax/presentation/providers/tax_provider.dart';
import '../../../tax/domain/entities/tax_entity.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class TaxesManagementPage extends ConsumerStatefulWidget {
  const TaxesManagementPage({super.key});

  @override
  ConsumerState<TaxesManagementPage> createState() =>
      _TaxesManagementPageState();
}

class _TaxesManagementPageState extends ConsumerState<TaxesManagementPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(taxNotifierProvider.notifier).loadTaxes());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(taxNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final taxState = ref.watch(taxNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taxes Management'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: switch (taxState) {
        TaxInitial() ||
        TaxLoading() => const Center(child: CircularProgressIndicator()),
        TaxError(:final message) => Center(child: Text('Error: $message')),
        TaxLoaded(
          :final taxes,
          :final isLoadingMore,
          :final currentPage,
          :final totalPages,
        ) =>
          _buildTaxList(taxes, isLoadingMore, currentPage < totalPages),
      },
      floatingActionButton: FloatingActionButton(
        // heroTag: 'taxes_management_fab',
        onPressed: () => _showAddTaxDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaxList(
    List<TaxEntity> taxes,
    bool isLoadingMore,
    bool hasMore,
  ) {
    if (taxes.isEmpty) {
      return const Center(child: Text('No taxes found.'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: taxes.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == taxes.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final tax = taxes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.green),
            title: Text(
              tax.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${tax.rate}%'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: tax.isActive,
                  onChanged: (val) {
                    ref.read(taxNotifierProvider.notifier).updateTax(tax.id, {
                      'isActive': val,
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: () => _confirmDeleteTax(tax),
                ),
              ],
            ),
            onTap: () => _showEditTaxDialog(tax),
          ),
        );
      },
    );
  }

  void _showAddTaxDialog() {
    final nameController = TextEditingController();
    final rateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tax Rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tax Name (e.g. VAT)',
              ),
            ),
            TextField(
              controller: rateController,
              decoration: const InputDecoration(labelText: 'Rate (%)'),
              keyboardType: TextInputType.number,
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
              final authState = ref.read(authNotifierProvider);
              String? restaurantId;
              if (authState is AuthAuthenticated) {
                restaurantId = authState.user.restaurantsId;
              }

              final success = await ref
                  .read(taxNotifierProvider.notifier)
                  .createTax({
                    'name': nameController.text,
                    'rate': double.tryParse(rateController.text) ?? 0.0,
                    'isActive': true,
                    if (restaurantId != null) 'restaurantId': restaurantId,
                  });
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditTaxDialog(TaxEntity tax) {
    final nameController = TextEditingController(text: tax.name);
    final rateController = TextEditingController(text: tax.rate.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tax Rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tax Name'),
            ),
            TextField(
              controller: rateController,
              decoration: const InputDecoration(labelText: 'Rate (%)'),
              keyboardType: TextInputType.number,
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
              final success = await ref
                  .read(taxNotifierProvider.notifier)
                  .updateTax(tax.id, {
                    'name': nameController.text,
                    'rate': double.tryParse(rateController.text) ?? 0.0,
                  });
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTax(TaxEntity tax) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tax'),
        content: Text('Are you sure you want to delete "${tax.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final success = await ref
                  .read(taxNotifierProvider.notifier)
                  .deleteTax(tax.id);
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
