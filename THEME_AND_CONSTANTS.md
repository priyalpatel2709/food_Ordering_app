# Theme and Constants Documentation

## Overview
This document explains how to use the theme system and route constants in the Food Ordering App.

## Theme System

### Color Palette (`app_colors.dart`)
The app uses a comprehensive color system with warm, appetizing colors suitable for a food ordering application.

#### Primary Colors
- **Primary**: `AppColors.primary` - Vibrant orange-red (#FF6B35)
- **Primary Light**: `AppColors.primaryLight` - Lighter variant
- **Primary Dark**: `AppColors.primaryDark` - Darker variant
- **Primary Container**: `AppColors.primaryContainer` - For backgrounds

#### Secondary Colors
- **Secondary**: `AppColors.secondary` - Fresh green (#4CAF50)
- Used for complementary elements and freshness indicators

#### Usage Example
```dart
import 'package:food_ordering_app/shared/theme/app_colors.dart';

Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textOnPrimary),
  ),
)
```

### Theme Configuration (`app_theme.dart`)
The app provides both light and dark themes with consistent styling.

#### Using the Theme
```dart
import 'package:food_ordering_app/shared/theme/app_theme.dart';

MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system, // or ThemeMode.light / ThemeMode.dark
)
```

#### Accessing Theme Colors in Widgets
```dart
// Use theme colors
final primaryColor = Theme.of(context).colorScheme.primary;
final textColor = Theme.of(context).textTheme.bodyLarge?.color;

// Or use AppColors directly
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
  ),
)
```

### Styled Components
The theme includes pre-configured styles for:
- **Buttons**: ElevatedButton, TextButton, OutlinedButton
- **Input Fields**: TextFormField with InputDecoration
- **Cards**: Card widget with elevation and shadows
- **AppBar**: Consistent app bar styling
- **Dialogs**: Alert dialogs and bottom sheets
- **Snackbars**: Floating snackbars with rounded corners

## Route Constants

### Route Constants (`route_constants.dart`)
Centralized route management for better maintainability.

#### Available Routes
```dart
RouteConstants.splash      // '/'
RouteConstants.login       // '/login'
RouteConstants.home        // '/home'
RouteConstants.profile     // '/profile'
RouteConstants.menu        // '/menu'
RouteConstants.cart        // '/cart'
RouteConstants.orders      // '/orders'
RouteConstants.settings    // '/settings'
RouteConstants.favorites   // '/favorites'
RouteConstants.search      // '/search'
```

#### Usage with GoRouter
```dart
import 'package:food_ordering_app/core/constants/route_constants.dart';
import 'package:go_router/go_router.dart';

// Navigate to a route
context.go(RouteConstants.home);

// Navigate with named route
context.goNamed(RouteConstants.homeName);

// Push a route
context.push(RouteConstants.profile);
```

### Benefits of Using Constants
1. **Type Safety**: Compile-time checking of route names
2. **Refactoring**: Easy to update routes across the entire app
3. **Autocomplete**: IDE suggestions for available routes
4. **No Magic Strings**: Eliminates hardcoded string literals

## Barrel Exports

### Theme Barrel Export
```dart
// Import all theme-related files at once
import 'package:food_ordering_app/shared/theme/theme.dart';
```

### Constants Barrel Export
```dart
// Import all constants at once
import 'package:food_ordering_app/core/constants/constants.dart';
```

## Best Practices

### 1. Always Use Theme Colors
❌ **Don't do this:**
```dart
Container(color: Colors.orange)
```

✅ **Do this:**
```dart
Container(color: AppColors.primary)
// or
Container(color: Theme.of(context).colorScheme.primary)
```

### 2. Always Use Route Constants
❌ **Don't do this:**
```dart
context.go('/home')
```

✅ **Do this:**
```dart
context.go(RouteConstants.home)
```

### 3. Use Theme Text Styles
❌ **Don't do this:**
```dart
Text(
  'Title',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
)
```

✅ **Do this:**
```dart
Text(
  'Title',
  style: Theme.of(context).textTheme.headlineMedium,
)
```

### 4. Gradients for Visual Appeal
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(12),
  ),
)
```

## Food Category Colors
Special colors for categorizing food items:
```dart
AppColors.categoryVegetarian  // Green
AppColors.categoryNonVeg      // Red
AppColors.categoryVegan       // Light green
AppColors.categoryDessert     // Pink
AppColors.categoryBeverage    // Blue
```

## Customization

### Changing Primary Color
Edit `lib/shared/theme/app_colors.dart`:
```dart
static const Color primary = Color(0xFFYOURCOLOR);
```

### Adding New Routes
Edit `lib/core/constants/route_constants.dart`:
```dart
static const String newRoute = '/new-route';
static const String newRouteName = 'newRoute';
```

Then add to `app_router.dart`:
```dart
GoRoute(
  path: RouteConstants.newRoute,
  name: RouteConstants.newRouteName,
  builder: (context, state) => NewPage(),
)
```

## Summary
- **Colors**: Use `AppColors` for all color references
- **Theme**: Applied automatically via `AppTheme.lightTheme`
- **Routes**: Use `RouteConstants` for all navigation
- **Consistency**: Follow the established patterns for a cohesive app experience
