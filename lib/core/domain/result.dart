// lib/core/domain/result.dart

/// Résultat générique domaine (sans dépendance externe).
/// Usage : Result.ok(value) ou Result.err(DomainError(...))
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T unwrapOr(T fallback) => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => fallback,
      };

  R match<R>({
    required R Function(T value) ok,
    required R Function(DomainError error) err,
  }) =>
      switch (this) {
        Ok<T>(:final value) => ok(value),
        Err<T>(:final error) => err(error),
      };

  static Ok<T> ok<T>(T value) => Ok<T>(value);
  static Err<T> err<T>(DomainError error) => Err<T>(error);
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final DomainError error;
  const Err(this.error);
}

/// Erreurs métier de haut niveau (à enrichir au besoin).
class DomainError {
  final String code;     // ex: 'InvalidPrerequisite', 'UnknownCatalogId'
  final String? message; // optionnel, pour debug/log
  final Map<String, Object?> details; // champs additionnels

  const DomainError(this.code, {this.message, this.details = const {}});

  @override
  String toString() => 'DomainError($code, $message, $details)';
}
