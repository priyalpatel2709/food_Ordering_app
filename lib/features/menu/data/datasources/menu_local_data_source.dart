import 'dart:convert';
import 'package:hive/hive.dart';
import '../dto/menu_dto.dart';

/// Local data source for menu using Hive

abstract class MenuLocalDataSource {
  Future<MenuResponseDto?> getCachedMenu();
  Future<void> cacheMenu(MenuResponseDto menu);
  Future<void> clearCache();
}

class MenuLocalDataSourceImpl implements MenuLocalDataSource {
  final Box _box;
  static const String _menuKey = 'cached_menu';
  static const String _cacheTimeKey = 'menu_cache_time';
  static const Duration _cacheValidity = Duration(hours: 1);

  MenuLocalDataSourceImpl(this._box);

  @override
  Future<MenuResponseDto?> getCachedMenu() async {
    // Check if cache is still valid
    final cacheTime = _box.get(_cacheTimeKey) as int?;
    if (cacheTime == null) return null;

    final cacheDateTime = DateTime.fromMillisecondsSinceEpoch(cacheTime);
    if (DateTime.now().difference(cacheDateTime) > _cacheValidity) {
      // Cache expired
      await clearCache();
      return null;
    }

    final menuData = _box.get(_menuKey) as String?;
    if (menuData == null) return null;

    try {
      final json = jsonDecode(menuData) as Map<String, dynamic>;
      return MenuResponseDto.fromJson(json);
    } catch (e) {
      // If deserialization fails, clear cache
      await clearCache();
      return null;
    }
  }

  @override
  Future<void> cacheMenu(MenuResponseDto menu) async {
    final jsonString = jsonEncode(menu.toJson());
    await _box.put(_menuKey, jsonString);
    await _box.put(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<void> clearCache() async {
    await _box.delete(_menuKey);
    await _box.delete(_cacheTimeKey);
  }
}
