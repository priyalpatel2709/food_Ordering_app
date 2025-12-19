# Food Ordering App - Authentication Flow

This Flutter application implements a complete authentication flow with splash screen, login page, and home page using `go_router` for navigation.

## Features Implemented

### 1. **Splash Screen** (`/`)
- Beautiful animated splash screen with gradient background
- Logo animation with scale and fade effects
- Automatically checks if user is logged in
- Navigates to Login or Home based on authentication status
- 3-second display duration

### 2. **Login Page** (`/login`)
- Modern, premium UI design with gradient backgrounds
- Email and password input fields with validation
- Password visibility toggle
- API integration with `http://localhost:25/login`
- Loading state during authentication
- Success/Error feedback with SnackBars
- Smooth page transitions

### 3. **Home Page** (`/home`)
- Displays user information from API response:
  - User ID (`_id`)
  - Name
  - Email
  - Restaurant ID (if available)
- User profile header
- Quick action cards (Menu, Cart, Orders, Profile)
- Feature highlights
- Logout functionality with confirmation dialog

## API Integration

### Login Endpoint
- **URL**: `http://localhost:25/login`
- **Method**: POST
- **Headers**: `Content-Type: application/json`
- **Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

- **Success Response** (200):
```json
{
  "_id": "user_id_here",
  "name": "John Doe",
  "email": "user@example.com",
  "token": "jwt_token_here",
  "restaurantsId": "restaurant_id_here"
}
```

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart       # API endpoints
│   ├── models/
│   │   └── user.dart                # User model
│   └── services/
│       ├── auth_service.dart        # Authentication API calls
│       └── storage_service.dart     # Local storage (SharedPreferences)
├── features/
│   ├── splash/
│   │   └── presentation/
│   │       └── pages/
│   │           └── splash_page.dart
│   ├── authentication/
│   │   └── presentation/
│   │       └── pages/
│   │           └── login_page.dart
│   └── home/
│       └── presentation/
│           └── pages/
│               └── home_page.dart
├── routes/
│   └── app_router.dart              # go_router configuration
└── main.dart                        # App entry point
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.6.2              # Routing
  http: ^1.2.2                    # HTTP requests
  shared_preferences: ^2.3.3      # Local storage
  flutter_svg: ^2.0.10+1          # SVG support
```

## How to Run

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Ensure backend is running**:
   - Make sure your backend server is running on `http://localhost:25`
   - The `/login` endpoint should be accessible

3. **Run the app**:
   ```bash
   flutter run
   ```

## Navigation Flow

```
Splash Screen (/)
    ↓
    ├─→ Login Page (/login)  [if not logged in]
    │       ↓
    │   [Login Success]
    │       ↓
    └─→ Home Page (/home)    [if logged in]
            ↓
        [Logout]
            ↓
        Login Page (/login)
```

## Key Features

### Authentication
- ✅ Email/Password validation
- ✅ API integration with error handling
- ✅ Token storage using SharedPreferences
- ✅ Persistent login (checks on app start)
- ✅ Secure logout with data clearing

### UI/UX
- ✅ Modern gradient designs
- ✅ Smooth animations and transitions
- ✅ Loading states
- ✅ Error feedback
- ✅ Form validation
- ✅ Responsive layouts

### Routing
- ✅ go_router implementation
- ✅ Custom page transitions
- ✅ Route guards (authentication check)
- ✅ Deep linking support

## Customization

### Change API Base URL
Edit `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://your-api-url:port';
```

### Modify Theme Colors
Edit `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.yourColor,
  brightness: Brightness.light,
),
```

## Testing the Login

You can test the login with your backend credentials. The app will:
1. Validate email format and password length
2. Send POST request to `/login` endpoint
3. Store user data and token on success
4. Navigate to home page
5. Display user information

## Troubleshooting

### Network Error
- Ensure backend is running on `http://localhost:25`
- Check if `/login` endpoint is accessible
- For Android emulator, use `http://10.0.2.2:25` instead of `localhost`

### Build Issues
```bash
flutter clean
flutter pub get
flutter run
```

## Next Steps

- Implement Menu page
- Add Cart functionality
- Create Orders history
- Build Profile settings
- Add Restaurant selection
- Implement real-time notifications

---

**Created with Flutter & go_router** 🚀
