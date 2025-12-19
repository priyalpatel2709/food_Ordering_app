# Quick Reference Guide

## 🚀 Quick Start

### Initialize App
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await StorageService.init();
  
  // Setup API token if user is logged in
  final storageService = StorageService();
  final token = storageService.getToken();
  if (token != null) {
    ApiService().setAuthToken(token);
  }
  
  runApp(const MainApp());
}
```

---

## 🌐 API Service

### Basic Usage
```dart
final apiService = ApiService();

// GET request
final response = await apiService.get('/users');

// POST request
final response = await apiService.post('/login', data: {
  'email': 'user@example.com',
  'password': 'password123',
});

// PUT request
final response = await apiService.put('/profile', data: {...});

// DELETE request
final response = await apiService.delete('/user/123');
```

### With Auth Token
```dart
// Set token (automatically added to all requests)
ApiService().setAuthToken('your-token-here');

// Make authenticated request
final response = await apiService.get('/protected-route');

// Clear token
ApiService().clearAuthToken();
```

### Error Handling
```dart
final response = await apiService.post('/login', data: {...});

if (response.isSuccess) {
  // Success
  final data = response.data;
  print('Success: $data');
} else {
  // Error
  final error = response.error;
  print('Error: $error');
}
```

---

## 💾 Storage Service

### User Management
```dart
final storage = StorageService();

// Save user
await storage.saveUser(user);

// Get user
final user = storage.getUser();

// Update user
await storage.updateUser(updatedUser);

// Clear user
await storage.clearUser();

// Check if logged in
final isLoggedIn = storage.isLoggedIn();
```

### Token Management
```dart
// Save token
await storage.saveToken('your-token');

// Get token
final token = storage.getToken();

// Clear token
await storage.clearToken();
```

### Settings
```dart
// Theme
await storage.saveThemeMode('dark');
final theme = storage.getThemeMode();

// Language
await storage.saveLanguage('en');
final language = storage.getLanguage();

// Generic data
await storage.saveData('key', 'value');
final value = storage.getData<String>('key');
```

### Reactive Updates
```dart
// Listen to user changes
storage.getUserStream().listenable().addListener(() {
  final user = storage.getUser();
  print('User updated: ${user?.name}');
});
```

---

## 🔐 Authentication

### Login
```dart
final authService = AuthService();
final result = await authService.login(email, password);

if (result.isSuccess && result.user != null) {
  // Save user and navigate
  await StorageService().saveUser(result.user!);
  context.go(RouteConstants.home);
} else {
  // Show error
  print(result.error);
}
```

### Register
```dart
final result = await authService.register(
  name: 'John Doe',
  email: 'john@example.com',
  password: 'password123',
);
```

### Logout
```dart
await authService.logout();
await StorageService().clearUser();
context.go(RouteConstants.login);
```

### Forgot Password
```dart
final result = await authService.forgotPassword('email@example.com');
```

### Change Password
```dart
final result = await authService.changePassword(
  currentPassword: 'old123',
  newPassword: 'new123',
);
```

---

## 🎨 Theme Colors

### Using AppColors
```dart
import 'package:food_ordering_app/shared/theme/app_colors.dart';

// Primary colors
Container(color: AppColors.primary)
Container(color: AppColors.primaryLight)
Container(color: AppColors.primaryDark)

// Text colors
Text('Hello', style: TextStyle(color: AppColors.textPrimary))
Text('Subtitle', style: TextStyle(color: AppColors.textSecondary))

// Background colors
Container(color: AppColors.background)
Container(color: AppColors.surface)

// Status colors
Container(color: AppColors.success)
Container(color: AppColors.error)
Container(color: AppColors.warning)
Container(color: AppColors.info)
```

### Gradients
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
  ),
)

Container(
  decoration: BoxDecoration(
    gradient: AppColors.secondaryGradient,
  ),
)
```

### Shadows
```dart
BoxShadow(
  color: AppColors.shadow,
  blurRadius: 10,
  offset: Offset(0, 5),
)

BoxShadow(
  color: AppColors.shadowLight,
  blurRadius: 5,
)
```

### Food Categories
```dart
// Vegetarian
Container(color: AppColors.categoryVegetarian)

// Non-Veg
Container(color: AppColors.categoryNonVeg)

// Vegan
Container(color: AppColors.categoryVegan)

// Dessert
Container(color: AppColors.categoryDessert)

// Beverage
Container(color: AppColors.categoryBeverage)
```

---

## 🧭 Navigation

### Using Route Constants
```dart
import 'package:food_ordering_app/core/constants/route_constants.dart';

// Navigate
context.go(RouteConstants.home);
context.go(RouteConstants.login);
context.go(RouteConstants.profile);

// Push
context.push(RouteConstants.menu);

// Named navigation
context.goNamed(RouteConstants.homeName);
```

### Available Routes
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

---

## 🎯 Common Patterns

### Login Flow
```dart
Future<void> handleLogin() async {
  final authService = AuthService();
  final storageService = StorageService();
  
  final result = await authService.login(email, password);
  
  if (result.isSuccess && result.user != null) {
    // Save user
    await storageService.saveUser(result.user!);
    
    // Set API token
    ApiService().setAuthToken(result.user!.token);
    
    // Navigate
    context.go(RouteConstants.home);
  } else {
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.error ?? 'Login failed'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
```

### Logout Flow
```dart
Future<void> handleLogout() async {
  final authService = AuthService();
  final storageService = StorageService();
  
  // Call logout API
  await authService.logout();
  
  // Clear local data
  await storageService.clearUser();
  
  // Clear API token
  ApiService().clearAuthToken();
  
  // Navigate to login
  context.go(RouteConstants.login);
}
```

### Check Auth Status
```dart
Future<bool> checkAuthStatus() async {
  final storage = StorageService();
  
  if (!storage.isLoggedIn()) {
    return false;
  }
  
  final token = storage.getToken();
  final authService = AuthService();
  
  // Verify token with server
  final isValid = await authService.verifyToken(token!);
  
  if (!isValid) {
    await storage.clearUser();
    return false;
  }
  
  return true;
}
```

### API Call with Loading State
```dart
bool _isLoading = false;

Future<void> fetchData() async {
  setState(() => _isLoading = true);
  
  try {
    final response = await ApiService().get('/data');
    
    if (response.isSuccess) {
      // Handle success
      final data = response.data;
      // Update UI
    } else {
      // Handle error
      _showError(response.error ?? 'Failed to fetch data');
    }
  } catch (e) {
    _showError('An error occurred: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### Snackbar with Theme Colors
```dart
void showSuccessMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

void showErrorMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
```

---

## 🛠️ Development Commands

### Install Dependencies
```bash
flutter pub get
```

### Generate Hive Adapters
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Watch for Changes (Auto-generate)
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Clean Generated Files
```bash
dart run build_runner clean
```

### Run App
```bash
flutter run
```

### Build APK
```bash
flutter build apk --release
```

### Build iOS
```bash
flutter build ios --release
```

---

## 📱 Widget Examples

### Themed Button
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
  ),
  child: Text('Click Me'),
)
```

### Themed Card
```dart
Card(
  color: AppColors.surface,
  elevation: 2,
  shadowColor: AppColors.shadow,
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text(
      'Card Content',
      style: TextStyle(color: AppColors.textPrimary),
    ),
  ),
)
```

### Gradient Container
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Padding(
    padding: EdgeInsets.all(20),
    child: Text(
      'Gradient Box',
      style: TextStyle(color: AppColors.white),
    ),
  ),
)
```

---

## 🔍 Debugging

### Enable API Logging
API logging is automatically enabled in debug mode. Check console for:
- 🌐 REQUEST logs
- ✅ RESPONSE logs
- ❌ ERROR logs

### Inspect Hive Data
```dart
// Get all users
final userBox = Hive.box<User>('user_box');
print('Users: ${userBox.values}');

// Get all settings
final settingsBox = Hive.box('settings_box');
print('Settings: ${settingsBox.toMap()}');
```

### Clear All Data (Testing)
```dart
await StorageService().clearAll();
```

---

## ✅ Checklist for New Features

- [ ] Define API endpoint in `api_constants.dart`
- [ ] Create service method in appropriate service file
- [ ] Handle loading states in UI
- [ ] Use `AppColors` for all colors
- [ ] Use `RouteConstants` for navigation
- [ ] Add error handling
- [ ] Test with different network conditions
- [ ] Update documentation

---

## 📚 Additional Resources

- [Dio Documentation](https://pub.dev/packages/dio)
- [Hive Documentation](https://docs.hivedb.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Material Design 3](https://m3.material.io/)

---

**Happy Coding! 🚀**
