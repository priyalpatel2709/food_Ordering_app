# Quick Start Guide - Food Ordering App

## 🚀 What's Been Implemented

Your Flutter food ordering app now has a complete authentication flow with:

### ✅ Splash Screen
- Animated logo with scale and fade effects
- Beautiful gradient background (orange to red)
- Auto-checks login status
- Navigates to Login or Home based on authentication

### ✅ Login Page
- Modern, premium UI with gradient backgrounds
- Email and password input with validation
- Password visibility toggle
- **API Integration**: Calls `http://localhost:25/login`
- Loading states and error handling
- Success/error feedback with SnackBars

### ✅ Home Page
- Displays user data from API:
  - User ID (`_id`)
  - Name
  - Email
  - Token (stored securely)
  - Restaurant ID (if available)
- Quick action cards (Menu, Cart, Orders, Profile)
- Logout functionality
- Beautiful card-based layout

### ✅ Routing with go_router
- Smooth page transitions
- Route guards for authentication
- Clean navigation structure

## 📱 How to Run

1. **Ensure your backend is running**:
   ```bash
   # Backend should be accessible at:
   http://localhost:25
   ```

2. **Run the Flutter app**:
   ```bash
   flutter run
   ```

   **Note for Android Emulator**: If using Android emulator, you may need to change the API URL from `localhost` to `10.0.2.2` in `lib/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:25';
   ```

## 🔐 API Integration

### Login Request
```http
POST http://localhost:25/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### Expected Response
```json
{
  "_id": "user_id_here",
  "name": "John Doe",
  "email": "user@example.com",
  "token": "jwt_token_here",
  "restaurantsId": "restaurant_id_here"
}
```

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart       # API configuration
│   ├── models/
│   │   └── user.dart                # User data model
│   └── services/
│       ├── auth_service.dart        # Login API calls
│       └── storage_service.dart     # Local data persistence
├── features/
│   ├── splash/
│   │   └── presentation/pages/splash_page.dart
│   ├── authentication/
│   │   └── presentation/pages/login_page.dart
│   └── home/
│       └── presentation/pages/home_page.dart
├── routes/
│   └── app_router.dart              # Navigation config
└── main.dart
```

## 🎨 Features

### Authentication
- ✅ Email/password validation
- ✅ API integration with error handling
- ✅ Token storage (SharedPreferences)
- ✅ Persistent login
- ✅ Secure logout

### UI/UX
- ✅ Modern gradient designs
- ✅ Smooth animations
- ✅ Loading states
- ✅ Form validation
- ✅ Error feedback
- ✅ Responsive layouts

### Navigation
- ✅ go_router implementation
- ✅ Custom transitions
- ✅ Authentication guards

## 🔧 Customization

### Change API URL
Edit `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://your-api-url:port';
```

### Change Theme Colors
Edit `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.yourColor,
),
```

## 🧪 Testing

Test the login flow:
1. Launch the app → See splash screen
2. Wait 3 seconds → Navigate to login
3. Enter email and password
4. Tap "Sign In"
5. On success → Navigate to home page
6. See user information displayed
7. Tap logout → Return to login

## 📊 Navigation Flow

```
App Start
    ↓
Splash Screen (/)
    ↓
Check Login Status
    ├─→ Not Logged In → Login Page (/login)
    │                       ↓
    │                   [Login Success]
    │                       ↓
    └─→ Logged In ────→ Home Page (/home)
                            ↓
                        [Logout]
                            ↓
                        Login Page
```

## ✅ Code Quality

- ✅ No analysis issues
- ✅ All deprecation warnings fixed
- ✅ Proper error handling
- ✅ Type-safe code
- ✅ Clean architecture

## 🎯 Next Steps

You can now extend the app with:
- Menu browsing
- Cart management
- Order placement
- Order history
- User profile editing
- Restaurant selection
- Payment integration
- Push notifications

## 📝 Important Notes

1. **Backend Required**: The app expects a backend at `http://localhost:25/login`
2. **Android Emulator**: Use `10.0.2.2` instead of `localhost`
3. **iOS Simulator**: Use `localhost` as is
4. **Token Storage**: User data persists across app restarts
5. **Validation**: Email must contain '@', password min 6 characters

---

**Your app is ready to run! 🎉**

Run `flutter run` and test the authentication flow with your backend API.
