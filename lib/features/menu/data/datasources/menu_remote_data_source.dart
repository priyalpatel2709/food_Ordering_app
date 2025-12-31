import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../dto/menu_dto.dart';

/// Remote data source for menu
abstract class MenuRemoteDataSource {
  Future<MenuResponseDto> getCurrentMenu();
  Future<MenuDto> getMenuById(String id);
  Future<void> createMenu(Map<String, dynamic> data);
  Future<void> updateMenu(String id, Map<String, dynamic> data);
  Future<void> addItemToMenu(String menuId, Map<String, dynamic> itemData);
  Future<void> updateMenuAdvanced(String id, Map<String, dynamic> data);
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final DioClient _dioClient;

  MenuRemoteDataSourceImpl(this._dioClient);

  @override
  Future<MenuResponseDto> getCurrentMenu() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.menuEndpoint}${ApiConstants.menuCurrentEndpoint}',
    );

    return MenuResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MenuDto> getMenuById(String id) async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.menuEndpoint}/$id',
    );
    return MenuDto.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> createMenu(Map<String, dynamic> data) async {
    await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.menuEndpoint}${ApiConstants.menuCreateEndpoint}',
      data: data,
    );
  }

  @override
  Future<void> updateMenu(String id, Map<String, dynamic> data) async {
    await _dioClient.put(
      '${ApiConstants.v1}${ApiConstants.menuEndpoint}/$id',
      data: data,
    );
  }

  @override
  Future<void> addItemToMenu(
    String menuId,
    Map<String, dynamic> itemData,
  ) async {
    await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.menuEndpoint}/$menuId${ApiConstants.menuAddItemEndpoint}',
      data: itemData,
    );
  }

  @override
  Future<void> updateMenuAdvanced(String id, Map<String, dynamic> data) async {
    await _dioClient.put(
      '${ApiConstants.v1}${ApiConstants.menuEndpoint}${ApiConstants.menuUpdateAdvanced}/$id',
      data: data,
    );
  }
}
