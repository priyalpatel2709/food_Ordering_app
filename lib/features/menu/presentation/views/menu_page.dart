import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
        title: Text('Logout', style: TextStyle(fontSize: 18.sp)),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16.sp),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(fontSize: 15.sp)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Logout', style: TextStyle(fontSize: 15.sp)),
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
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      color: AppColors.primary.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.table_restaurant, color: AppColors.primary, size: 5.w),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'Ordering for Table ${session.tableNumber}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 15.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(dineInSessionProvider.notifier).state = null;
            },
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
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
    final bool isDesktop = Device.width > 900;

    return Scaffold(
      appBar: canPop
          ? AppBar(
              title: Text(
                'Select Items',
                style: TextStyle(fontSize: isDesktop ? 14.sp : 18.sp),
              ),
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: isDesktop ? 1.5.w : 6.w,
                ),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart,
                    color: AppColors.primary,
                    size: isDesktop ? 1.5.w : 6.w,
                  ),
                  onPressed: () => context.push(RouteConstants.cart),
                ),
                SizedBox(width: isDesktop ? 1.w : 0),
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
    final bool isDesktop = Device.width > 900;
    return switch (state) {
      MenuInitial() => Center(
        child: Text('Initializing...', style: TextStyle(fontSize: 16.sp)),
      ),
      MenuLoading() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 2.h),
            Text(
              'Loading menu...',
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      MenuError(:final message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 15.w, color: AppColors.error),
            SizedBox(height: 2.h),
            Text(
              message,
              style: TextStyle(fontSize: 16.sp, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(menuNotifierProvider.notifier).refreshCurrentMenu(),
              icon: Icon(Icons.refresh, size: 5.w),
              label: Text('Retry', style: TextStyle(fontSize: 15.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              ),
            ),
          ],
        ),
      ),
      MenuLoaded(:final menus) =>
        menus.isEmpty
            ? Center(
                child: Text(
                  'No menu available',
                  style: TextStyle(
                    fontSize: isDesktop ? 13.sp : 16.sp,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 3.w : 5.w,
                    vertical: 2.h,
                  ),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 90.w : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...menus.map((menu) => _buildMenuSection(menu)),
                        ],
                      ),
                    ),
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

    final bool isDesktop = Device.width > 900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                menu.name,
                style: TextStyle(
                  fontSize: isDesktop ? 16.sp : 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                menu.description,
                style: TextStyle(
                  fontSize: isDesktop ? 11.sp : 14.sp,
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
        SizedBox(height: 2.h),
        _buildMenuItems(filteredItems),
        SizedBox(height: 3.h),
      ],
    );
  }

  Widget _buildMenuItems(List<MenuItemEntity> items) {
    final bool isDesktop = Device.width > 900;
    final bool isTablet = Device.width > 600 && Device.width <= 900;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 5.w : 40),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: isDesktop ? 5.w : 64,
                color: AppColors.grey400,
              ),
              SizedBox(height: 2.h),
              Text(
                'No items found in this category',
                style: TextStyle(
                  fontSize: isDesktop ? 11.sp : 14.sp,
                  color: AppColors.textSecondary,
                ),
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
        crossAxisSpacing: isDesktop ? 1.5.w : 0,
        mainAxisSpacing: isDesktop ? 1.5.w : 0,
        mainAxisExtent: isDesktop ? 42.h : null,
      ),
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
