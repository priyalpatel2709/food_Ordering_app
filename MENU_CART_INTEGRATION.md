# Menu Item Cart Integration - Update Summary

## New Features Implemented

### ✅ 1. Quantity Controls on Menu Page
When an item is already in the cart (without customizations), the menu item card now shows **quantity controls** instead of the "Add" button.

**Visual:**
```
┌─────────────────────────────────────┐
│ ┌────┐  Burger                      │
│ │IMG │  Delicious burger...         │
│ │    │  ⭐ 4.5  ⏱️ 15 min           │
│ └────┘  $12.99    [-] 2 [+]         │
└─────────────────────────────────────┘
```

**Behavior:**
- **[+] button**: Increments quantity in cart
- **[-] button**: Decrements quantity (removes if quantity becomes 0)
- **Number**: Shows current quantity in cart

---

### ✅ 2. No Default Addons
Customization options are **no longer pre-selected** by default.

**Before:**
- Active addons were automatically selected when card expanded

**After:**
- All addons start unselected
- User must explicitly select desired addons

---

### ✅ 3. Repeat vs Add New for Items with Customizations

When an item with customizations is already in cart and user selects new customizations, two options appear:

**"Repeat" Button:**
- Increments quantity of existing cart item (same customizations)
- Ignores currently selected customizations in the expanded view

**"Add New" Button:**
- Adds a new cart item with currently selected customizations
- Creates separate cart entry

**Visual:**
```
┌─────────────────────────────────────┐
│ Customization Options               │
│ ☑ Extra Cheese      +$2.00          │
│ ☑ Bacon             +$3.00          │
│                                     │
│ [Repeat]          [Add New]         │
└─────────────────────────────────────┘
```

---

## How It Works

### Scenario 1: Item Without Customizations

**First Add:**
```
User taps "Add" button
  ↓
Item added to cart with quantity = 1
  ↓
Button changes to quantity controls [-] 1 [+]
```

**Increment:**
```
User taps [+]
  ↓
Quantity increases to 2
  ↓
Controls show [-] 2 [+]
```

**Decrement:**
```
User taps [-]
  ↓
Quantity decreases to 1
  ↓
If quantity becomes 0, item removed and button changes back to "Add"
```

---

### Scenario 2: Item With Customizations (Not in Cart)

**User Flow:**
```
User taps item to expand
  ↓
User selects customizations (e.g., Extra Cheese, Bacon)
  ↓
Price updates: $12.99 → $17.99
  ↓
User taps "Add" button
  ↓
Item added to cart with selected customizations
  ↓
Button remains "Add" (for adding with different customizations)
```

---

### Scenario 3: Item With Customizations (Already in Cart)

**Case A: No customizations selected in expanded view**
```
Item in cart: Burger (no addons) × 1
  ↓
User sees quantity controls [-] 1 [+]
  ↓
User can increment/decrement without expanding
```

**Case B: User selects customizations**
```
Item in cart: Burger (no addons) × 1
  ↓
User expands item and selects Extra Cheese
  ↓
Two buttons appear:
  - [Repeat]: Increment existing item (no addons)
  - [Add New]: Add new item with Extra Cheese
```

---

## Code Changes

### MenuItemCard Updates

**New Properties:**
```dart
final Function()? onIncrement;
final Function()? onDecrement;
final int? currentQuantity;
final bool hasItemInCart;
```

**Removed:**
- Pre-selection of active customizations in `initState()`

**Added:**
- `_buildQuantityControls()` - Renders [-] [number] [+] controls
- `_handleRepeatItem()` - Calls `onIncrement` to repeat existing item
- `_handleAddNew()` - Adds new item with selected customizations
- Smart button logic in `_buildActionButtons()`

---

### MenuPage Updates

**Cart State Watching:**
```dart
final cartState = ref.watch(cartNotifierProvider);
final cartItems = cartState is CartLoaded ? cartState.items : <CartItemEntity>[];
```

**Cart Item Lookup:**
```dart
// Find if this item is in cart (without customizations)
final cartItemWithoutCustomizations = cartItems.firstWhere(
  (cartItem) =>
      cartItem.menuItemId == menuItem.id &&
      cartItem.selectedCustomizations.isEmpty,
  orElse: () => CartItemEntity(...), // Empty placeholder
);
```

**Callbacks:**
```dart
onIncrement: () {
  if (hasItemInCart) {
    ref.read(cartNotifierProvider.notifier)
        .incrementQuantity(cartItemWithoutCustomizations.id);
  } else {
    ref.read(cartNotifierProvider.notifier).addItem(
      menuItemId: menuItem.id,
      // ... with no customizations
    );
  }
},

onDecrement: () {
  if (hasItemInCart) {
    ref.read(cartNotifierProvider.notifier)
        .decrementQuantity(cartItemWithoutCustomizations.id);
  }
},
```

---

## User Experience Improvements

### 1. **Faster Ordering**
- Users can quickly adjust quantities without opening cart
- No need to navigate to cart page for simple quantity changes

### 2. **Clear Intent**
- "Repeat" vs "Add New" makes it clear what will happen
- No confusion about whether customizations will be added to existing item or create new one

### 3. **No Accidental Addons**
- Users won't accidentally add unwanted customizations
- Explicit selection required

### 4. **Visual Feedback**
- Quantity controls clearly show item is in cart
- Real-time quantity display

---

## Edge Cases Handled

### 1. **Item with customizations in cart, user adds without customizations**
- Creates separate cart item (one with customizations, one without)

### 2. **User decrements to 0**
- Item removed from cart
- Button changes back to "Add"

### 3. **Item unavailable**
- All buttons disabled
- "Unavailable" badge shown

### 4. **Multiple items with different customizations**
- Each combination tracked separately
- Quantity controls only affect base item (no customizations)

---

## Testing Checklist

- [ ] Add item without customizations
- [ ] Increment quantity from menu page
- [ ] Decrement quantity from menu page
- [ ] Decrement to 0 removes item
- [ ] Button changes to "Add" after removal
- [ ] Expand item with customizations
- [ ] No customizations pre-selected
- [ ] Select customizations and tap "Add"
- [ ] Item in cart, select different customizations
- [ ] "Repeat" button increments existing item
- [ ] "Add New" button creates new cart item
- [ ] Quantity controls show correct count
- [ ] Cart badge updates correctly
- [ ] Unavailable items disabled

---

## Visual States

### State 1: Not in Cart
```
[Add] button visible
```

### State 2: In Cart (No Customizations)
```
[-] 2 [+] controls visible
```

### State 3: In Cart + Expanded + No Selection
```
▼ (expand icon) + [-] 2 [+] controls
```

### State 4: In Cart + Expanded + Customizations Selected
```
[Repeat] [Add New] buttons visible
(in expanded section)
```

---

## Summary

The menu page now provides a **seamless cart integration** with:
- ✅ Inline quantity controls
- ✅ No default addon selection
- ✅ Clear "Repeat" vs "Add New" options
- ✅ Real-time cart state synchronization
- ✅ Intuitive user experience

Users can now manage their cart directly from the menu page without constant navigation!
