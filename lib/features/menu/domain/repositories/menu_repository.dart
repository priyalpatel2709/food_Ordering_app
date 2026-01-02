import '../../../../core/error/result.dart';
import '../entities/menu_entity.dart';

/// Menu Repository Interface - Pure domain
abstract class MenuRepository {
  Future<Result<List<MenuEntity>>> getCurrentMenu();
  Future<Result<MenuEntity>> getMenuById(String id);
  Future<Result<void>> createMenu(Map<String, dynamic> data);
  Future<Result<void>> updateMenu(String id, Map<String, dynamic> data);
  Future<Result<void>> addItemToMenu(
    String menuId,
    Map<String, dynamic> itemData,
  );
  Future<Result<void>> updateMenuAdvanced(String id, Map<String, dynamic> data);
}
