import '../../domain/entities/customer_loyalty_entity.dart';
import '../datasources/loyalty_remote_data_source.dart';

/// Repository for loyalty operations
abstract class LoyaltyRepository {
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
    int page,
    int limit,
  });
  Future<Map<String, dynamic>> redeemPoints(String customerId, int points);
  Future<CustomerLoyaltyEntity> addPoints(
    String customerId,
    int points,
    String reason,
  );
  Future<void> recordVisit(String customerId, double orderAmount);
  Future<List<CustomerLoyaltyEntity>> getUpcomingOccasions({int days});
  Future<List<CustomerNote>> addNote(String customerId, String note);
}

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  final LoyaltyRemoteDataSource _remoteDataSource;

  LoyaltyRepositoryImpl(this._remoteDataSource);

  @override
  Future<CustomerLoyaltyEntity?> lookupCustomer(String identifier) async {
    return await _remoteDataSource.lookupCustomer(identifier);
  }

  @override
  Future<CustomerLoyaltyEntity> createCustomer({
    required String name,
    required String phone,
    String? email,
    DateTime? dateOfBirth,
    Map<String, dynamic>? preferences,
  }) async {
    return await _remoteDataSource.createCustomer(
      name: name,
      phone: phone,
      email: email,
      dateOfBirth: dateOfBirth,
      preferences: preferences,
    );
  }

  @override
  Future<CustomerLoyaltyEntity> getCustomer(String id) async {
    return await _remoteDataSource.getCustomer(id);
  }

  @override
  Future<List<CustomerLoyaltyEntity>> getCustomers({
    String? tier,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    return await _remoteDataSource.getCustomers(
      tier: tier,
      status: status,
      search: search,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Map<String, dynamic>> redeemPoints(
    String customerId,
    int points,
  ) async {
    return await _remoteDataSource.redeemPoints(customerId, points);
  }

  @override
  Future<CustomerLoyaltyEntity> addPoints(
    String customerId,
    int points,
    String reason,
  ) async {
    return await _remoteDataSource.addPoints(customerId, points, reason);
  }

  @override
  Future<void> recordVisit(String customerId, double orderAmount) async {
    return await _remoteDataSource.recordVisit(customerId, orderAmount);
  }

  @override
  Future<List<CustomerLoyaltyEntity>> getUpcomingOccasions({
    int days = 7,
  }) async {
    return await _remoteDataSource.getUpcomingOccasions(days: days);
  }

  @override
  Future<List<CustomerNote>> addNote(String customerId, String note) async {
    return await _remoteDataSource.addNote(customerId, note);
  }
}
