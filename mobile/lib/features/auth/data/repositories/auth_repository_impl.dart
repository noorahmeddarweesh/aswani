import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../mappers/user_mapper.dart';
import '../models/auth_response_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._tokens);

  final AuthDataSource _dataSource;

  /// Secure storage for the access and refresh tokens.
  final KeyValueStore _tokens;

  Future<void> _saveTokens(AuthResponseDto response) async {
    await _tokens.write(StorageKeys.accessToken, response.accessToken);
    await _tokens.write(StorageKeys.refreshToken, response.refreshToken);
  }

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Result.success(await call());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    } on Object {
      return const Result.failure(Failure.unknown);
    }
  }

  @override
  Future<Result<User>> signIn({
    required String identifier,
    required String password,
  }) => _guard(() async {
    final response = await _dataSource.login(
      identifier: identifier,
      password: password,
    );
    await _saveTokens(response);
    return response.user.toEntity();
  });

  @override
  Future<Result<User>> signUp({
    required String fullName,
    required String identifier,
    required String password,
  }) => _guard(() async {
    final response = await _dataSource.register(
      fullName: fullName,
      identifier: identifier,
      password: password,
    );
    await _saveTokens(response);
    return response.user.toEntity();
  });

  @override
  Future<Result<void>> requestPasswordReset({required String identifier}) =>
      _guard(() => _dataSource.forgotPassword(identifier: identifier));

  @override
  Future<Result<void>> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) => _guard(
    () => _dataSource.resetPassword(
      identifier: identifier,
      code: code,
      newPassword: newPassword,
    ),
  );

  @override
  Future<void> signOut() async {
    await _dataSource.logout();
    await _tokens.delete(StorageKeys.accessToken);
    await _tokens.delete(StorageKeys.refreshToken);
  }
}
