// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:firebase_database/firebase_database.dart' as _i345;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:walkie/data/datasources/firebase_auth_datasource.dart' as _i366;
import 'package:walkie/data/datasources/firebase_user_datasource.dart' as _i291;
import 'package:walkie/data/repositories/auth_repository_impl.dart' as _i873;
import 'package:walkie/data/repositories/user_repository_impl.dart' as _i60;
import 'package:walkie/domain/repositories/auth_repository.dart' as _i756;
import 'package:walkie/domain/repositories/user_repository.dart' as _i685;
import 'package:walkie/domain/usecases/get_users.dart' as _i651;
import 'package:walkie/domain/usecases/login_usecase.dart' as _i325;
import 'package:walkie/domain/usecases/signup_usecase.dart' as _i678;
import 'package:walkie/domain/usecases/update_user_status.dart' as _i543;
import 'package:walkie/domain/usecases/watch_users.dart' as _i921;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i651.GetUsers>(
        () => _i651.GetUsers(gh<_i685.UserRepository>()));
    gh.factory<_i543.UpdateUserStatus>(
        () => _i543.UpdateUserStatus(gh<_i685.UserRepository>()));
    gh.factory<_i921.WatchUsers>(
        () => _i921.WatchUsers(gh<_i685.UserRepository>()));
    gh.factory<_i291.FirebaseUserDataSource>(
        () => _i291.FirebaseUserDataSource(gh<_i345.FirebaseDatabase>()));
    gh.factory<_i366.FirebaseAuthDataSource>(
        () => _i366.FirebaseAuthDataSource(gh<_i345.FirebaseDatabase>()));
    gh.factory<_i873.AuthRepositoryImpl>(
        () => _i873.AuthRepositoryImpl(gh<_i366.FirebaseAuthDataSource>()));
    gh.factory<_i60.UserRepositoryImpl>(
        () => _i60.UserRepositoryImpl(gh<_i291.FirebaseUserDataSource>()));
    gh.factory<_i325.LoginUseCase>(
        () => _i325.LoginUseCase(gh<_i756.AuthRepository>()));
    gh.factory<_i678.SignupUseCase>(
        () => _i678.SignupUseCase(gh<_i756.AuthRepository>()));
    return this;
  }
}
