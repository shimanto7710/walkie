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
    
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return const Left(AuthFailure('All fields are required'));
    }

    if (name.length < 2) {
      return const Left(AuthFailure('Name must be at least 2 characters'));
    }

    if (!_isValidEmail(email)) {
      return const Left(AuthFailure('Please enter a valid email address'));
    }

    if (password.length < 6) {
      return const Left(AuthFailure('Password must be at least 6 characters'));
    }

    final result = await _authRepository.signup(name, email, password);
    return result;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
