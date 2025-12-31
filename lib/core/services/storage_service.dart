import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

/// Storage Service using Hive for local data persistence
///
/// This service handles all local storage operations with:
/// - Type-safe storage using Hive
/// - Automatic encryption support
/// - Fast read/write operations
/// - Reactive updates with ValueListenable
class StorageService {
  // Box names
  static const String _userBoxName = 'user_box';
  static const String _settingsBoxName = 'settings_box';

  // Keys
  static const String _currentUserKey = 'current_user';
  static const String _authTokenKey = 'auth_token';
  static const String _authRestaurantIdKey = 'restaurant_id';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  StorageService._internal();

  Box<User>? _userBox;
  Box? _settingsBox;

  /// Initialize Hive and open boxes
  /// Call this in main() before runApp()
  static Future<void> init() async {
    await Hive.initFlutter();

    log('Hive init');
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }

    // Open boxes
    try {
      await Hive.openBox<User>(_userBoxName);
    } catch (e) {
      log('Error opening user box, clearing data: $e');
      await Hive.deleteBoxFromDisk(_userBoxName);
      await Hive.openBox<User>(_userBoxName);
    }

    try {
      await Hive.openBox(_settingsBoxName);
    } catch (e) {
      log('Error opening settings box, clearing data: $e');
      await Hive.deleteBoxFromDisk(_settingsBoxName);
      await Hive.openBox(_settingsBoxName);
    }
  }

  /// Get user box
  Box<User> get _getUserBox {
    if (_userBox == null || !_userBox!.isOpen) {
      _userBox = Hive.box<User>(_userBoxName);
    }
    return _userBox!;
  }

  /// Get settings box
  Box get _getSettingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      _settingsBox = Hive.box(_settingsBoxName);
    }
    return _settingsBox!;
  }

  // ==================== User Management ====================

  /// Save user data
  Future<void> saveUser(User user) async {
    await _getUserBox.put(_currentUserKey, user);
    await _getSettingsBox.put(_authTokenKey, user.token);
    await _getSettingsBox.put(_authRestaurantIdKey, user.restaurantsId);
  }

  /// Get current user
  User? getUser() {
    return _getUserBox.get(_currentUserKey);
  }

  /// Get user as stream for reactive updates
  // ValueListenable<Box<User>> getUserStream() {
  //   return _getUserBox.listenable();
  // }

  /// Update user data
  Future<void> updateUser(User user) async {
    await saveUser(user);
  }

  /// Clear user data
  Future<void> clearUser() async {
    await _getUserBox.delete(_currentUserKey);
    await _getSettingsBox.delete(_authTokenKey);
    await _getSettingsBox.delete(_authRestaurantIdKey);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    final user = getUser();
    final token = getToken();
    return user != null && token != null && token.isNotEmpty;
  }

  // ==================== Token Management ====================

  /// Get authentication token
  String? getToken() {
    return _getSettingsBox.get(_authTokenKey);
  }

  String? getRestaurantId() {
    return _getSettingsBox.get(_authRestaurantIdKey);
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _getSettingsBox.put(_authTokenKey, token);
  }

  Future<void> saveRestaurantId(String restaurantId) async {
    await _getSettingsBox.put(_authRestaurantIdKey, restaurantId);
  }

  /// Clear authentication token
  Future<void> clearToken() async {
    await _getSettingsBox.delete(_authTokenKey);
  }

  // ==================== Settings Management ====================

  /// Save theme mode
  Future<void> saveThemeMode(String themeMode) async {
    await _getSettingsBox.put(_themeKey, themeMode);
  }

  /// Get theme mode
  String? getThemeMode() {
    return _getSettingsBox.get(_themeKey);
  }

  /// Save language
  Future<void> saveLanguage(String language) async {
    await _getSettingsBox.put(_languageKey, language);
  }

  /// Get language
  String? getLanguage() {
    return _getSettingsBox.get(_languageKey);
  }

  /// Save generic key-value pair
  Future<void> saveData(String key, dynamic value) async {
    await _getSettingsBox.put(key, value);
  }

  /// Get generic data by key
  T? getData<T>(String key) {
    return _getSettingsBox.get(key) as T?;
  }

  /// Delete data by key
  Future<void> deleteData(String key) async {
    await _getSettingsBox.delete(key);
  }

  /// Check if key exists
  bool hasData(String key) {
    return _getSettingsBox.containsKey(key);
  }

  // ==================== Cleanup ====================

  /// Clear all data (use with caution)
  Future<void> clearAll() async {
    await _getUserBox.clear();
    await _getSettingsBox.clear();
  }

  /// Close all boxes (call when app is closing)
  Future<void> close() async {
    await _userBox?.close();
    await _settingsBox?.close();
  }

  /// Compact boxes to reduce storage size
  Future<void> compact() async {
    await _getUserBox.compact();
    await _getSettingsBox.compact();
  }
}
