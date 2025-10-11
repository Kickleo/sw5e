# -----------------------------------------------------------------------------
# Fichier : Makefile
# Rôle : Fournir des raccourcis de commandes qualité (format, lint, test, ci).
# Dépendances : Flutter SDK, dart, outils déclarés dans pubspec.
# Exemple d'usage : `make lint` pour analyser le projet.
# -----------------------------------------------------------------------------

.PHONY: format lint test build ci

format:
	flutter format lib test

lint:
	flutter analyze

test:
	flutter test --coverage
	dart run tool/check_coverage.dart --min 70

build:
	flutter build apk --debug

ci: format lint test
