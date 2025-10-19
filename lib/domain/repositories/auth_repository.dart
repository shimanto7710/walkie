import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> signup(String name, String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> updateUserStatus(String userId, bool status);
}
