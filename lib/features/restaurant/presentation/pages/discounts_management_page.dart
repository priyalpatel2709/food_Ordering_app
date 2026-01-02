import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../discount/presentation/providers/discount_provider.dart';
import '../../../discount/domain/entities/discount_entity.dart';
import '../../../../shared/theme/app_colors.dart';

class DiscountsManagementPage extends ConsumerStatefulWidget {
  const DiscountsManagementPage({super.key});

  @override
  ConsumerState<DiscountsManagementPage> createState() =>
      _DiscountsManagementPageState();
}

class _DiscountsManagementPageState
    extends ConsumerState<DiscountsManagementPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref.read(discountNotifierProvider.notifier).loadDiscounts(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(discountNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final discountState = ref.watch(discountNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discounts Management'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: switch (discountState) {
        DiscountInitial() ||
        DiscountLoading() => const Center(child: CircularProgressIndicator()),
        DiscountError(:final message) => Center(child: Text('Error: $message')),
        DiscountLoaded(
          :final discounts,
          :final isLoadingMore,
          :final currentPage,
          :final totalPages,
        ) =>
          _buildDiscountList(
            discounts,
            isLoadingMore,
            currentPage < totalPages,
          ),
      },
      floatingActionButton: FloatingActionButton(
        // heroTag: 'discounts_management_fab',
        onPressed: () => _showAddDiscountDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDiscountList(
    List<DiscountEntity> discounts,
    bool isLoadingMore,
    bool hasMore,
  ) {
    if (discounts.isEmpty) {
      return const Center(child: Text('No discounts found.'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: discounts.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == discounts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final discount = discounts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.local_offer, color: Colors.redAccent),
            title: Text(
              discount.discountCode ?? 'No Code',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${discount.value}${discount.type == 'percentage' ? '%' : '\$'} off',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: discount.isActive ?? false,
                  onChanged: (val) {
                    ref.read(discountNotifierProvider.notifier).updateDiscount(
                      discount.id ?? '',
                      {'isActive': val},
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: () => _confirmDeleteDiscount(discount),
                ),
              ],
            ),
            onTap: () => _showEditDiscountDialog(discount),
          ),
        );
      },
    );
  }

  void _showAddDiscountDialog() {
    final codeController = TextEditingController();
    final valueController = TextEditingController();
    String type = 'percentage';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Discount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Discount Code'),
                textCapitalization: TextCapitalization.characters,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Value'),
                keyboardType: TextInputType.number,
              ),

              DropdownButton<String>(
                isExpanded: true,
                value: type,
                items: const [
                  DropdownMenuItem(
                    value: 'percentage',
                    child: Text('Percentage'),
                  ),
                  DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => type = val);
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Valid From'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Valid To'),
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
                    .read(discountNotifierProvider.notifier)
                    .createDiscount({
                      'discountCode': codeController.text.toUpperCase(),
                      'type': type,
                      'value': double.tryParse(valueController.text) ?? 0.0,
                      'isActive': true,
                      'validFrom': DateTime.now().toIso8601String(),
                      'validTo': DateTime.now()
                          .add(const Duration(days: 30))
                          .toIso8601String(),
                    });
                if (success && mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDiscountDialog(DiscountEntity discount) {
    final codeController = TextEditingController(text: discount.discountCode);
    final valueController = TextEditingController(
      text: discount.value.toString(),
    );
    String type = discount.type ?? 'percentage';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Discount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Discount Code'),
                textCapitalization: TextCapitalization.characters,
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Value'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: type,
                items: const [
                  DropdownMenuItem(
                    value: 'percentage',
                    child: Text('Percentage'),
                  ),
                  DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => type = val);
                },
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
                    .read(discountNotifierProvider.notifier)
                    .updateDiscount(discount.id ?? '', {
                      'discountCode': codeController.text.toUpperCase(),
                      'type': type,
                      'value': double.tryParse(valueController.text) ?? 0.0,
                    });
                if (success && mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteDiscount(DiscountEntity discount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Discount'),
        content: Text(
          'Are you sure you want to delete "${discount.discountCode}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final success = await ref
                  .read(discountNotifierProvider.notifier)
                  .deleteDiscount(discount.id ?? '');
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
