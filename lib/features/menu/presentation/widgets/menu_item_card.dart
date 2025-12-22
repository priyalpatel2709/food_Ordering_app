import 'package:flutter/material.dart';
import '../../domain/entities/menu_entity.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../../shared/theme/app_colors.dart';

class MenuItemCard extends StatefulWidget {
  final MenuItemEntity item;
  final Function(List<CustomizationSelection>)? onAddToCart;
  final Function()? onIncrement;
  final Function()? onDecrement;
  final int? currentQuantity;
  final bool hasItemInCart;

  const MenuItemCard({
    super.key,
    required this.item,
    this.onAddToCart,
    this.onIncrement,
    this.onDecrement,
    this.currentQuantity,
    this.hasItemInCart = false,
  });

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  // Track selected customizations (start empty - no defaults)
  final Set<String> _selectedCustomizationIds = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Don't pre-select any customizations
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _toggleCustomization(String customizationId) {
    setState(() {
      if (_selectedCustomizationIds.contains(customizationId)) {
        _selectedCustomizationIds.remove(customizationId);
      } else {
        _selectedCustomizationIds.add(customizationId);
      }
    });
  }

  double _calculateTotalPrice() {
    double total = widget.item.price;
    for (var option in widget.item.customizationOptions) {
      if (_selectedCustomizationIds.contains(option.id)) {
        total += option.price;
      }
    }
    return total;
  }

  List<CustomizationSelection> _getSelectedCustomizations() {
    return widget.item.customizationOptions
        .where((option) => _selectedCustomizationIds.contains(option.id))
        .map(
          (option) => CustomizationSelection(
            id: option.id,
            name: option.name,
            price: option.price,
          ),
        )
        .toList();
  }

  void _handleAddToCart() {
    if (widget.onAddToCart != null) {
      widget.onAddToCart!(_getSelectedCustomizations());
    }
  }

  void _handleRepeatItem() {
    // Add same item with same customizations (increment existing)
    if (widget.onIncrement != null) {
      widget.onIncrement!();
    }
  }

  void _handleAddNew() {
    // Add item with currently selected customizations
    _handleAddToCart();
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();
    final hasCustomizations = widget.item.customizationOptions.isNotEmpty;
    final hasSelectedCustomizations = _selectedCustomizationIds.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: hasCustomizations ? _toggleExpand : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                      image: widget.item.image.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.item.image),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.item.image.isEmpty
                        ? const Icon(
                            Icons.restaurant,
                            size: 40,
                            color: AppColors.grey400,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Item Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!widget.item.isAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Unavailable',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.item.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.item.preparationTime} min',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\$${totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (_selectedCustomizationIds.isNotEmpty)
                                  Text(
                                    'Base: \$${widget.item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                            _buildActionButtons(
                              hasCustomizations,
                              hasSelectedCustomizations,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable section for customization options
          if (hasCustomizations)
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Customization Options',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.item.customizationOptions.map((option) {
                      final isSelected = _selectedCustomizationIds.contains(
                        option.id,
                      );
                      return InkWell(
                        onTap: () => _toggleCustomization(option.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.grey50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.grey200,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: 20,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.grey400,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    option.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '+\$${option.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (widget.item.allergens.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Allergens',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: widget.item.allergens
                            .map(
                              (allergen) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  allergen,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    // Action buttons when expanded
                    if (widget.hasItemInCart && hasSelectedCustomizations) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.item.isAvailable
                                  ? _handleRepeatItem
                                  : null,
                              icon: const Icon(Icons.repeat, size: 16),
                              label: const Text('Repeat'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.item.isAvailable
                                  ? _handleAddNew
                                  : null,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add New'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    bool hasCustomizations,
    bool hasSelectedCustomizations,
  ) {
    // If item is in cart and has no customizations, show quantity controls
    if (widget.hasItemInCart && !hasCustomizations) {
      return _buildQuantityControls();
    }

    // If item is in cart and has customizations but none selected, show quantity controls
    if (widget.hasItemInCart &&
        hasCustomizations &&
        !hasSelectedCustomizations &&
        !_isExpanded) {
      return Row(
        children: [
          if (hasCustomizations)
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.expand_more,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          const SizedBox(width: 8),
          _buildQuantityControls(),
        ],
      );
    }

    // Otherwise show add button with expand icon
    return Row(
      children: [
        if (hasCustomizations)
          AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(Icons.expand_more, color: AppColors.primary, size: 24),
          ),
        const SizedBox(width: 8),
        InkWell(
          onTap: widget.item.isAvailable ? _handleAddToCart : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: widget.item.isAvailable
                  ? AppColors.primaryGradient
                  : null,
              color: widget.item.isAvailable ? null : AppColors.grey300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_shopping_cart,
                  size: 16,
                  color: widget.item.isAvailable
                      ? AppColors.white
                      : AppColors.grey600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.item.isAvailable
                        ? AppColors.white
                        : AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(8),
        gradient: AppColors.primaryGradient,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: widget.onDecrement,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              bottomLeft: Radius.circular(6),
            ),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.remove, size: 16, color: AppColors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${widget.currentQuantity ?? 0}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          InkWell(
            onTap: widget.onIncrement,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.add, size: 16, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
