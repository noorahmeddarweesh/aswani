import '../errors/failure.dart';

/// What every repository method returns: a value or a [Failure], never a
/// thrown exception. The compiler makes the caller handle both.
///
/// ```dart
/// switch (await repository.signIn(...)) {
///   case Success(:final value): ...
///   case Error(:final failure): ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = Error<T>;
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Error<T> extends Result<T> {
  const Error(this.failure);

  final Failure failure;
}
