// lib/core/domain/result.dart

/// Résultat générique domaine (sans dépendance externe).
/// Usage : Result.ok(value) ou Result.err(DomainError(...))
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>; // Indique si le résultat représente un succès.
  bool get isErr => this is Err<T>; // Symétrique pour un échec.

  T unwrapOr(T fallback) => switch (this) {
        Ok<T>(:final value) => value, // Retourne la valeur si succès.
        Err<T>() => fallback, // Sinon on renvoie la valeur de repli.
      };

  R match<R>({
    required R Function(T value) ok,
    required R Function(DomainError error) err,
  }) =>
      switch (this) {
        Ok<T>(:final value) => ok(value), // Applique la branche succès.
        Err<T>(:final error) => err(error), // Applique la branche échec.
      };

  static Ok<T> ok<T>(T value) => Ok<T>(value); // Helper de création succès.
  static Err<T> err<T>(DomainError error) => Err<T>(error); // Helper échec.
}

final class Ok<T> extends Result<T> {
  final T value; // Valeur du succès.
  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final DomainError error; // Erreur transportée lors d'un échec.
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
