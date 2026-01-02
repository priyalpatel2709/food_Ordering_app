import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/user.dart';
import '../../../../shared/theme/app_colors.dart';
import '../viewmodels/menu_view_model.dart';
import '../../domain/entities/menu_entity.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../widgets/user_header_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/menu_item_card.dart';
import '../../../dine_in/presentation/providers/dine_in_providers.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  final StorageService _storageService = StorageService();
  User? _currentUser;
  bool _isLoadingUser = true;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Load menu using the view model
    Future.microtask(
      () => ref.read(menuNotifierProvider.notifier).loadCurrentMenu(),
    );
  }

  Future<void> _loadUserData() async {
    final user = _storageService.getUser();
    setState(() {
      _currentUser = user;
      _isLoadingUser = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.clearUser();
      if (!mounted) return;
      context.go(RouteConstants.login);
    }
  }

  void _handleCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  List<MenuItemEntity> _filterItemsByCategory(
    List<MenuItemEntity> items,
    String? categoryId,
  ) {
    if (categoryId == null) {
      return items;
    }
    return items.where((item) => item.category.id == categoryId).toList();
  }

  Widget _buildDineInBanner() {
    final session = ref.watch(dineInSessionProvider);
    if (session == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primary.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(
            Icons.table_restaurant,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ordering for Table ${session.tableNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(dineInSessionProvider.notifier).state = null;
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final menuState = ref.watch(menuNotifierProvider);
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      appBar: canPop
          ? AppBar(
              title: const Text('Select Items'),
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: AppColors.primary,
                  ),
                  onPressed: () => context.push(RouteConstants.cart),
                ),
              ],
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.grey50,
              AppColors.white,
              AppColors.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (!canPop)
                UserHeaderCard(user: _currentUser, onLogout: _handleLogout),
              _buildDineInBanner(),
              Expanded(child: _buildContent(menuState)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MenuState state) {
    return switch (state) {
      MenuInitial() => const Center(child: Text('Initializing...')),
      MenuLoading() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading menu...',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      MenuError(:final message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(menuNotifierProvider.notifier).refreshCurrentMenu(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
      MenuLoaded(:final menus) =>
        menus.isEmpty
            ? const Center(
                child: Text(
                  'No menu available',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref
                    .read(menuNotifierProvider.notifier)
                    .refreshCurrentMenu(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const MenuHeader(),
                      // const SizedBox(height: 24),
                      ...menus.map((menu) => _buildMenuSection(menu)),
                    ],
                  ),
                ),
              ),
    };
  }

  Widget _buildMenuSection(MenuEntity menu) {
    final filteredItems = _filterItemsByCategory(
      menu.items,
      _selectedCategoryId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                menu.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                menu.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        CategoryChips(
          categories: menu.categories,
          selectedCategoryId: _selectedCategoryId,
          onCategorySelected: _handleCategorySelected,
        ),
        const SizedBox(height: 16),
        _buildMenuItems(filteredItems),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMenuItems(List<MenuItemEntity> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.grey400),
              const SizedBox(height: 16),
              const Text(
                'No items found in this category',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // Get cart state
    final cartState = ref.watch(cartNotifierProvider);
    final cartItems = cartState is CartLoaded
        ? cartState.items
        : <CartItemEntity>[];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final menuItem = items[index];

        // Find if this item is in cart (without customizations)
        final cartItemWithoutCustomizations = cartItems.firstWhere(
          (cartItem) =>
              cartItem.menuItemId == menuItem.id &&
              cartItem.selectedCustomizations.isEmpty,
          orElse: () => CartItemEntity(
            id: '',
            menuItemId: '',
            menuItemName: '',
            menuItemImage: '',
            basePrice: 0,
            quantity: 0,
            selectedCustomizations: [],
            addedAt: DateTime.now(),
          ),
        );

        final hasItemInCart = cartItemWithoutCustomizations.id.isNotEmpty;
        final currentQuantity = hasItemInCart
            ? cartItemWithoutCustomizations.quantity
            : 0;

        return MenuItemCard(
          item: menuItem,
          hasItemInCart: hasItemInCart,
          currentQuantity: currentQuantity,
          onAddToCart: (selectedCustomizations) {
            // Add item to cart with selected customizations
            ref
                .read(cartNotifierProvider.notifier)
                .addItem(
                  menuItemId: menuItem.id,
                  menuItemName: menuItem.name,
                  menuItemImage: menuItem.image,
                  basePrice: menuItem.price,
                  selectedCustomizations: selectedCustomizations,
                  taxRate: menuItem.taxRate,
                );
          },
          onIncrement: () {
            // Increment the item without customizations
            if (hasItemInCart) {
              ref
                  .read(cartNotifierProvider.notifier)
                  .incrementQuantity(cartItemWithoutCustomizations.id);
            } else {
              // Add new item without customizations
              ref
                  .read(cartNotifierProvider.notifier)
                  .addItem(
                    menuItemId: menuItem.id,
                    menuItemName: menuItem.name,
                    menuItemImage: menuItem.image,
                    basePrice: menuItem.price,
                    selectedCustomizations: [],
                    taxRate: menuItem.taxRate,
                  );
            }
          },
          onDecrement: () {
            // Decrement the item without customizations
            if (hasItemInCart) {
              ref
                  .read(cartNotifierProvider.notifier)
                  .decrementQuantity(cartItemWithoutCustomizations.id);
            }
          },
        );
      },
    );
  }
}
