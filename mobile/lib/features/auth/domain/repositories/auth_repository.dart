import '../../../../core/result/result.dart';
import '../entities/user.dart';

/// What the auth screens need. The UI depends on this interface only; the
/// implementation decides whether data comes from the API or the mock.
abstract interface class AuthRepository {
  Future<Result<User>> signIn({
    required String identifier,
    required String password,
  });

  Future<Result<User>> signUp({
    required String fullName,
    required String identifier,
    required String password,
  });

  /// Sends a verification code to the email or phone.
  Future<Result<void>> requestPasswordReset({required String identifier});

  Future<Result<void>> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  });

  /// The signed-in user from the server (GET /api/users/me); used on launch
  /// to check that the saved session is still valid.
  Future<Result<User>> currentUser();

  Future<void> signOut();
}
