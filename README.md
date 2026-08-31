# شؤون العاملين — Flutter App

Clean Architecture + Cubit (flutter_bloc) implementation of the HR attendance app, wired to
the .NET backend in `../dotnet_backend`.

## Architecture

Each feature (`dashboard`, `employee`) is split into 3 independent layers:

```
lib/
  core/                         # shared: theme, DI, networking, error types, utils
  features/
    dashboard/
      domain/                   # entities, repository *interfaces*, use cases — pure Dart, no Flutter/Dio imports
      data/                     # models (JSON <-> entity), remote data source (Dio), repository impl
      presentation/             # Cubit + State, pages, widgets
    employee/
      domain/ ...
      data/ ...
      presentation/ ...
  main.dart
```

Dependency rule: `presentation -> domain <- data`. The `domain` layer never imports
Flutter or Dio; it only depends on `core/utils/result.dart` (a tiny `Either`-style
`Result<T>` type used instead of throwing exceptions across layer boundaries).

State management is `Cubit` (not full `Bloc`) since every screen here is driven by
simple method calls (`loadDashboard()`, `changeMonth()`, `selectTab()`) rather than
event streams — this keeps the code small without losing the separation flutter_bloc gives you.

Dependency injection is `get_it`, wired once in `core/di/injection_container.dart`.

## Run it

1. Start the backend first (see `../dotnet_backend/README.md`):
   ```bash
   cd ../dotnet_backend/HRAttendance.Api && dotnet run
   ```
2. Point Flutter at it — edit `lib/core/network/api_constants.dart` if needed, or pass it at build time:
   ```bash
   flutter pub get
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5080/api   # Android emulator
   flutter run --dart-define=API_BASE_URL=http://localhost:5080/api  # iOS sim / desktop
   ```

## What's implemented

- **Dashboard** (`شؤون العاملين` home): live stat tiles (total/present/late/mission/leave/absent),
  date picker, quick actions grid, notifications list — screen 1 from the reference design.
- **Employee list**: searchable list of all employees.
- **Employee details** (`بيانات الموظف`): profile header, month calendar with the exact color
  legend (حاضر / إجازة اعتيادية / إجازة عارضة / إجازة مرضية / إذن / انقطاع / مأمورية),
  month navigation arrows, and 4 tabs (التفاصيل / التأخيرات / الإذن / المأموريات) — screen 2.

## Extending it

To add a new feature (e.g. "Leave requests — الإجازات"), copy the `employee/` folder structure:
1. Define entities + repository interface + use cases in `domain/`.
2. Implement models + remote data source + repository in `data/`.
3. Write a `Cubit`/`State` pair and pages/widgets in `presentation/`.
4. Register everything in `injection_container.dart`.
5. Add the corresponding controller/DTOs/endpoints on the .NET side.

## Testing

`bloc_test` and `mocktail` are included as dev dependencies for cubit/repository unit tests
(mock the `*Repository` interfaces — never the Dio client directly — to keep tests fast and layer-correct).
