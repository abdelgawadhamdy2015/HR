import '../error/failures.dart';

/// A minimal Either<Failure, T> replacement used throughout the domain layer,
/// so use cases/repositories never throw — they always return a Result.
sealed class Result<T> {
  const Result();

  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) {
    final self = this;
    if (self is Success<T>) return onSuccess(self.data);
    if (self is Error<T>) return onFailure(self.failure);
    throw StateError('Unreachable');
  }

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
