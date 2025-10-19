import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/errors/failures.dart';

abstract class UserRepository {
  Future<Either<Failure, User?>> getUserById(String userId);
  Future<Either<Failure, void>> updateUserStatus(String userId, bool status);
  Future<Either<Failure, List<User>>> getFriendsOfUser(String userId);
  Stream<List<User>> watchFriendsOfUser(String userId);
}
