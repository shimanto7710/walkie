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
  Future<Either<Failure, List<User>>> getUsers() async {
    try {
      final users = await _dataSource.getUsers();
      return Right(users);
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
  Future<Either<Failure, void>> addUser(User user) async {
    try {
      await _dataSource.addUser(user);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<List<User>> watchUsers() {
    try {
      return _dataSource.watchUsers();
    } catch (e) {
      throw ServerException('Failed to watch users: $e');
    }
  }
}
