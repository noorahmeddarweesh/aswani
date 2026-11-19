import '../../domain/entities/user.dart';
import '../models/user_dto.dart';

/// The only place where an API user becomes an app user.
extension UserMapper on UserDto {
  User toEntity() => User(
    id: id,
    fullName: fullName,
    identifier: identifier,
    hasPreferences: hasPreferences,
    avatarUrl: avatarUrl,
  );
}
