import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

enum UserStatus { active, suspended }

/// A person. Their price tier is not stored: it is derived from their
/// verification and its expiry at booking time (BR-21, BR-25). The national id
/// is unique (BR-27) and shown masked. All seed people are fictional.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String phone,
    required String email,
    String? nationalId,
    @Default(UserStatus.active) UserStatus status,
  }) = _User;
}
