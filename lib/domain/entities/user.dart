import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required bool isOnline,
    required String lastActive,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

extension UserExtension on User {
  String get statusText => isOnline ? 'Online' : 'Offline';
  
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'U';
}
