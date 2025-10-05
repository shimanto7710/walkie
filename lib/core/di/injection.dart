import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register Firebase Database
  getIt.registerLazySingleton<FirebaseDatabase>(() => FirebaseDatabase.instance);
  
  // Initialize injectable dependencies
  getIt.init();
  
  // Register repository interface
  getIt.registerLazySingleton<UserRepository>(() => getIt<UserRepositoryImpl>());
}
