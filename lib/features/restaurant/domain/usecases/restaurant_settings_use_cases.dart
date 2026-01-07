import '../../../../core/error/result.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantSettingsUseCase {
  final RestaurantRepository _repository;

  GetRestaurantSettingsUseCase(this._repository);

  Future<Result<Map<String, dynamic>?>> execute(String id) {
    return _repository.getRestaurantSettings(id);
  }
}

class CreateRestaurantSettingsUseCase {
  final RestaurantRepository _repository;

  CreateRestaurantSettingsUseCase(this._repository);

  Future<Result<void>> execute(Map<String, dynamic> data) {
    return _repository.createRestaurantSettings(data);
  }
}

class UpdateRestaurantSettingsUseCase {
  final RestaurantRepository _repository;

  UpdateRestaurantSettingsUseCase(this._repository);

  Future<Result<void>> execute(String id, Map<String, dynamic> data) {
    return _repository.updateRestaurantSettings(id, data);
  }
}
