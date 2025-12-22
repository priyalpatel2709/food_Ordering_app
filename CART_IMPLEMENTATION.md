# Add to Cart Functionality - Implementation Guide

## Overview
Complete implementation of add-to-cart functionality with customization options, cart management, and cart page.

---

## Features Implemented

### ✅ 1. Customization Selection
- **Interactive checkboxes** for customization options
- **Dynamic price calculation** based on selected add-ons
- **Visual feedback** for selected options
- **Real-time price updates** as options are toggled

### ✅ 2. Cart State Management
- **Riverpod state management** for cart
- **Add items** with selected customizations
- **Update quantities** (increment/decrement)
- **Remove items** from cart
- **Clear entire cart**
- **Unique item identification** based on item + customizations

### ✅ 3. Cart Page
- **List of cart items** with details
- **Quantity controls** (+/- buttons)
- **Remove item** button
- **Order summary** (subtotal, tax, delivery fee, total)
- **Checkout button**
- **Empty cart state** with "Browse Menu" button
- **Clear cart** confirmation dialog

### ✅ 4. Cart Badge
- **Item count badge** on cart tab in bottom navigation
- **Real-time updates** when items are added/removed
- **Visual indicator** (red circle with count)

---

## File Structure

```
lib/features/cart/
├── domain/
│   └── entities/
│       └── cart_entity.dart          # Cart entities (CartItemEntity, CustomizationSelection, CartSummary)
├── presentation/
│   ├── pages/
│   │   └── cart_page.dart            # Main cart page
│   ├── providers/
│   │   └── cart_provider.dart        # Cart state management (CartNotifier)
│   └── widgets/
│       ├── cart_item_card.dart       # Individual cart item widget
│       ├── cart_summary_card.dart    # Order summary widget
│       └── empty_cart_widget.dart    # Empty state widget
```

---

## How It Works

### 1. Adding Items to Cart

**Flow:**
```
User expands menu item card
  ↓
User selects customization options (checkboxes)
  ↓
Price updates dynamically
  ↓
User taps "Add" button
  ↓
MenuItemCard.onAddToCart(selectedCustomizations) called
  ↓
CartNotifier.addItem() called with:
  - menuItemId
  - menuItemName
  - menuItemImage
  - basePrice
  - selectedCustomizations
  ↓
CartNotifier generates unique ID:
  - Based on menuItemId + customization IDs
  - Same item with different customizations = different cart items
  ↓
If item with same customizations exists:
  - Increment quantity
Else:
  - Add new cart item with quantity = 1
  ↓
Cart state updates
  ↓
SnackBar shows confirmation with "View Cart" action
```

**Code Example:**
```dart
// In menu_page.dart
MenuItemCard(
  item: menuItem,
  onAddToCart: (selectedCustomizations) {
    ref.read(cartNotifierProvider.notifier).addItem(
      menuItemId: menuItem.id,
      menuItemName: menuItem.name,
      menuItemImage: menuItem.image,
      basePrice: menuItem.price,
      selectedCustomizations: selectedCustomizations,
    );
  },
)
```

---

### 2. Customization Selection

**MenuItemCard State:**
```dart
// Track selected customizations
final Set<String> _selectedCustomizationIds = {};

// Pre-select active customizations
@override
void initState() {
  for (var option in widget.item.customizationOptions) {
    if (option.isActive) {
      _selectedCustomizationIds.add(option.id);
    }
  }
}

// Toggle customization
void _toggleCustomization(String customizationId) {
  setState(() {
    if (_selectedCustomizationIds.contains(customizationId)) {
      _selectedCustomizationIds.remove(customizationId);
    } else {
      _selectedCustomizationIds.add(customizationId);
    }
  });
}

// Calculate total price
double _calculateTotalPrice() {
  double total = widget.item.price;
  for (var option in widget.item.customizationOptions) {
    if (_selectedCustomizationIds.contains(option.id)) {
      total += option.price;
    }
  }
  return total;
}
```

---

### 3. Cart State Management

**CartNotifier Methods:**

```dart
// Add item to cart
void addItem({
  required String menuItemId,
  required String menuItemName,
  required String menuItemImage,
  required double basePrice,
  required List<CustomizationSelection> selectedCustomizations,
})

// Update quantity
void updateQuantity(String cartItemId, int newQuantity)

// Increment quantity
void incrementQuantity(String cartItemId)

// Decrement quantity (removes if quantity becomes 0)
void decrementQuantity(String cartItemId)

// Remove item
void removeItem(String cartItemId)

// Clear cart
void clearCart()
```

**Cart States:**
```dart
sealed class CartState {}

class CartEmpty extends CartState {}

class CartLoaded extends CartState {
  final CartSummary summary;
  List<CartItemEntity> get items => summary.items;
}
```

---

### 4. Price Calculations

**Per Item:**
```dart
// Base price + customizations
double get pricePerItem {
  final customizationTotal = selectedCustomizations.fold<double>(
    0,
    (sum, customization) => sum + customization.price,
  );
  return basePrice + customizationTotal;
}

// Total for this cart item (price * quantity)
double get totalPrice {
  return pricePerItem * quantity;
}
```

**Cart Summary:**
```dart
factory CartSummary.fromItems(List<CartItemEntity> items) {
  final subtotal = items.fold<double>(
    0,
    (sum, item) => sum + item.totalPrice,
  );
  final tax = subtotal * 0.1; // 10% tax
  final deliveryFee = subtotal > 0 ? 5.0 : 0.0; // $5 delivery fee
  final total = subtotal + tax + deliveryFee;
  
  return CartSummary(
    items: items,
    subtotal: subtotal,
    tax: tax,
    deliveryFee: deliveryFee,
    total: total,
    totalItems: items.fold(0, (sum, item) => sum + item.quantity),
  );
}
```

---

## UI Components

### MenuItemCard (Updated)

**Features:**
- Expandable to show customization options
- Interactive checkboxes for customizations
- Dynamic price display (base + selected customizations)
- "Add" button with customization callback

**Visual States:**
- **Collapsed:** Shows basic info + price + expand icon
- **Expanded:** Shows customizations + allergens
- **Customization Selected:** Highlighted with primary color border
- **Customization Unselected:** Gray border

---

### CartItemCard

**Features:**
- Item image, name, and customizations
- Quantity controls (+/- buttons)
- Remove button (X icon)
- Price display (total and per-item)

**Layout:**
```
┌─────────────────────────────────────┐
│ ┌────┐  Burger Deluxe            X  │
│ │IMG │  + Extra Cheese (+$2.00)     │
│ │    │  + Bacon (+$3.00)            │
│ └────┘                               │
│        [-] 2 [+]        $34.00      │
│                         $17.00 each │
└─────────────────────────────────────┘
```

---

### CartSummaryCard

**Features:**
- Subtotal
- Tax (10%)
- Delivery Fee ($5.00)
- Total (bold, primary color)

**Layout:**
```
┌─────────────────────────────────────┐
│ Order Summary                       │
│                                     │
│ Subtotal              $30.00        │
│ Tax (10%)              $3.00        │
│ Delivery Fee           $5.00        │
│ ─────────────────────────────────   │
│ Total                 $38.00        │
└─────────────────────────────────────┘
```

---

### EmptyCartWidget

**Features:**
- Large cart icon
- "Your cart is empty" message
- "Browse Menu" button (navigates back)

---

## Navigation

### Cart Route
- **Path:** `/cart`
- **Name:** `cart`
- **Transition:** Slide up from bottom
- **Access:** Bottom navigation "Cart" tab or SnackBar "View Cart" action

### Bottom Navigation Badge
- Shows cart item count
- Red circle badge
- Updates in real-time
- Shows "99+" for counts > 99

---

## User Flows

### Flow 1: Add Item with Customizations
1. User browses menu
2. User taps menu item card to expand
3. User selects customization options (checkboxes)
4. Price updates dynamically
5. User taps "Add" button
6. SnackBar appears: "[Item name] added to cart!" with "View Cart" action
7. Cart badge updates with new count

### Flow 2: View Cart
1. User taps "View Cart" in SnackBar OR taps Cart tab in bottom nav
2. Cart page slides up from bottom
3. User sees list of cart items with customizations
4. User sees order summary at bottom

### Flow 3: Update Quantity
1. User taps "+" to increment quantity
2. Item quantity increases
3. Price updates (total and per-item)
4. Order summary updates

### Flow 4: Remove Item
1. User taps "X" button on cart item
2. Item removed from cart
3. SnackBar appears: "[Item name] removed from cart"
4. Order summary updates
5. If cart becomes empty, shows empty state

### Flow 5: Clear Cart
1. User taps trash icon in app bar
2. Confirmation dialog appears
3. User confirms
4. All items removed
5. Empty state shown
6. SnackBar appears: "Cart cleared"

---

## Testing Checklist

- [ ] Add item without customizations
- [ ] Add item with customizations
- [ ] Add same item with different customizations (should create separate cart items)
- [ ] Add same item with same customizations (should increment quantity)
- [ ] Price updates when selecting/deselecting customizations
- [ ] Cart badge shows correct count
- [ ] Cart badge updates when items added/removed
- [ ] Increment quantity in cart
- [ ] Decrement quantity in cart
- [ ] Decrement quantity to 0 removes item
- [ ] Remove item with X button
- [ ] Clear cart (with confirmation)
- [ ] Empty cart state shows correctly
- [ ] "Browse Menu" button navigates back
- [ ] Order summary calculates correctly
- [ ] Tax calculation (10%)
- [ ] Delivery fee ($5.00)
- [ ] Total calculation
- [ ] SnackBar shows on add to cart
- [ ] "View Cart" action in SnackBar works
- [ ] Cart page navigation from bottom nav
- [ ] Back button works on cart page

---

## Future Enhancements

1. **Persistent Cart**
   - Save cart to local storage (Hive/Drift)
   - Restore cart on app restart

2. **Cart Sync**
   - Sync cart with backend
   - Multi-device cart sync

3. **Checkout Flow**
   - Delivery address selection
   - Payment method selection
   - Order confirmation
   - Order tracking

4. **Promo Codes**
   - Apply discount codes
   - Calculate discounts
   - Show savings

5. **Delivery Time**
   - Select delivery time slot
   - Estimated delivery time
   - Track delivery

6. **Favorites**
   - Save favorite customizations
   - Quick add from favorites

7. **Order Notes**
   - Add special instructions
   - Dietary preferences

---

## Technical Notes

### Unique Cart Item ID
```dart
// Generate unique ID based on item and customizations
final customizationIds = selectedCustomizations
    .map((c) => c.id)
    .toList()
  ..sort();
final uniqueId = '$menuItemId-${customizationIds.join("-")}';
```

This ensures:
- Same item with different customizations = different cart items
- Same item with same customizations = increment quantity

### State Management
- **CartNotifier:** Manages cart items and operations
- **cartNotifierProvider:** Provides cart state
- **cartItemCountProvider:** Computed provider for item count

### Performance
- Efficient state updates with `StateNotifier`
- Minimal rebuilds with Riverpod providers
- Lazy loading with `ListView.builder`

---

## API Integration (Future)

When backend is ready, update CartNotifier to:

```dart
// Add item to cart (with API call)
Future<void> addItem(...) async {
  // Add to local state immediately
  _items.add(newItem);
  _updateState();
  
  // Sync with backend
  try {
    await cartRepository.addItem(newItem);
  } catch (e) {
    // Rollback on error
    _items.remove(newItem);
    _updateState();
    // Show error
  }
}
```

---

## Summary

The add-to-cart functionality is now complete with:
- ✅ Customization selection
- ✅ Dynamic price calculation
- ✅ Cart state management
- ✅ Cart page with full CRUD operations
- ✅ Cart badge on bottom navigation
- ✅ Empty state handling
- ✅ User-friendly confirmations and feedback

All components are well-organized, reusable, and follow Flutter best practices!
