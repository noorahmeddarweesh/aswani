import '../errors/app_exception.dart';
import '../errors/failure.dart';
import 'result.dart';

/// Runs a data-source call and turns its outcome into a [Result]: contract
/// errors become a [Failure] with their code, anything else `UNKNOWN`.
Future<Result<T>> guard<T>(Future<T> Function() call) async {
  try {
    return Result.success(await call());
  } on AppException catch (e) {
    return Result.failure(Failure.fromException(e));
  } on Object {
    return const Result.failure(Failure.unknown);
  }
}
