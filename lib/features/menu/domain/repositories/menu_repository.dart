import '../../../../core/error/result.dart';
import '../entities/menu_entity.dart';

/// Menu Repository Interface - Pure domain
abstract class MenuRepository {
  Future<Result<List<MenuEntity>>> getCurrentMenu();
  Future<Result<void>> updateMenu(String id, Map<String, dynamic> data);
  Future<Result<void>> updateMenuAdvanced(String id, Map<String, dynamic> data);
}
