import 'dart:developer';

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
  Future<void> createCategory(Map<String, dynamic> data);
  Future<void> updateCategory(String id, Map<String, dynamic> data);
  Future<void> deleteCategory(String id);
  Future<void> createCustomizationOption(Map<String, dynamic> data);
  Future<void> updateCustomizationOption(String id, Map<String, dynamic> data);
  Future<void> deleteCustomizationOption(String id);
  Future<void> updateItem(String id, Map<String, dynamic> data);
  Future<void> deleteItem(String id);
  Future<List<MenuItemDto>> getAllItems();
  Future<List<CategoryDto>> getAllCategories();
  Future<List<CustomizationOptionDto>> getAllCustomizationOptions();
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final DioClient _dioClient;

  MenuRemoteDataSourceImpl(this._dioClient);

  @override
  Future<MenuResponseDto> getCurrentMenu() async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.v1}${ApiConstants.menuEndpoint}${ApiConstants.menuCurrentEndpoint}',
      );

      final responseData = response.data;
      if (responseData is List) {
        return MenuResponseDto(
          success: true,
          currentDay: '',
          currentTime: '',
          menus: responseData
              .map((e) => MenuDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }

      return MenuResponseDto.fromJson(responseData as Map<String, dynamic>);
    } catch (e, st) {
      log('Error fetching menu: $e, $st');
      return MenuResponseDto(
        menus: [],
        success: false,
        currentDay: '',
        currentTime: '',
      );
    }
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
      '${ApiConstants.v1}${ApiConstants.itemEndpoint}/createItem',
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

  @override
  Future<void> createCategory(Map<String, dynamic> data) async {
    await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.categoryEndpoint}',
      data: data,
    );
  }

  @override
  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _dioClient.patch(
      '${ApiConstants.v1}${ApiConstants.categoryEndpoint}/$id',
      data: data,
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _dioClient.delete(
      '${ApiConstants.v1}${ApiConstants.categoryEndpoint}/$id',
    );
  }

  @override
  Future<void> createCustomizationOption(Map<String, dynamic> data) async {
    await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.customizationOptionEndpoint}',
      data: data,
    );
  }

  @override
  Future<void> updateCustomizationOption(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _dioClient.patch(
      '${ApiConstants.v1}${ApiConstants.customizationOptionEndpoint}/$id',
      data: data,
    );
  }

  @override
  Future<void> deleteCustomizationOption(String id) async {
    await _dioClient.delete(
      '${ApiConstants.v1}${ApiConstants.customizationOptionEndpoint}/$id',
    );
  }

  @override
  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    await _dioClient.patch(
      '${ApiConstants.v1}${ApiConstants.itemEndpoint}/$id',
      data: data,
    );
  }

  @override
  Future<void> deleteItem(String id) async {
    await _dioClient.delete(
      '${ApiConstants.v1}${ApiConstants.itemEndpoint}/$id',
    );
  }

  @override
  Future<List<MenuItemDto>> getAllItems() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.itemEndpoint}',
    );
    final data = response.data['data'];
    if (data is List) {
      return data.map((e) => MenuItemDto.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<CategoryDto>> getAllCategories() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.categoryEndpoint}',
    );
    final data = response.data['data'];
    if (data is List) {
      return data.map((e) => CategoryDto.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<CustomizationOptionDto>> getAllCustomizationOptions() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.customizationOptionEndpoint}',
    );
    final data = response.data['data'];
    if (data is List) {
      return data.map((e) => CustomizationOptionDto.fromJson(e)).toList();
    }
    return [];
  }
}
