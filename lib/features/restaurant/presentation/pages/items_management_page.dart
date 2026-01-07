import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../features/rbac/presentation/widgets/permission_guard.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../../../menu/presentation/viewmodels/categories_view_model.dart';
import '../../../menu/presentation/viewmodels/items_view_model.dart';
import '../../../menu/presentation/viewmodels/customizations_view_model.dart';
import '../../../../features/tax/presentation/providers/tax_provider.dart';

class ItemsManagementPage extends ConsumerStatefulWidget {
  const ItemsManagementPage({super.key});

  @override
  ConsumerState<ItemsManagementPage> createState() =>
      _ItemsManagementPageState();
}

class _ItemsManagementPageState extends ConsumerState<ItemsManagementPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref.read(itemsNotifierProvider.notifier).loadItems();
      ref.read(categoriesNotifierProvider.notifier).loadCategories(limit: 1000);
      ref
          .read(customizationsNotifierProvider.notifier)
          .loadOptions(limit: 1000);
      ref.read(taxNotifierProvider.notifier).loadTaxes(limit: 1000);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(itemsNotifierProvider.notifier).loadItems(search: query);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(itemsNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsState = ref.watch(itemsNotifierProvider);
    final categoriesState = ref.watch(categoriesNotifierProvider);
    // final menuState = ref.watch(menuNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Items Management'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: switch (itemsState) {
              ItemsInitial() || ItemsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              ItemsError(:final message) => Center(
                child: Text('Error: $message'),
              ),
              ItemsLoaded(
                :final items,
                :final isLoadingMore,
                :final currentPage,
                :final totalPages,
              ) =>
                _buildItemList(items, isLoadingMore, currentPage < totalPages),
            },
          ),
        ],
      ),

      floatingActionButton: PermissionGuard(
        permission: PermissionConstants.itemCreate,
        child: FloatingActionButton(
          onPressed: () {
            final state = categoriesState;
            if (state is CategoriesLoaded) {
              context.push(RouteConstants.addItem, extra: null);
            }
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildItemList(
    List<MenuItemEntity> items,
    bool isLoadingMore,
    bool hasMore,
  ) {
    if (items.isEmpty) {
      return const Center(child: Text('No items found.'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: items.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = items[index];
        return Card(
          child: ListTile(
            leading: item.image.isNotEmpty
                ? Image.network(
                    item.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const CircleAvatar(child: Icon(Icons.fastfood)),
            title: Text(item.name),
            subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PermissionGuard(
                  permission: PermissionConstants.itemUpdate,
                  child: Switch(
                    value: item.isAvailable,
                    onChanged: (val) {
                      ref.read(itemsNotifierProvider.notifier).updateItem(
                        item.id,
                        {'isAvailable': val},
                      );
                    },
                  ),
                ),
                PermissionGuard(
                  permission: PermissionConstants.itemDelete,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    onPressed: () => _confirmDeleteItem(item),
                  ),
                ),
              ],
            ),
            onTap: () => context.push(RouteConstants.addItem, extra: item),
          ),
        );
      },
    );
  }

  void _confirmDeleteItem(MenuItemEntity item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final success = await ref
                  .read(itemsNotifierProvider.notifier)
                  .deleteItem(item.id);
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
