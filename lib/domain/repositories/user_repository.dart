import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/errors/failures.dart';

abstract class UserRepository {
  Future<Either<Failure, List<User>>> getUsers();
  Future<Either<Failure, void>> updateUserStatus(String userId, bool status);
  Future<Either<Failure, void>> addUser(User user);
  Stream<List<User>> watchUsers();
  Future<Either<Failure, List<User>>> getFriendsOfUser(String userId);
  Stream<List<User>> watchFriendsOfUser(String userId);
}
