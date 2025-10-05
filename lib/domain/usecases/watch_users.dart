import 'package:injectable/injectable.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

@injectable
class WatchUsers {
  final UserRepository _repository;

  WatchUsers(this._repository);

  Stream<List<User>> call() {
    return _repository.watchUsers();
  }
}
