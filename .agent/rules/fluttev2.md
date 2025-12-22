---
trigger: manual
---

# 🏗️ Enterprise Flutter Architecture Guide
**Version 2.0 - Global Standard for Production Flutter Applications**

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [State Management Patterns](#state-management-patterns)
4. [Feature Module Architecture](#feature-module-architecture)
5. [Dependency Injection](#dependency-injection)
6. [API & Network Layer](#api--network-layer)
7. [Local Storage Strategy](#local-storage-strategy)
8. [Localization (i18n)](#localization-i18n)
9. [Testing Strategy](#testing-strategy)
10. [Performance Optimization](#performance-optimization)
11. [Security Best Practices](#security-best-practices)
12. [CI/CD Pipeline](#cicd-pipeline)

---

## 1. Architecture Overview

### 1.1 Architecture Pattern Selection

Choose based on your project complexity:

#### **Option A: Simplified Clean Architecture** (Recommended for 80% of apps)
```
Presentation Layer (UI)
    ↓
Provider Layer (State Management)
    ↓
Repository Layer (Data Coordination)
    ↓
Data Sources (API, Local DB)
```

**When to use:**
- CRUD applications
- Standard business apps
- MVP/prototypes
- Teams < 10 developers

#### **Option B: Full Clean Architecture** (Complex business logic)
```
Presentation Layer (UI)
    ↓
Provider/BLoC Layer
    ↓
Domain Layer (Use Cases, Entities)
    ↓
Data Layer (Repositories, Data Sources)
```

**When to use:**
- Complex business rules
- Financial/healthcare apps
- Apps requiring extensive testing
- Large teams (10+ developers)

#### **Option C: Feature-First Architecture** (Modular apps)
```
Features (Independent modules)
    ↓
Shared Core (Common utilities)
    ↓
Platform Layer (Native code)
```

**When to use:**
- Multi-tenant applications
- White-label apps
- Microservices architecture
- Apps with plugin system

### 1.2 State Management Decision Matrix

| Pattern | Complexity | Learning Curve | Best For |
|---------|-----------|----------------|----------|
| **Riverpod** | Medium | Medium | Most apps, DI, testability |
| **BLoC** | High | High | Large teams, strict patterns |
| **Provider** | Low | Low | Simple apps, learning |
| **GetX** | Low | Low | Rapid prototyping (not recommended for enterprise) |
| **MobX** | Medium | Medium | Reactive programming fans |

**Recommendation:** Use **Riverpod** for new projects (best balance of power and simplicity)

---

## 2. Project Structure

### 2.1 Root Directory Structure

```
project_root/
├── .agent/                         # AI agent workflows
│   └── workflows/
├── .github/                        # GitHub Actions CI/CD
│   └── workflows/
├── .vscode/                        # VS Code settings
│   ├── launch.json
│   └── settings.json
├── android/                        # Android native
├── ios/                           # iOS native
├── linux/                         # Linux (optional)
├── macos/                         # macOS (optional)
├── web/                           # Web (optional)
├── windows/                       # Windows (optional)
├── assets/                        # Static assets
│   ├── images/
│   ├── fonts/
│   ├── animations/
│   └── data/
├── lib/                           # Main application code
├── test/                          # Unit & widget tests
├── integration_test/              # E2E tests
├── scripts/                       # Build/deployment scripts
├── docs/                          # Documentation
│   ├── ARCHITECTURE.md
│   ├── API.md
│   └── SETUP.md
├── .env.example                   # Environment template
├── .env.dev                       # Development config
├── .env.staging                   # Staging config
├── .env.prod                      # Production config
├── .gitignore
├── analysis_options.yaml          # Linter rules
├── pubspec.yaml
├── README.md
└── CHANGELOG.md
```

### 2.2 Lib Directory Structure (Complete)

```
lib/
├── main.dart                      # App entry point
├── main_dev.dart                  # Dev entry point
├── main_staging.dart              # Staging entry point
├── main_prod.dart                 # Production entry point
│
├── app/                           # App configuration
│   ├── app.dart                  # MaterialApp widget
│   ├── router.dart               # Route configuration
│   ├── app_config.dart           # App-level config
│   └── flavor_config.dart        # Flavor configuration
│
├── core/                          # Shared/common code
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── app_constants.dart
│   │   ├── dimension_constants.dart
│   │   ├── route_constants.dart
│   │   ├── string_constants.dart
│   │   └── permissions/          # Feature permissions
│   │
│   ├── di/                       # Dependency Injection
│   │   ├── injection.dart        # Main DI setup
│   │   ├── app_module.dart       # App-level dependencies
│   │   └── network_module.dart   # Network dependencies
│   │
│   ├── error/                    # Error handling
│   │   ├── exceptions.dart       # Custom exceptions
│   │   ├── failures.dart         # Failure classes
│   │   └── error_handler.dart    # Global error handler
│   │
│   ├── l10n/                     # Localization
│   │   ├── app_en.arb
│   │   ├── app_es.arb
│   │   ├── app_fr.arb
│   │   └── l10n.dart             # Generated
│   │
│   ├── models/                   # Core models
│   │   ├── base_model.dart
│   │   ├── api_response.dart
│   │   ├── pagination_model.dart
│   │   └── result.dart           # Result<T> wrapper
│   │
│   ├── network/                  # Network layer
│   │   ├── api_client.dart       # Dio client
│   │   ├── api_endpoints.dart    # Endpoint definitions
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── logging_interceptor.dart
│   │   │   ├── retry_interceptor.dart
│   │   │   └── error_interceptor.dart
│   │   └── network_info.dart     # Connectivity checker
│   │
│   ├── observers/                # App observers
│   │   ├── provider_observer.dart
│   │   ├── route_observer.dart
│   │   └── lifecycle_observer.dart
│   │
│   ├── services/                 # Core services
│   │   ├── analytics_service.dart
│   │   ├── auth_service.dart
│   │   ├── cache_service.dart
│   │   ├── crashlytics_service.dart
│   │   ├── deep_link_service.dart
│   │   ├── notification_service.dart
│   │   ├── storage_service.dart
│   │   └── biometric_service.dart
│   │
│   ├── theme/                    # Theming
│   │   ├── app_theme.dart
│   │   ├── color_schemes.dart
│   │   ├── text_themes.dart
│   │   ├── theme_extensions.dart
│   │   └── theme_provider.dart
│   │
│   ├── utils/                    # Utilities
│   │   ├── date_utils.dart
│   │   ├── format_utils.dart
│   │   ├── validation_utils.dart
│   │   ├── logger.dart
│   │   └── extensions/
│   │       ├── string_extensions.dart
│   │       ├── context_extensions.dart
│   │       └── date_extensions.dart
│   │
│   └── widgets/                  # Reusable widgets
│       ├── buttons/
│       │   ├── primary_button.dart
│       │   ├── secondary_button.dart
│       │   └── icon_button.dart
│       ├── cards/
│       │   ├── info_card.dart
│       │   └── expandable_card.dart
│       ├── dialogs/
│       │   ├── confirmation_dialog.dart
│       │   ├── error_dialog.dart
│       │   └── loading_dialog.dart
│       ├── forms/
│       │   ├── text_field.dart
│       │   ├── dropdown_field.dart
│       │   ├── date_picker_field.dart
│       │   └── search_field.dart
│       ├── loading/
│       │   ├── shimmer_loading.dart
│       │   ├── skeleton_loader.dart
│       │   └── circular_loader.dart
│       ├── navigation/
│       │   ├── app_bar.dart
│       │   ├── bottom_nav_bar.dart
│       │   └── drawer.dart
│       └── misc/
│           ├── empty_state.dart
│           ├── error_state.dart
│           └── avatar.dart
│
└── features/                      # Feature modules
    ├── auth/
    ├── home/
    ├── profile/
    └── [feature_name]/
```

---

## 3. State Management Patterns

### 3.1 Riverpod Architecture (Recommended)

```dart
// Provider structure
lib/features/[feature]/
├── providers/
│   ├── [feature]_provider.dart           # Main provider
│   ├── [feature]_state_provider.dart     # State notifier
│   └── [feature]_repository_provider.dart # Repository provider

// Example: User feature
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  FutureOr<User?> build() async {
    return await ref.watch(userRepositoryProvider).getCurrentUser();
  }

  Future<void> updateProfile(User user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(userRepositoryProvider).updateUser(user);
    });
  }
}
```

### 3.2 BLoC Pattern (Alternative)

```dart
// BLoC structure
lib/features/[feature]/
├── bloc/
│   ├── [feature]_bloc.dart
│   ├── [feature]_event.dart
│   └── [feature]_state.dart

// Example
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;
  
  UserBloc(this.repository) : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
    on<UpdateUser>(_onUpdateUser);
  }
}
```

---

## 4. Feature Module Architecture

### 4.1 Complete Feature Structure

```
features/[feature_name]/
├── data/
│   ├── datasources/
│   │   ├── [feature]_local_datasource.dart
│   │   └── [feature]_remote_datasource.dart
│   ├── models/
│   │   ├── [model]_model.dart
│   │   ├── [model]_model.g.dart
│   │   └── [model]_model.freezed.dart
│   └── repositories/
│       └── [feature]_repository_impl.dart
│
├── domain/                        # Optional for complex features
│   ├── entities/
│   │   └── [entity].dart
│   ├── repositories/
│   │   └── [feature]_repository.dart
│   └── usecases/
│       ├── get_[feature].dart
│       ├── create_[feature].dart
│       └── update_[feature].dart
│
├── presentation/                  # or "view/"
│   ├── providers/                # or "bloc/"
│   │   └── [feature]_provider.dart
│   ├── screens/                  # or "pages/"
│   │   ├── [feature]_screen.dart
│   │   └── [feature]_detail_screen.dart
│   └── widgets/
│       ├── [feature]_card.dart
│       ├── [feature]_list_item.dart
│       └── [feature]_bottom_sheet.dart
│
└── [feature]_module.dart         # Feature exports
```

### 4.2 Feature Independence Rules

**CRITICAL RULES:**
1. ❌ Features MUST NOT import from other features directly
2. ✅ Shared code goes in `core/`
3. ✅ Feature communication via events/providers
4. ✅ Each feature should be extractable as a package

**Exception:** Importing shared domain entities is acceptable

---

## 5. Dependency Injection

### 5.1 Riverpod DI Pattern

```dart
// core/di/injection.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'injection.g.dart';

// Network
@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ref.watch(configProvider).apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
  ));
  
  dio.interceptors.addAll([
    ref.watch(authInterceptorProvider),
    ref.watch(loggingInterceptorProvider),
  ]);
  
  return dio;
}

// Storage
@riverpod
Database database(DatabaseRef ref) {
  return Database();
}

// Services
@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService(
    api: ref.watch(dioProvider),
    storage: ref.watch(storageServiceProvider),
  );
}

// Repositories
@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepositoryImpl(
    remoteDataSource: ref.watch(userRemoteDataSourceProvider),
    localDataSource: ref.watch(userLocalDataSourceProvider),
  );
}
```

### 5.2 Get_It Pattern (Alternative)

```dart
// core/di/injection.dart
final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External
  getIt.registerLazySingleton(() => Dio());
  
  // Services
  getIt.registerLazySingleton<AuthService>(
    () => AuthServiceImpl(getIt()),
  );
  
  // Repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(ge