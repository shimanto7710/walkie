import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/usecases/login_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/di/injection.dart';

part 'auth_provider.freezed.dart';

// Auth State
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    User? currentUser,
    String? errorMessage,
  }) = _AuthState;
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;

  AuthNotifier(this._loginUseCase) : super(const AuthState());

  Future<void> login(String email, String password) async {
    print('🚀 Starting login process...');
    print('  Email: $email');
    print('  Password: $password');
    
    state = state.copyWith(isLoading: true, errorMessage: null);
    print('📱 State updated: isLoading = true');

    final result = await _loginUseCase(email, password);
    print('🔍 Login use case result: $result');

    result.fold(
      (failure) {
        print('❌ Login failed: $failure');
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: _getErrorMessage(failure),
        );
        print('📱 State updated: isLoading = false, isAuthenticated = false');
      },
      (user) {
        print('✅ Login successful: ${user.name}');
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          currentUser: user,
          errorMessage: null,
        );
        print('📱 State updated: isLoading = false, isAuthenticated = true');
      },
    );
  }

  void logout() {
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  String _getErrorMessage(Failure failure) {
    return failure.when(
      serverFailure: (message) => 'Server error: $message',
      networkFailure: (message) => 'Network error: $message',
      cacheFailure: (message) => 'Cache error: $message',
      unknownFailure: (message) => 'Unknown error: $message',
      authFailure: (message) => message,
    );
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.read(loginUseCaseProvider);
  return AuthNotifier(loginUseCase);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return getIt<LoginUseCase>();
});

// Computed providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).currentUser;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});
