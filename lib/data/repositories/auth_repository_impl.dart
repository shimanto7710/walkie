import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

@injectable
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await _dataSource.authenticateUser(email, password);
      
      if (user != null) {
        await _dataSource.updateUserStatus(user.id, true);
        return Right(user);
      } else {
        return Left(AuthFailure('Invalid email or password'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> signup(String name, String email, String password) async {
    try {
      final user = await _dataSource.createUser(name, email, password);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Logout failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to get current user: $e'));
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
      return Left(UnknownFailure('Failed to update user status: $e'));
    }
  }
}
