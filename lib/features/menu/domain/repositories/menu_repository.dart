import '../../../../core/error/result.dart';
import '../../../../core/domain/entities/paginated_data.dart';
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
  Future<Result<void>> addItem(Map<String, dynamic> itemData);
  Future<Result<void>> updateMenuAdvanced(String id, Map<String, dynamic> data);
  Future<Result<PaginatedData<MenuEntity>>> getAllMenus({
    int page = 1,
    int limit = 10,
    String? search,
  });
  Future<Result<void>> createCategory(Map<String, dynamic> data);
  Future<Result<void>> updateCategory(String id, Map<String, dynamic> data);
  Future<Result<void>> deleteCategory(String id);
  Future<Result<void>> createCustomizationOption(Map<String, dynamic> data);
  Future<Result<void>> updateCustomizationOption(
    String id,
    Map<String, dynamic> data,
  );
  Future<Result<void>> deleteCustomizationOption(String id);
  Future<Result<void>> updateItem(String id, Map<String, dynamic> data);
  Future<Result<void>> deleteItem(String id);
  Future<Result<PaginatedData<MenuItemEntity>>> getAllItems({
    int page = 1,
    int limit = 10,
    String? search,
  });
  Future<Result<PaginatedData<CategoryEntity>>> getAllCategories({
    int page = 1,
    int limit = 10,
    String? search,
  });
  Future<Result<PaginatedData<CustomizationOptionEntity>>>
  getAllCustomizationOptions({int page = 1, int limit = 10, String? search});
  Future<Result<void>> deleteMenu(String id);
}
