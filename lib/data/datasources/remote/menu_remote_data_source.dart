import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../dto/menu_dto.dart';

/// Remote data source for menu
abstract class MenuRemoteDataSource {
  Future<MenuResponseDto> getCurrentMenu();
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final DioClient _dioClient;

  MenuRemoteDataSourceImpl(this._dioClient);

  @override
  Future<MenuResponseDto> getCurrentMenu() async {
    final response = await _dioClient.get(
      '${ApiConstants.v2}${ApiConstants.menuEndpoint}${ApiConstants.menuCurrentEndpoint}',
    );

    return MenuResponseDto.fromJson(response.data as Map<String, dynamic>);
  }
}
