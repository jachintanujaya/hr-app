import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hr_app/core/error/failures.dart';
import 'package:hr_app/core/permissions/user_role.dart';
import 'package:hr_app/core/usecases/usecase.dart';
import 'package:hr_app/features/auth/domain/entities/user_entity.dart';
import 'package:hr_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:hr_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:hr_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:hr_app/features/auth/presentation/bloc/auth_bloc.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockGetCurrentUserUseCase getCurrentUserUseCase;

  const testUser = UserEntity(
    id: '1',
    fullName: 'Jane Doe',
    email: 'jane@company.com',
    role: UserRole.admin,
  );

  setUp(() {
    loginUseCase = MockLoginUseCase();
    logoutUseCase = MockLogoutUseCase();
    getCurrentUserUseCase = MockGetCurrentUserUseCase();
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(NoParams());
  });

  AuthBloc buildBloc() => AuthBloc(
        loginUseCase: loginUseCase,
        logoutUseCase: logoutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
      );

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when login succeeds',
      build: buildBloc,
      setUp: () {
        when(() => loginUseCase(any())).thenAnswer((_) async => const Right(testUser));
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(email: 'jane@company.com', password: 'secret')),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.authenticated, user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, failure] when login fails',
      build: buildBloc,
      setUp: () {
        when(() => loginUseCase(any()))
            .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(email: 'jane@company.com', password: 'wrong')),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.failure, errorMessage: 'Invalid credentials'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'admin user has team-management permissions',
      build: buildBloc,
      setUp: () {
        when(() => loginUseCase(any())).thenAnswer((_) async => const Right(testUser));
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(email: 'jane@company.com', password: 'secret')),
      verify: (bloc) {
        expect(bloc.state.permissions?.canManageTeamMembers, isTrue);
        expect(bloc.state.permissions?.canCreateOrDeleteEmployees, isFalse);
      },
    );
  });
}
