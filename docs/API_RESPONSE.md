# API Response Structure

## Login API Response

When a successful login occurs at `http://localhost:25/login`, the API returns the following structure:

```json
{
  "_id": "507f1f77bcf86cd799439011",
  "name": "John Doe",
  "email": "john.doe@example.com",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "restaurantsId": "507f191e810c19729de860ea"
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `_id` | String | Yes | Unique user identifier (MongoDB ObjectId) |
| `name` | String | Yes | User's full name |
| `email` | String | Yes | User's email address |
| `token` | String | Yes | JWT authentication token for subsequent API calls |
| `restaurantsId` | String | No | Associated restaurant ID (optional, for restaurant owners/staff) |

### Usage in App

The app stores this data using `SharedPreferences`:
- User object is stored as JSON string
- Token is stored separately for easy access
- Data persists across app restarts
- Used for authentication state management

### Example Implementation

```dart
// Making the login request
final response = await http.post(
  Uri.parse('http://localhost:25/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'email': 'user@example.com',
    'password': 'password123',
  }),
);

// Parsing the response
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  final user = User.fromJson(data);
  
  // Access user data
  print(user.id);            // _id
  print(user.name);          // name
  print(user.email);         // email
  print(user.token);         // token
  print(user.restaurantsId); // restaurantsId (nullable)
}
```

### Error Responses

The API may return error responses with the following structure:

```json
{
  "message": "Invalid credentials",
  "error": "Authentication failed"
}
```

The app handles these errors gracefully and displays user-friendly messages.
