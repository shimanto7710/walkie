import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/user_repository.dart';
import '../../core/errors/failures.dart';

@injectable
class UpdateUserStatus {
  final UserRepository _repository;

  UpdateUserStatus(this._repository);

  Future<Either<Failure, void>> call(String userId, bool status) async {
    return await _repository.updateUserStatus(userId, status);
  }
}
