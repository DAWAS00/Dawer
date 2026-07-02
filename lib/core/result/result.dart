import '../../domain/failures/app_failure.dart';

sealed class Result<T, E> {
  const Result();

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(E failure) onFailure,
  }) {
    return switch (this) {
      Success<T, E>(:final value) => onSuccess(value),
      Failure<T, E>(:final failure) => onFailure(failure),
    };
  }

  T? get valueOrNull => switch (this) {
    Success<T, E>(:final value) => value,
    Failure<T, E>() => null,
  };

  E? get failureOrNull => switch (this) {
    Success<T, E>() => null,
    Failure<T, E>(:final failure) => failure,
  };

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;
}

final class Success<T, E> extends Result<T, E> {
  final T value;
  const Success(this.value);
}

final class Failure<T, E> extends Result<T, E> {
  final E failure;
  const Failure(this.failure);
}

typedef AppResult<T> = Result<T, AppFailure>;
