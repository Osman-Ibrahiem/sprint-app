import 'package:sprint/core/result/failure.dart';

/// Success or a typed [Failure]. Domain code returns this for refusals that
/// are part of normal business, instead of throwing.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;

  T get valueOrThrow => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>(:final failure) => throw StateError('Result is $failure'),
      };

  Failure? get failureOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(:final failure) => failure,
      };

  Result<R> map<R>(R Function(T value) f) => switch (this) {
        Ok<T>(:final value) => Ok(f(value)),
        Err<T>(:final failure) => Err(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
