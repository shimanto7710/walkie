import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    required String password,
    required bool status,
    required String lastActive,
    @Default({}) Map<String, bool> friends,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

extension UserExtension on User {
  String get statusText => status ? 'Online' : 'Offline';
  
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'U';
  
  String get username => email.split('@').first;
}
