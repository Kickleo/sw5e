/// ---------------------------------------------------------------------------
/// Fichier : lib/common/result/app_result.dart
/// Rôle : Exposer un alias typé autour de [Result] pour homogénéiser la
///        manipulation des succès/erreurs dans la nouvelle architecture.
/// Dépendances : `Result` historique situé dans `core/domain/result.dart`.
/// Exemple d'usage :
///   final outcome = appOk<int>(1);
/// ---------------------------------------------------------------------------
import 'package:sw5e_manager/core/domain/result.dart' as core;

/// AppResult = alias permettant de référencer le type de résultat commun.
typedef AppResult<T> = core.Result<T>;

/// DomainError = alias pour uniformiser les erreurs domaine dans la doc.
typedef DomainError = core.DomainError;

/// appOk = helper pour retourner un [AppResult] réussi.
AppResult<T> appOk<T>(T value) => core.Result<T>.ok(value);

/// appErr = helper pour retourner un [AppResult] en échec.
AppResult<T> appErr<T>(DomainError error) => core.Result<T>.err(error);
