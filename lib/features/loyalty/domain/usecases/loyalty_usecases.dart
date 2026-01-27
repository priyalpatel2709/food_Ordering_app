import '../entities/customer_loyalty_entity.dart';
import '../../data/repositories/loyalty_repository.dart';

/// Use case for looking up a customer by phone or email
class LookupCustomerUseCase {
  final LoyaltyRepository _repository;

  LookupCustomerUseCase(this._repository);

  Future<CustomerLoyaltyEntity?> call(String identifier) async {
    return await _repository.lookupCustomer(identifier);
  }
}

/// Use case for creating a new customer
class CreateCustomerUseCase {
  final LoyaltyRepository _repository;

  CreateCustomerUseCase(this._repository);

  Future<CustomerLoyaltyEntity> call({
    required String name,
    required String phone,
    String? email,
    DateTime? dateOfBirth,
    Map<String, dynamic>? preferences,
  }) async {
    return await _repository.createCustomer(
      name: name,
      phone: phone,
      email: email,
      dateOfBirth: dateOfBirth,
      preferences: preferences,
    );
  }
}

/// Use case for redeeming loyalty points
class RedeemPointsUseCase {
  final LoyaltyRepository _repository;

  RedeemPointsUseCase(this._repository);

  Future<Map<String, dynamic>> call(String customerId, int points) async {
    return await _repository.redeemPoints(customerId, points);
  }
}

/// Use case for getting customer details
class GetCustomerUseCase {
  final LoyaltyRepository _repository;

  GetCustomerUseCase(this._repository);

  Future<CustomerLoyaltyEntity> call(String id) async {
    return await _repository.getCustomer(id);
  }
}
