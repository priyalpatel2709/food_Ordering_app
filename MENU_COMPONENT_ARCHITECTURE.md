# Menu Page Component Architecture

## Component Hierarchy

```
MenuPage (StatefulWidget)
│
├── Scaffold
│   │
│   ├── body: Container (with gradient background)
│   │   │
│   │   └── SafeArea
│   │       │
│   │       └── Column
│   │           │
│   │           ├── UserHeaderCard ← NEW COMPONENT
│   │           │   ├── User avatar (gradient circle)
│   │           │   ├── Welcome message
│   │           │   ├── User name
│   │           │   └── Logout button
│   │           │
│   │           └── Expanded
│   │               │
│   │               └── _buildContent() → MenuState switch
│   │                   │
│   │                   ├── MenuLoading → CircularProgressIndicator
│   │                   ├── MenuError → Error message + Retry button
│   │                   └── MenuLoaded → RefreshIndicator
│   │                       │
│   │                       └── SingleChildScrollView
│   │                           │
│   │                           └── Column
│   │                               │
│   │                               ├── MenuHeader ← NEW COMPONENT
│   │                               │   ├── Restaurant icon
│   │                               │   ├── "Today's Menu" title
│   │                               │   └── "Fresh & Delicious" subtitle
│   │                               │
│   │                               └── For each menu:
│   │                                   │
│   │                                   ├── Menu name & description
│   │                                   │
│   │                                   ├── CategoryChips ← NEW COMPONENT
│   │                                   │   ├── "All" chip (FilterChip)
│   │                                   │   └── Category chips (FilterChip)
│   │                                   │       ├── Horizontal scroll
│   │                                   │       ├── Click to filter
│   │                                   │       └── Visual selection
│   │                                   │
│   │                                   └── _buildMenuItems()
│   │                                       │
│   │                                       └── ListView.builder
│   │                                           │
│   │                                           └── MenuItemCard ← NEW COMPONENT
│   │                                               │
│   │                                               ├── InkWell (tap to expand)
│   │                                               │   │
│   │                                               │   └── Row
│   │                                               │       ├── Item image
│   │                                               │       └── Column
│   │                                               │           ├── Name + Availability badge
│   │                                               │           ├── Description
│   │                                               │           ├── Rating + Prep time
│   │                                               │           └── Price + Add button + Expand icon
│   │                                               │
│   │                                               └── SizeTransition (expandable)
│   │                                                   │
│   │                                                   └── Column
│   │                                                       ├── Customization options
│   │                                                       │   └── List of options with prices
│   │                                                       └── Allergens
│   │                                                           └── Wrap of allergen chips
│   │
│   └── bottomNavigationBar: CustomBottomNavigationBar ← NEW COMPONENT
│       │
│       └── Row (4 navigation items)
│           ├── Menu (selected with gradient)
│           ├── Cart (placeholder)
│           ├── Orders (placeholder)
│           └── Profile (placeholder)
```

---

## State Flow

### Local State (MenuPage)
```
_currentUser: User?
  ↓
  Used by: UserHeaderCard

_selectedCategoryId: String?
  ↓
  Used by: CategoryChips (visual selection)
  ↓
  Used by: _filterItemsByCategory() (filtering logic)
  ↓
  Affects: MenuItemCard list

_currentBottomNavIndex: int
  ↓
  Used by: CustomBottomNavigationBar (visual selection)
  ↓
  Triggers: _handleBottomNavTap() (navigation)
```

### Riverpod State (MenuNotifier)
```
MenuState (sealed class)
  ├── MenuInitial
  ├── MenuLoading
  ├── MenuError(message)
  └── MenuLoaded(menus)
      ↓
      Used by: _buildContent() switch expression
      ↓
      Renders: Appropriate UI for each state
```

---

## Data Flow

### Category Filtering
```
User taps category chip
  ↓
CategoryChips.onCategorySelected(categoryId)
  ↓
_handleCategorySelected(categoryId)
  ↓
setState(() { _selectedCategoryId = categoryId })
  ↓
_buildMenuSection() called
  ↓
_filterItemsByCategory(items, _selectedCategoryId)
  ↓
Filtered items passed to _buildMenuItems()
  ↓
MenuItemCard widgets rendered with filtered items
```

### Card Expansion
```
User taps MenuItemCard
  ↓
_toggleExpand() in MenuItemCard state
  ↓
setState(() { _isExpanded = !_isExpanded })
  ↓
AnimationController.forward() or .reverse()
  ↓
SizeTransition animates height
  ↓
Customization options & allergens shown/hidden
```

### Add to Cart
```
User taps "Add" button
  ↓
MenuItemCard.onAddToCart()
  ↓
_handleAddToCart() in MenuPage
  ↓
SnackBar shows confirmation (placeholder)
  ↓
TODO: Implement actual cart state management
```

---

## Component Props

### UserHeaderCard
```dart
Props:
  - user: User?
  - onLogout: VoidCallback

Emits:
  - onLogout() when logout button tapped
```

### MenuHeader
```dart
Props: None (static component)
```

### CategoryChips
```dart
Props:
  - categories: List<CategoryEntity>
  - selectedCategoryId: String?
  - onCategorySelected: Function(String?)

Emits:
  - onCategorySelected(categoryId) when chip tapped
```

### MenuItemCard
```dart
Props:
  - item: MenuItemEntity
  - onAddToCart: VoidCallback?

Internal State:
  - _isExpanded: bool
  - _animationController: AnimationController

Emits:
  - onAddToCart() when add button tapped
```

### CustomBottomNavigationBar
```dart
Props:
  - currentIndex: int
  - onTap: Function(int)

Emits:
  - onTap(index) when nav item tapped
```

---

## Animations

### MenuItemCard Expansion
```
Animation Type: SizeTransition
Duration: 300ms
Curve: easeInOut

Trigger: Tap on card
Effect: Smooth height expansion/collapse

Additional: AnimatedRotation on chevron icon
  - 0 turns (down) when collapsed
  - 0.5 turns (up) when expanded
```

### CustomBottomNavigationBar Selection
```
Animation Type: AnimatedContainer
Duration: 200ms (implicit)

Trigger: Tap on nav item
Effect: Gradient background fades in/out
```

### CategoryChips Selection
```
Animation Type: FilterChip (built-in)
Duration: ~150ms (Material default)

Trigger: Tap on chip
Effect: Background color change + checkmark
```

---

## Styling Consistency

All components use `AppColors` from `shared/theme/app_colors.dart`:

- **Primary**: Orange-red (#FF6B35)
- **Success**: Green (#4CAF50)
- **Error**: Red (#E53935)
- **Text Primary**: Dark gray (#212121)
- **Text Secondary**: Medium gray (#757575)
- **Shadows**: Light shadow (0x0D000000)
- **Gradients**: Primary gradient (primary → primaryDark)

---

## Responsive Behavior

### UserHeaderCard
- Fixed height based on content
- Responsive width (fills available space)

### MenuHeader
- Fixed height based on content
- Responsive width with padding

### CategoryChips
- Fixed height: 50px
- Horizontal scroll for overflow
- Chips size based on content

### MenuItemCard
- Responsive width (fills available space)
- Fixed image size: 100x100
- Expandable height (animated)

### CustomBottomNavigationBar
- Fixed height based on content + SafeArea
- Responsive width (equal spacing)
- 4 items always visible

---

## Performance Optimizations

1. **ListView.builder**: Lazy loading for menu items
2. **const constructors**: Where possible for static widgets
3. **AnimationController disposal**: Proper cleanup in MenuItemCard
4. **Efficient filtering**: Single pass with `where()` clause
5. **Minimal rebuilds**: Local state in components
6. **Image caching**: NetworkImage handles caching automatically

---

## Accessibility

1. **Touch targets**: All interactive elements ≥ 48x48 dp
2. **Visual feedback**: InkWell ripples on all tappable areas
3. **Disabled states**: Clear visual distinction for unavailable items
4. **Semantic labels**: Descriptive text for all actions
5. **Color contrast**: Meets WCAG AA standards
6. **Animation duration**: < 400ms for responsiveness
