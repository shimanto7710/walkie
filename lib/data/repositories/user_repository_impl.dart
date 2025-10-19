import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/firebase_user_datasource.dart';

@injectable
class UserRepositoryImpl implements UserRepository {
  final FirebaseUserDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);


  @override
  Future<Either<Failure, User?>> getUserById(String userId) async {
    try {
      final user = await _dataSource.getUserById(userId);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserStatus(String userId, bool status) async {
    try {
      await _dataSource.updateUserStatus(userId, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }



  @override
  Future<Either<Failure, List<User>>> getFriendsOfUser(String userId) async {
    try {
      final friends = await _dataSource.getFriendsOfUser(userId);
      return Right(friends);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<List<User>> watchFriendsOfUser(String userId) {
    try {
      return _dataSource.watchFriendsOfUser(userId);
    } catch (e) {
      throw ServerException('Failed to watch friends: $e');
    }
  }
}
