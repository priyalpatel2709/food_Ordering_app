import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../providers/pos_provider.dart';
import '../../../../features/settings/presentation/providers/settings_provider.dart';
import './modifier_dialog.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final products = state.filteredProducts;
    final bool isDesktop = Device.width > 1000;

    return Column(
      children: [
        // Search & Filter Bar
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 1.w : 2.w,
            vertical: settings.compactLayout ? 1.h : 2.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => ref
                      .read(posNotifierProvider.notifier)
                      .setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20.px,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.px),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.px),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.px),
                  border: Border.all(color: AppColors.border),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.filter_list, size: 20.px),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Product Grid
        Expanded(
          child: state.isLoading
              ? _buildSkeletonGrid(settings.compactLayout)
              : products.isEmpty
              ? _buildEmptyState()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = _getCrossAxisCount(
                      constraints.maxWidth,
                    );

                    if (settings.compactLayout) {
                      crossAxisCount += (isDesktop ? 2 : 1);
                    }

                    // Adjust aspect ratio based on screen and settings
                    double aspectRatio = isDesktop ? 0.82 : 0.78;

                    if (settings.compactLayout) {
                      // Make cards slightly taller in compact mode to fit text
                      aspectRatio = isDesktop ? 0.75 : 0.72;
                    }

                    if (!settings.showItemImages) {
                      aspectRatio = settings.compactLayout ? 1.6 : 1.4;
                    }

                    return GridView.builder(
                      // padding: EdgeInsets.symmetric(horizontal: 2.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product: products[index],
                          showImage: settings.showItemImages,
                          isCompact: settings.compactLayout,
                        );
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

  Widget _buildSkeletonGrid(bool isCompact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        if (isCompact) crossAxisCount += 2;

        return GridView.builder(
          padding: EdgeInsets.all(2.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.8,
            crossAxisSpacing: isCompact ? 1.w : 2.w,
            mainAxisSpacing: isCompact ? 1.h : 2.h,
          ),
          itemCount: 8,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(16.px),
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
          Icon(Icons.restaurant_menu, size: 60.px, color: AppColors.grey300),
          SizedBox(height: 2.h),
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
  final bool showImage;
  final bool isCompact;

  const ProductCard({
    super.key,
    required this.product,
    this.showImage = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAvailable = product.isAvailable;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.6,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.px),
          side: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Stack(
          children: [
            InkWell(
              onTap: isAvailable
                  ? () {
                      if (product.customizationOptions.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              ModifierDialog(product: product),
                        );
                      } else {
                        ref
                            .read(posNotifierProvider.notifier)
                            .addToCart(product);
                      }
                    }
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Section
                  if (showImage)
                    Expanded(
                      flex: isCompact ? 3 : 4,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primaryContainer.withOpacity(
                                0.3,
                              ),
                              child: Icon(
                                Icons.restaurant,
                                color: AppColors.primary,
                                size: 24.px,
                              ),
                            ),
                          ),
                          if (product.customizationOptions.isNotEmpty)
                            Positioned(
                              top: 4.px,
                              right: 4.px,
                              child: Container(
                                padding: EdgeInsets.all(4.px),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4.px,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.tune,
                                  size: 10.px,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          if (!isAvailable)
                            Container(
                              color: Colors.black45,
                              alignment: Alignment.center,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.px,
                                  vertical: 4.px,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(4.px),
                                ),
                                child: Text(
                                  'UNAVAILABLE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.px,
                        vertical: isCompact ? 4.px : 8.px,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              product.name,
                              maxLines: 2,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.px),
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
                              // SizedBox(
                              // width: isCompact ? 20.px : 32.px,
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Direct Add Button (Quick Add)
            if (isAvailable)
              Positioned(
                bottom: isCompact ? 4.px : 8.px,
                right: isCompact ? 4.px : 8.px,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.px),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  child: InkWell(
                    onTap: () {
                      ref.read(posNotifierProvider.notifier).addToCart(product);
                      // ScaffoldMessenger.of(context).clearSnackBars();
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text('${product.name} added to cart'),
                      //     duration: const Duration(milliseconds: 500),
                      //     backgroundColor: Colors.black87,
                      //     behavior: SnackBarBehavior.floating,
                      //     width: 40.w,
                      //   ),
                      // );
                    },
                    borderRadius: BorderRadius.circular(
                      isCompact ? 8.px : 12.px,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(isCompact ? 4.px : 8.px),
                      child: Icon(
                        Icons.add,
                        size: isCompact ? 14.px : 18.px,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
