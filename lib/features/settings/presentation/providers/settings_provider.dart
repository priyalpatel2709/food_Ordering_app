import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum TextScale { small, medium, large }

class AppSettings {
  final ThemeMode themeMode;
  final bool showItemImages;
  final bool showCategoryImages;
  final TextScale textScale;
  final bool compactLayout;
  final bool leftHandedMode;
  final bool showLoyaltyPoints;
  final bool autoSettle;

  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.showItemImages = true,
    this.showCategoryImages = true,
    this.textScale = TextScale.medium,
    this.compactLayout = false,
    this.leftHandedMode = false,
    this.showLoyaltyPoints = true,
    this.autoSettle = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? showItemImages,
    bool? showCategoryImages,
    TextScale? textScale,
    bool? compactLayout,
    bool? leftHandedMode,
    bool? showLoyaltyPoints,
    bool? autoSettle,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      showItemImages: showItemImages ?? this.showItemImages,
      showCategoryImages: showCategoryImages ?? this.showCategoryImages,
      textScale: textScale ?? this.textScale,
      compactLayout: compactLayout ?? this.compactLayout,
      leftHandedMode: leftHandedMode ?? this.leftHandedMode,
      showLoyaltyPoints: showLoyaltyPoints ?? this.showLoyaltyPoints,
      autoSettle: autoSettle ?? this.autoSettle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'showItemImages': showItemImages,
      'showCategoryImages': showCategoryImages,
      'textScale': textScale.index,
      'compactLayout': compactLayout,
      'leftHandedMode': leftHandedMode,
      'showLoyaltyPoints': showLoyaltyPoints,
      'autoSettle': autoSettle,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      showItemImages: map['showItemImages'] ?? true,
      showCategoryImages: map['showCategoryImages'] ?? true,
      textScale: TextScale.values[map['textScale'] ?? 1],
      compactLayout: map['compactLayout'] ?? false,
      leftHandedMode: map['leftHandedMode'] ?? false,
      showLoyaltyPoints: map['showLoyaltyPoints'] ?? true,
      autoSettle: map['autoSettle'] ?? false,
    );
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
      return SettingsNotifier();
    });

class SettingsNotifier extends StateNotifier<AppSettings> {
  static const String _boxName = 'settings_box';
  static const String _settingsKey = 'app_settings';

  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox(_boxName);
    final savedSettings = box.get(_settingsKey);
    if (savedSettings != null) {
      state = AppSettings.fromMap(Map<String, dynamic>.from(savedSettings));
    }
  }

  Future<void> _saveSettings() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_settingsKey, state.toMap());
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _saveSettings();
  }

  void toggleItemImages(bool value) {
    state = state.copyWith(showItemImages: value);
    _saveSettings();
  }

  void toggleCategoryImages(bool value) {
    state = state.copyWith(showCategoryImages: value);
    _saveSettings();
  }

  void setTextScale(TextScale scale) {
    state = state.copyWith(textScale: scale);
    _saveSettings();
  }

  void toggleLayoutDensity(bool compact) {
    state = state.copyWith(compactLayout: compact);
    _saveSettings();
  }

  void toggleOrientation(bool leftHanded) {
    state = state.copyWith(leftHandedMode: leftHanded);
    _saveSettings();
  }

  void toggleLoyaltyDisplay(bool show) {
    state = state.copyWith(showLoyaltyPoints: show);
    _saveSettings();
  }

  void toggleAutoSettle(bool value) {
    state = state.copyWith(autoSettle: value);
    _saveSettings();
  }
}
