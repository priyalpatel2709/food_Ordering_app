import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/kds_order.dart';

class KdsRemoteDataSource {
  final DioClient _dioClient;

  KdsRemoteDataSource(this._dioClient);

  Future<KdsConfig> getConfig() async {
    final response = await _dioClient.get(
      ApiConstants.v1 + ApiConstants.kds + ApiConstants.kdsConfig,
    );
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return KdsConfig.fromJson(data['data']);
    }
    return KdsConfig.fromJson(data);
  }

  Future<List<KdsOrder>> getOrders() async {
    final response = await _dioClient.get(ApiConstants.v1 + ApiConstants.kds);
    final data = response.data;
    List<dynamic> list = [];
    if (data is List) {
      list = data;
    } else if (data is Map && data['data'] is List) {
      list = data['data'];
    }

    return list.map((e) => KdsOrder.fromJson(e)).toList();
  }

  Future<KdsOrder> updateItemStatus(
    String orderId,
    String itemId,
    String status,
  ) async {
    final response = await _dioClient.patch(
      '${ApiConstants.v1}${ApiConstants.kds}/$orderId/items/$itemId/status',
      data: {'status': status},
    );
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return KdsOrder.fromJson(data['data']);
    }
    return KdsOrder.fromJson(data);
  }
}
