# HR Portal — Flutter (Clean Architecture + Bloc)

A multi-role HR app: **Employee**, **Admin** (team manager), **Super Admin** (HR).
Covers Attendance, Time Off, and Employee Management.

## Architecture

```
lib/
  core/                     # shared infrastructure, no feature logic
    di/                     # get_it service locator
    network/                # dio client + connectivity check
    error/                  # Failure (domain-safe) & Exception (data-layer) types
    usecases/               # base UseCase<Type, Params> contract
    permissions/            # UserRole enum + Permissions helper (role -> capabilities)
    routing/                # go_router config with role-aware redirects
    utils/                  # constants

  features/
    auth/                   # ✅ fully implemented — use as the template
      domain/               #   entities, repository interface, usecases
      data/                 #   models, datasources (remote/local), repository impl
      presentation/         #   bloc, pages, widgets
    attendance/             # ✅ fully implemented (clock in/out + team view)
    time_off/               # ✅ fully implemented (request/cancel, approvals, policies)
    employee_management/    # ✅ fully implemented (my team / all employees / detail / create / reassign)
    dashboard/              # ✅ example of permission-based UI composition
```

## Why this structure

- **Domain layer has zero Flutter/Dio/Hive imports.** It only knows about
  entities, repository *interfaces*, and usecases. This is what makes the
  business logic testable and swappable.
- **Data layer** implements those interfaces, talking to Dio (remote) and
  secure storage (local), translating `Exception`s into `Failure`s.
- **Presentation layer (Bloc)** only talks to usecases via `Either<Failure, T>`,
  never directly to repositories or datasources.
- **One role enum, one Permissions class.** Don't write `if (user.role == 'admin')`
  scattered through widgets — always go through `Permissions` so business rules
  about who-can-do-what live in exactly one file
  (`core/permissions/permissions.dart`).

## All core features are implemented

Auth, Attendance, Time Off, and Employee Management are all built end-to-end
following the same Clean Architecture + Bloc pattern: domain (entities,
repository interfaces, usecases) → data (models, datasources, repository
impls) → presentation (bloc, pages). If you add a new feature (e.g.
Payroll, Performance Reviews), copy any of these four feature folders
file-by-file as your template — `time_off` is the richest example since it
has three distinct role-scoped flows in one bloc (request/cancel, approve/reject,
policy management).

What's still genuinely a TODO, marked inline in the code:
- Token refresh flow in `core/network/dio_client.dart` (currently just lets 401s bubble up)
- Manager-picker UI in `EmployeeDetailPage` for super admin's "reassign manager" action
- Edit-record form in `TeamAttendancePage`'s dialog (currently a placeholder)
- Wiring `Profile` tile on the dashboard to a real profile page
- `flutter_secure_storage` doesn't work out of the box on web — if you need
  web support, swap to `shared_preferences` (less secure) or a platform check

## Role model

```dart
enum UserRole { employee, admin, superAdmin }
```

- **employee** — clocks in/out, requests time off, views own profile
- **admin** — all employee abilities + views/edits team attendance, approves
  team's time off, manages team members
- **superAdmin** (HR) — all admin abilities + full org-wide CRUD on employees,
  time-off policy configuration, company-wide reports

All of this is expressed as boolean getters on `Permissions`, computed from
the role — extend that file as new capabilities are added, instead of adding
new `if (role == ...)` checks elsewhere.

## Setup

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs   # if you add injectable/json_serializable annotations
flutter run
```

Update `ApiConstants.baseUrl` in `lib/core/utils/constants.dart` to point at
your real backend, and adjust the JSON keys in `UserModel.fromJson` /
`AuthRemoteDataSource` to match your API's actual response shape.

## Testing

`bloc_test` + `mocktail` are included. Suggested pattern (see `test/features/auth`):
- Mock the repository, test the Bloc's emitted states for each usecase outcome.
- Mock the datasources, test the repository's Either mapping.
- Test `Permissions` directly per role — it's pure logic, trivial to cover 100%.
