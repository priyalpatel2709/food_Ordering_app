import '../../../../core/error/result.dart';
import '../entities/menu_entity.dart';

/// Menu Repository Interface - Pure domain
abstract class MenuRepository {
  Future<Result<List<MenuEntity>>> getCurrentMenu();
}
