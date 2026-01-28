import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_app/core/di/providers.dart';
import '../../../loyalty/data/datasources/loyalty_remote_data_source.dart';
import '../../../loyalty/data/repositories/loyalty_repository.dart';
import '../../../loyalty/domain/usecases/loyalty_usecases.dart';
import '../../../loyalty/domain/entities/customer_loyalty_entity.dart';

// Data Source Provider
final loyaltyRemoteDataSourceProvider = Provider<LoyaltyRemoteDataSource>((
  ref,
) {
  final dioClient = ref.watch(dioClientProvider);
  return LoyaltyRemoteDataSourceImpl(dioClient);
});

// Repository Provider
final loyaltyRepositoryProvider = Provider<LoyaltyRepository>((ref) {
  final remoteDataSource = ref.watch(loyaltyRemoteDataSourceProvider);
  return LoyaltyRepositoryImpl(remoteDataSource);
});

// Use Case Providers
final lookupCustomerUseCaseProvider = Provider<LookupCustomerUseCase>((ref) {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return LookupCustomerUseCase(repository);
});

final redeemPointsUseCaseProvider = Provider<RedeemPointsUseCase>((ref) {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return RedeemPointsUseCase(repository);
});

final getCustomerUseCaseProvider = Provider<GetCustomerUseCase>((ref) {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return GetCustomerUseCase(repository);
});

final createCustomerUseCaseProvider = Provider<CreateCustomerUseCase>((ref) {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return CreateCustomerUseCase(repository);
});

// Loyalty State
class LoyaltyState {
  final List<CustomerLoyaltyEntity> allCustomers;
  final CustomerLoyaltyEntity? customer;
  final List<CustomerLoyaltyEntity> searchResults;
  final List<CustomerLoyaltyEntity> upcomingOccasions;
  final bool isLoading;
  final String? error;
  final VisitStats? globalStats; // For analytics summary

  const LoyaltyState({
    this.allCustomers = const [],
    this.customer,
    this.searchResults = const [],
    this.upcomingOccasions = const [],
    this.isLoading = false,
    this.error,
    this.globalStats,
  });

  LoyaltyState copyWith({
    List<CustomerLoyaltyEntity>? allCustomers,
    CustomerLoyaltyEntity? customer,
    List<CustomerLoyaltyEntity>? searchResults,
    List<CustomerLoyaltyEntity>? upcomingOccasions,
    bool? isLoading,
    String? error,
    VisitStats? globalStats,
    bool clearCustomer = false,
    bool clearError = false,
  }) {
    return LoyaltyState(
      allCustomers: allCustomers ?? this.allCustomers,
      customer: clearCustomer ? null : (customer ?? this.customer),
      searchResults: searchResults ?? this.searchResults,
      upcomingOccasions: upcomingOccasions ?? this.upcomingOccasions,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      globalStats: globalStats ?? this.globalStats,
    );
  }
}

// Loyalty Notifier
class LoyaltyNotifier extends StateNotifier<LoyaltyState> {
  final LookupCustomerUseCase _lookupCustomerUseCase;
  final RedeemPointsUseCase _redeemPointsUseCase;
  final GetCustomerUseCase _getCustomerUseCase;
  final CreateCustomerUseCase _createCustomerUseCase;
  final LoyaltyRepository _repository; // Direct repository access for lists

  LoyaltyNotifier(
    this._lookupCustomerUseCase,
    this._redeemPointsUseCase,
    this._getCustomerUseCase,
    this._createCustomerUseCase,
    this._repository,
  ) : super(const LoyaltyState());

  /// Lookup customer by phone or email
  Future<void> lookupCustomer(String identifier) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      searchResults: [],
    );

    try {
      final results = await _lookupCustomerUseCase.call(identifier);
      if (results.length == 1) {
        state = state.copyWith(
          customer: results[0],
          searchResults: results,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          searchResults: results,
          isLoading: false,
          customer: null,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Fetch all customers with filters
  Future<void> fetchAllCustomers({
    String? search,
    String? tier,
    int limit = 50,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final customers = await _repository.getCustomers(
        search: search,
        tier: tier,
        limit: limit,
      );
      state = state.copyWith(allCustomers: customers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new customer
  Future<CustomerLoyaltyEntity?> createCustomer({
    required String name,
    required String phone,
    String? email,
    DateTime? dateOfBirth,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final customer = await _createCustomerUseCase.call(
        name: name,
        phone: phone,
        email: email,
        dateOfBirth: dateOfBirth,
      );
      state = state.copyWith(customer: customer, isLoading: false);
      return customer;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Redeem loyalty points
  Future<Map<String, dynamic>> redeemPoints(int points) async {
    if (state.customer == null) {
      return {'success': false, 'error': 'No customer selected'};
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _redeemPointsUseCase.call(
        state.customer!.id,
        points,
      );

      if (result['success'] == true) {
        // Refresh customer data to get updated points
        final updatedCustomer = await _getCustomerUseCase.call(
          state.customer!.id,
        );
        state = state.copyWith(customer: updatedCustomer, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] as String?,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Fetch upcoming birthdays/anniversaries
  Future<void> fetchUpcomingOccasions({int days = 7}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final occasions = await _repository.getUpcomingOccasions(days: days);

      state = state.copyWith(upcomingOccasions: occasions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add a note to a customer
  Future<bool> addNote(String customerId, String note) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedNotes = await _repository.addNote(customerId, note);
      if (state.customer?.id == customerId) {
        state = state.copyWith(
          customer: CustomerLoyaltyEntity(
            id: state.customer!.id,
            phone: state.customer!.phone,
            name: state.customer!.name,
            email: state.customer!.email,
            loyaltyTier: state.customer!.loyaltyTier,
            loyaltyPoints: state.customer!.loyaltyPoints,
            memberSince: state.customer!.memberSince,
            visitStats: state.customer!.visitStats,
            status: state.customer!.status,
            notes: updatedNotes,
            preferences: state.customer!.preferences,
            marketing: state.customer!.marketing,
            tags: state.customer!.tags,
            segments: state.customer!.segments,
            referral: state.customer!.referral,
            dateOfBirth: state.customer!.dateOfBirth,
            anniversary: state.customer!.anniversary,
            lastActivity: DateTime.now(),
          ),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Fetch a single customer by ID
  Future<void> fetchCustomerDetails(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final customer = await _getCustomerUseCase.call(id);
      state = state.copyWith(customer: customer, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Select a customer from search results
  void selectCustomer(CustomerLoyaltyEntity customer) {
    state = state.copyWith(customer: customer);
  }

  /// Clear current customer and search results
  void clearCustomer() {
    state = state.copyWith(
      clearCustomer: true,
      clearError: true,
      searchResults: [],
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Loyalty Notifier Provider
final loyaltyNotifierProvider =
    StateNotifierProvider<LoyaltyNotifier, LoyaltyState>((ref) {
      final lookupCustomerUseCase = ref.watch(lookupCustomerUseCaseProvider);
      final redeemPointsUseCase = ref.watch(redeemPointsUseCaseProvider);
      final getCustomerUseCase = ref.watch(getCustomerUseCaseProvider);
      final createCustomerUseCase = ref.watch(createCustomerUseCaseProvider);
      final repository = ref.watch(loyaltyRepositoryProvider);

      return LoyaltyNotifier(
        lookupCustomerUseCase,
        redeemPointsUseCase,
        getCustomerUseCase,
        createCustomerUseCase,
        repository,
      );
    });
