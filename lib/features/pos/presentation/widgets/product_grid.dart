import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../providers/pos_provider.dart';

import './modifier_dialog.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final products = state.filteredProducts;
    final bool isDesktop = Device.width > 1000;

    return Column(
      children: [
        // Search & Filter Bar
        Padding(
          padding: EdgeInsets.all(isDesktop ? 1.w : 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => ref
                      .read(posNotifierProvider.notifier)
                      .setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Product Grid
        Expanded(
          child: state.isLoading
              ? _buildSkeletonGrid()
              : products.isEmpty
              ? _buildEmptyState()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = _getCrossAxisCount(
                      constraints.maxWidth,
                    );
                    // Adjust aspect ratio based on item width to keep cards proportional
                    final aspectRatio = isDesktop ? 0.8 : 0.75;

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: products[index]);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 6;
    if (width > 900) return 4;
    if (width > 600) return 3;
    if (width > 400) return 2;
    return 1;
  }

  Widget _buildSkeletonGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 8,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends ConsumerWidget {
  final MenuItemEntity product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAvailable = product.isAvailable;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.6,
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        child: InkWell(
          onTap: isAvailable
              ? () => ref.read(posNotifierProvider.notifier).addToCart(product)
              : null,
          onLongPress: isAvailable
              ? () => showDialog(
                  context: context,
                  builder: (context) => ModifierDialog(product: product),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Expanded(
                flex: 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primaryContainer.withOpacity(0.3),
                        child: Icon(
                          Icons.restaurant,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                    if (!isAvailable)
                      Container(
                        color: Colors.black45,
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'UNAVAILABLE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Info Section
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          product.name,
                          maxLines: 2,
                          minFontSize: 11,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              '\$${product.price.toStringAsFixed(2)}',
                              maxLines: 1,
                              minFontSize: 12,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (isAvailable)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
