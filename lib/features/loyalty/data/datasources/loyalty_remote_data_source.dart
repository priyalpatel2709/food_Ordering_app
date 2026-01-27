import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/customer_loyalty_entity.dart';

/// Remote data source for customer loyalty operations
abstract class LoyaltyRemoteDataSource {
  Future<CustomerLoyaltyEntity?> lookupCustomer(String identifier);
  Future<CustomerLoyaltyEntity> createCustomer({
    required String name,
    required String phone,
    String? email,
    DateTime? dateOfBirth,
    Map<String, dynamic>? preferences,
  });
  Future<CustomerLoyaltyEntity> getCustomer(String id);
  Future<List<CustomerLoyaltyEntity>> getCustomers({
    String? tier,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  });
  Future<Map<String, dynamic>> redeemPoints(String customerId, int points);
  Future<CustomerLoyaltyEntity> addPoints(
    String customerId,
    int points,
    String reason,
  );
  Future<void> recordVisit(String customerId, double orderAmount);
}

class LoyaltyRemoteDataSourceImpl implements LoyaltyRemoteDataSource {
  final DioClient _dioClient;

  LoyaltyRemoteDataSourceImpl(this._dioClient);

  @override
  Future<CustomerLoyaltyEntity?> lookupCustomer(String identifier) async {
    try {
      // Use search query parameter to support full-text search (name, email, phone)
      final response = await _dioClient.get(
        '${ApiConstants.v1}/loyalty/customers',
        queryParameters: {'search': identifier, 'limit': 1},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['status'] == 'success' &&
          data['data'] != null &&
          (data['data'] as List).isNotEmpty) {
        return CustomerLoyaltyEntity.fromJson(
          data['data'][0] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<CustomerLoyaltyEntity> createCustomer({
    required String name,
    required String phone,
    String? email,
    DateTime? dateOfBirth,
    Map<String, dynamic>? preferences,
  }) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}/loyalty/customers',
      data: {
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
        if (preferences != null) 'preferences': preferences,
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'success') {
      return CustomerLoyaltyEntity.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    } else {
      throw Exception(data['message'] ?? 'Failed to create customer');
    }
  }

  @override
  Future<CustomerLoyaltyEntity> getCustomer(String id) async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}/loyalty/customers/$id',
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'success') {
      return CustomerLoyaltyEntity.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    } else {
      throw Exception(data['message'] ?? 'Failed to get customer');
    }
  }

  @override
  Future<List<CustomerLoyaltyEntity>> getCustomers({
    String? tier,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (tier != null) queryParams['tier'] = tier;
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    final response = await _dioClient.get(
      '${ApiConstants.v1}/loyalty/customers',
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'success') {
      final customers = (data['data'] as List)
          .map(
            (customer) => CustomerLoyaltyEntity.fromJson(
              customer as Map<String, dynamic>,
            ),
          )
          .toList();
      return customers;
    } else {
      throw Exception(data['message'] ?? 'Failed to get customers');
    }
  }

  @override
  Future<Map<String, dynamic>> redeemPoints(
    String customerId,
    int points,
  ) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}/loyalty/customers/$customerId/redeem',
      data: {'points': points},
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'success') {
      return {
        'success': true,
        'discountAmount': points / 100, // 100 points = $1
        'pointsRedeemed': points,
        'remainingPoints': data['data']['currentPoints'] as int,
        'message': data['message'] as String,
      };
    } else {
      return {
        'success': false,
        'error': data['message'] ?? 'Failed to redeem points',
      };
    }
  }

  @override
  Future<CustomerLoyaltyEntity> addPoints(
    String customerId,
    int points,
    String reason,
  ) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}/loyalty/customers/$customerId/points',
      data: {'points': points, 'reason': reason},
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'success') {
      // Return updated customer data
      return await getCustomer(customerId);
    } else {
      throw Exception(data['message'] ?? 'Failed to add points');
    }
  }

  @override
  Future<void> recordVisit(String customerId, double orderAmount) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}/loyalty/customers/$customerId/visit',
      data: {'orderAmount': orderAmount},
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Failed to record visit');
    }
  }
}
