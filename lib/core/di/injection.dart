import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register Firebase Database first
  getIt.registerLazySingleton<FirebaseDatabase>(() => FirebaseDatabase.instance);
  
  // Initialize injectable dependencies
  getIt.init();
  
  
  // Register repository interfaces
  getIt.registerLazySingleton<UserRepository>(() => getIt<UserRepositoryImpl>());
  getIt.registerLazySingleton<AuthRepository>(() => getIt<AuthRepositoryImpl>());
}
