import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

@injectable
class SignupUseCase {
  final AuthRepository _authRepository;

  SignupUseCase(this._authRepository);

  Future<Either<Failure, User>> call({
    required String name,
    required String email,
    required String password,
  }) async {
    print('🔧 SignupUseCase called with: $email');
    
    // Validate input
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      print('❌ Validation failed: Empty fields');
      return const Left(AuthFailure('All fields are required'));
    }

    if (name.length < 2) {
      print('❌ Validation failed: Name too short');
      return const Left(AuthFailure('Name must be at least 2 characters'));
    }

    if (!_isValidEmail(email)) {
      print('❌ Validation failed: Invalid email format');
      return const Left(AuthFailure('Please enter a valid email address'));
    }

    if (password.length < 6) {
      print('❌ Validation failed: Password too short');
      return const Left(AuthFailure('Password must be at least 6 characters'));
    }

    print('✅ Validation passed, calling auth repository...');
    final result = await _authRepository.signup(name, email, password);
    print('🔍 Auth repository result: $result');
    return result;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
