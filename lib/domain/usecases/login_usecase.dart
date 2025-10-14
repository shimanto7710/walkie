import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

@injectable
class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<Either<Failure, User>> call(String email, String password) async {
    
    if (email.isEmpty || password.isEmpty) {
      return const Left(AuthFailure('Email and password are required'));
    }

    if (!_isValidEmail(email)) {
      return const Left(AuthFailure('Please enter a valid email address'));
    }

    if (password.length < 6) {
      return const Left(AuthFailure('Password must be at least 6 characters'));
    }

    final result = await _authRepository.login(email, password);
    return result;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
