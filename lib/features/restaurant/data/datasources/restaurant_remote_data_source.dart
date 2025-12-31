import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

abstract class RestaurantRemoteDataSource {
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<int>> exportDashboardReport();
  Future<Map<String, dynamic>> getRestaurantSettings(String id);
  Future<void> updateRestaurantSettings(String id, Map<String, dynamic> data);
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final DioClient _dioClient;

  RestaurantRemoteDataSourceImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.dashboard}${ApiConstants.dashboardStats}',
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<List<int>> exportDashboardReport() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.dashboard}${ApiConstants.dashboardExport}',
      // Response type should be stream or bytes for PDF
    );
    // This is a placeholder for actual byte handling
    return (response.data as List<dynamic>).cast<int>();
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
