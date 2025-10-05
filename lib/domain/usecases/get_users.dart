import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../../core/errors/failures.dart';

@injectable
class GetUsers {
  final UserRepository _repository;

  GetUsers(this._repository);

  Future<Either<Failure, List<User>>> call() async {
    return await _repository.getUsers();
  }
}
