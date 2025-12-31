import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

/// Generic remote data source for CRUD operations
abstract class CrudRemoteDataSource {
  Future<List<dynamic>> getAll(String endpoint, {Map<String, dynamic>? params});
  Future<dynamic> getOne(String endpoint, String id);
  Future<dynamic> create(String endpoint, Map<String, dynamic> data);
  Future<dynamic> update(String endpoint, String id, Map<String, dynamic> data);
  Future<void> delete(String endpoint, String id);
}

class CrudRemoteDataSourceImpl implements CrudRemoteDataSource {
  final DioClient _dioClient;

  CrudRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<dynamic>> getAll(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}$endpoint/',
      queryParameters: params,
    );
    return response.data['data'] as List<dynamic>;
  }

  @override
  Future<dynamic> getOne(String endpoint, String id) async {
    final response = await _dioClient.get('${ApiConstants.v1}$endpoint/$id');
    return response.data['data'];
  }

  @override
  Future<dynamic> create(String endpoint, Map<String, dynamic> data) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}$endpoint/',
      data: data,
    );
    return response.data['data'];
  }

  @override
  Future<dynamic> update(
    String endpoint,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dioClient.put(
      '${ApiConstants.v1}$endpoint/$id',
      data: data,
    );
    return response.data['data'];
  }

  @override
  Future<void> delete(String endpoint, String id) async {
    await _dioClient.delete('${ApiConstants.v1}$endpoint/$id');
  }
}
