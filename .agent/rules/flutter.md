# Enterprise Flutter Coding Rules (Feature-Wise)

## MVVM + Manual Riverpod + Dio + Hive + GoRouter

> **No code generation. No build_runner. Feature-first architecture.**

---

## 0. Global Technology Policy (MANDATORY)

### ❌ Removed

- Freezed
- json_serializable
- Riverpod code generation
- Drift
- build_runner
- Any annotation-based codegen

### ✅ Kept

- Manual Riverpod
- Dio
- Hive (manual adapters only)
- GoRouter
- Pure Dart models
- Explicit constructors + copyWith

---

## 1. Feature-Wise Architecture (MANDATORY)

Each **feature is isolated** and contains **all layers inside it**.

### Dependency Flow (STRICT)

View
↓
ViewModel
↓
UseCase
↓
Repository
↓
DataSource (Remote / Local)

yaml
Copy code

❌ Cross-feature imports are NOT allowed  
❌ UI must never access Repository / Dio / Hive

---

## 2. Project Structure (Feature-First)

lib/
├─ core/
│ ├─ constants/
│ ├─ error/
│ │ ├─ result.dart
│ │ └─ failure.dart
│ ├─ network/
│ │ ├─ dio_client.dart
│ │ └─ interceptors/
│ ├─ storage/
│ │ └─ hive_service.dart
│ └─ di/
│ └─ providers.dart
│
├─ features/
│ ├─ auth/
│ │ ├─ data/
│ │ │ ├─ datasources/
│ │ │ │ ├─ auth_remote_ds.dart
│ │ │ │ └─ auth_local_ds.dart
│ │ │ ├─ dto/
│ │ │ └─ repositories/
│ │ ├─ domain/
│ │ │ ├─ entities/
│ │ │ ├─ repositories/
│ │ │ └─ usecases/
│ │ └─ presentation/
│ │ ├─ viewmodels/
│ │ ├─ views/
│ │ └─ widgets/
│ │
│ ├─ user/
│ │ ├─ data/
│ │ ├─ domain/
│ │ └─ presentation/
│ │
│ └─ dashboard/
│ ├─ data/
│ ├─ domain/
│ └─ presentation/
│
└─ presentation/
└─ routing/

yaml
Copy code

---

## 3. Feature Isolation Rules

- A feature **owns its entire stack**
- No feature imports another feature’s:
  - Data
  - Domain
  - ViewModels

✅ Shared logic must live in `core/`

---

## 4. View Rules (Per Feature)

### Allowed

- `StatelessWidget`
- `ConsumerWidget`

### Rules

- UI only
- No business logic
- Reads state from ViewModel provider
- Navigation via GoRouter only

❌ No Dio / Hive / Repository usage  
❌ No `setState` for logic

---

## 5. ViewModel Rules (Per Feature)

- Uses `StateNotifier` or `AsyncNotifier`
- Holds immutable state
- Calls **only UseCases**
- Emits UI-ready state

❌ No Dio / Hive imports  
❌ No raw JSON

---

## 6. UseCase Rules (Per Feature)

- One action per use case
- Pure Dart
- Returns `Result<T>`
- No Flutter / Dio / Hive imports

Example:

```dart
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Result<UserEntity>> execute(LoginParams params) {
    return repository.login(params);
  }
}
7. Repository Rules (Per Feature)
Implements domain repository interface

Decides remote vs local

Maps DTO → Entity

Handles caching

❌ UI must never see DTOs

8. DataSource Rules (Per Feature)
Remote DataSource
Uses Dio

Returns DTOs

No entities

Local DataSource
Uses Hive

Manual adapters only

No entities

9. DTO & Entity Rules
DTO
Feature-scoped

Immutable

Manual fromJson / toJson

No annotations

Entity
Pure domain model

No dependencies

Used by ViewModels & UI

10. Error Handling (Global)
Result Pattern
dart
Copy code
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure extends Result<Never> {
  final String message;
  const Failure(this.message);
}
Mapping
DioException → Failure

HiveException → Failure

No raw exceptions reach UI

11. Navigation (GoRouter)
Defined in presentation/routing

Feature screens registered centrally

No Navigator API usage

12. Security Rules
HTTPS mandatory

Tokens in secure storage (NOT Hive)

No secrets in code

No sensitive logging

13. Testing Rules (Per Feature)
Minimum per feature:

ViewModel tests

UseCase tests

Repository tests

Rules:

Mock Dio

Mock Hive

No real IO

14. Performance Rules
const widgets

Pagination

Debounced API calls

Fine-grained providers

Avoid rebuild storms

15. Forbidden Practices (GLOBAL)
❌ Freezed
❌ json_serializable
❌ build_runner
❌ Drift
❌ Riverpod codegen
❌ setState for business logic
❌ DTO exposure to UI
❌ Direct HTTP / DB access in UI

16. Naming Conventions
Feature Example: auth
AuthViewModel

AuthState

LoginUseCase

AuthRepository

AuthRepositoryImpl

UserEntity

UserDto

authViewModelProvider

17. Final Guarantee
✅ Feature isolation
✅ No codegen
✅ No build_runner
✅ Stable CI
✅ Scales to large teams
```
