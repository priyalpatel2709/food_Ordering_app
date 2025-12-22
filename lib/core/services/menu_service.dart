import '../constants/api_constants.dart';
import '../models/menu_response.dart';
import 'api_service.dart';

/// Service for menu-related API calls
class MenuService {
  final ApiService _apiService = ApiService();

  /// Fetch current menu
  ///
  /// Returns the current menu based on the day and time
  Future<MenuResponse?> getCurrentMenu() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.v2}${ApiConstants.menuEndpoint}${ApiConstants.menuCurrentEndpoint}',
      );

      if (response.isSuccess && response.data != null) {
        return MenuResponse.fromJson(response.data!);
      }

      return null;
    } catch (e) {
      print('Error fetching current menu: $e');
      return null;
    }
  }
}
