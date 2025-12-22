---
trigger: always_on
---

# Enterprise Coding Rules for Flutter  
### Riverpod + Drift + Dio

## 1. Architecture Requirements

Project structure must follow:

lib/
├─ core/
│ ├─ constants/
│ ├─ error/
│ ├─ network/
│ ├─ utils/
│ └─ di/
├─ data/
│ ├─ datasources/
│ │ ├─ remote/
│ │ └─ local/
│ ├─ dto/
│ └─ repositories/
├─ domain/
│ ├─ entities/
│ ├─ repositories/
│ └─ usecases/
└─ presentation/
├─ providers/
├─ views/
├─ widgets/
└─ routing/

markdown
Copy code

### Mandatory Layer Rules
- UI → Providers → Use Cases → Repositories → Data Sources
- UI must never call Dio or Drift directly
- Domain must be pure (no Flutter, Dio, Drift imports)

---

## 2. Riverpod Rules
- Use `StateNotifier`, `AsyncNotifier`, or `FutureProvider`
- State must be immutable
- Providers must be defined in core/di
- Separate concerns:
  - `Provider` → configs/services
  - `StateNotifierProvider` → business logic
  - `FutureProvider`/`AsyncNotifier` → async flows

Example:
```dart
final userProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(getUserUseCaseProvider).execute(),
);
3. Dio Rules
Create a centralized DioClient with:

base URL

interceptors

timeouts

retry logic

Never instantiate Dio directly in UI or repositories

Use typed DTOs (no raw JSON)

Implement token injection interceptor

Interceptors requirement:

Auth

Logging in debug only

Retry handling

4. Drift Rules
Create tables, DAOs, and migrations

Use repositories to call DAOs

Implement caching strategy:

remote → cache → serve

Domain layer must never contain Drift imports

5. Error & Result Handling
Use Result type:

Success<T>

Failure

Map:

DioException → Failure

DriftException → Failure

Never throw raw exceptions to UI

6. DTO & Entity Rules
DTO:

immutable

fromJson/toJson

Entities:

pure domain types

no dependency on Flutter/Dio/Drift

7. Security Requirements
HTTPS mandatory

Token storage must be secure (not Drift)

Sensitive values must not be logged

8. Testing Requirements
At minimum:

provider tests

repository tests

use case tests

Mocks must be used for Dio & Drift.

9. Performance Standards
use const constructors

caching and pagination

debounce heavy operations

provider granularity to reduce rebuilds

10. Forbidden Practices
The following are not allowed:

setState for business logic

direct HTTP calls in UI

direct database access in UI

exposing DTOs to UI

using GetX/Bloc/MobX/etc.

bypassing error mapping

hardcoding secrets

11. Documentation Requirements
describe complex use cases

document repositories

document interceptors

explain migrations

12. Naming Conventions (Mandatory)
Examples:

UserRepositoryImpl

GetUserUseCase

UserEntity

UserDto

userProvider

Providers:

dart
Copy code
final userProvider = FutureProvider((ref) { ... });
Repositories:

dart
Copy code
class UserRepositoryImpl implements UserRepository { ... }