# Menu Feature Components

This directory contains reusable UI components for the menu feature.

## Components

### 1. **UserHeaderCard** (`user_header_card.dart`)
Displays user information and logout button at the top of the menu page.

**Props:**
- `user`: User? - Current user information
- `onLogout`: VoidCallback - Callback for logout action

---

### 2. **MenuHeader** (`menu_header.dart`)
Displays the "Today's Menu" header with gradient styling.

**Features:**
- Gradient background
- Restaurant icon
- Title and subtitle

---

### 3. **CategoryChips** (`category_chips.dart`)
Horizontally scrollable category filter chips.

**Props:**
- `categories`: List<CategoryEntity> - List of categories to display
- `selectedCategoryId`: String? - Currently selected category ID
- `onCategorySelected`: Function(String?) - Callback when category is selected

**Features:**
- Horizontal scrolling with BouncingScrollPhysics
- "All" option to show all items
- Visual feedback for selected category
- Sorted by display order

---

### 4. **MenuItemCard** (`menu_item_card.dart`)
Expandable card displaying menu item details.

**Props:**
- `item`: MenuItemEntity - Menu item to display
- `onAddToCart`: VoidCallback? - Callback for add to cart action

**Features:**
- Expandable to show customization options and allergens
- Smooth animations using AnimationController
- Displays:
  - Item image (with fallback icon)
  - Name and description
  - Rating and preparation time
  - Price (including customizations)
  - Availability status
  - Customization options (when expanded)
  - Allergens (when expanded)
- Disabled state for unavailable items

---

### 5. **CustomBottomNavigationBar** (`custom_bottom_navigation_bar.dart`)
Bottom navigation bar with animated selection states.

**Props:**
- `currentIndex`: int - Currently selected tab index
- `onTap`: Function(int) - Callback when tab is tapped

**Features:**
- 4 navigation items: Menu, Cart, Orders, Profile
- Animated gradient highlight for active tab
- Smooth transitions

---

## Usage Example

```dart
import 'package:flutter/material.dart';
import '../widgets/user_header_card.dart';
import '../widgets/menu_header.dart';
import '../widgets/category_chips.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class MenuPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          UserHeaderCard(
            user: currentUser,
            onLogout: _handleLogout,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MenuHeader(),
                  CategoryChips(
                    categories: categories,
                    selectedCategoryId: selectedCategoryId,
                    onCategorySelected: _handleCategorySelected,
                  ),
                  // Menu items
                  ...items.map((item) => MenuItemCard(
                    item: item,
                    onAddToCart: () => _handleAddToCart(item),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }
}
```

## State Management

The menu page uses:
- **Local State** for UI interactions (category filtering, bottom nav selection, card expansion)
- **Riverpod** for menu data management (MenuNotifier)

## Filtering Logic

Category filtering is implemented in the MenuPage:

```dart
List<MenuItemEntity> _filterItemsByCategory(
  List<MenuItemEntity> items,
  String? categoryId,
) {
  if (categoryId == null) {
    return items; // Show all items
  }
  return items.where((item) => item.category.id == categoryId).toList();
}
```

## Animations

- **MenuItemCard**: Uses `AnimationController` with `SizeTransition` for smooth expand/collapse
- **CustomBottomNavigationBar**: Uses `AnimatedContainer` for tab selection transitions
- **CategoryChips**: Uses `FilterChip` with built-in selection animations

## Styling

All components use the centralized `AppColors` theme for consistency:
- Primary gradient for highlights
- Consistent shadows and borders
- Semantic colors for status indicators
