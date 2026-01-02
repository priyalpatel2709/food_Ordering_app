import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

abstract class RestaurantRemoteDataSource {
  Future<Map<String, dynamic>> getDashboardStats({
    String? startDate,
    String? endDate,
  });
  Future<List<int>> exportDashboardReport({String? startDate, String? endDate});
  Future<Map<String, dynamic>> getRestaurantSettings(String id);
  Future<void> updateRestaurantSettings(String id, Map<String, dynamic> data);
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final DioClient _dioClient;

  RestaurantRemoteDataSourceImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> getDashboardStats({
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.dashboard}${ApiConstants.dashboardStats}',
      queryParameters: queryParams,
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<List<int>> exportDashboardReport({
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    // Use raw dio to get bytes
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.dashboard}${ApiConstants.dashboardExport}',
      queryParameters: queryParams,
      // Note: DioClient needs to handle or expose responseType
    );
    // Assuming the response is indeed the list of bytes or a buffer
    if (response.data is List<int>) {
      return response.data;
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getRestaurantSettings(String id) async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.restaurantEndpoint}/$id',
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<void> updateRestaurantSettings(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _dioClient.put(
      '${ApiConstants.v1}${ApiConstants.restaurantEndpoint}/$id',
      data: data,
    );
  }
}
