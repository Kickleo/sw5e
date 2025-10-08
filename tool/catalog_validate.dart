// tool/catalog_validate.dart
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  const baseDir = 'assets/catalog';
  final expected = <String>[
    'species.json',
    'classes.json',
    'backgrounds.json',
    'skills.json',
    'equipment.json',
    'maneuvers.json',
    'formulas.json', // objet
  ];

  final dir = Directory(baseDir);
  if (!dir.existsSync()) {
    print('catalog_validate: "$baseDir" absent — rien à valider (OK provisoire).');
    exit(0);
  }

  final existing = expected.where((f) => File('$baseDir/$f').existsSync()).toList();
  if (existing.isEmpty) {
    print('catalog_validate: aucun fichier de catalogue trouvé — rien à valider (OK provisoire).');
    exit(0);
  }

  final slug = RegExp(r'^[a-z0-9-]{3,60}$');
  final errors = <String>[];

  void addError(String msg) => errors.add(msg);

  // Valide les fichiers "array" avec id/slug unique
  Future<void> validateArrayFile(String name) async {
    final path = '$baseDir/$name';
    final raw = await File(path).readAsString();
    dynamic json;
    try {
      json = jsonDecode(raw);
    } catch (e) {
      addError('$name: JSON invalide ($e)');
      return;
    }
    if (json is! List) {
      addError('$name: attendu un tableau JSON ([]).');
      return;
    }
    final seen = <String>{};
    for (var i = 0; i < json.length; i++) {
      final item = json[i];
      if (item is! Map) {
        addError('$name[$i]: attendu un objet JSON ({}).');
        continue;
      }
      final id = item['id'];
      if (id is! String || id.isEmpty) {
        addError('$name[$i]: champ "id" manquant ou vide.');
        continue;
      }
      if (!slug.hasMatch(id)) {
        addError('$name[$i]: id "$id" ne respecte pas la regex ^[a-z0-9-]{3,60}\$.');
      }
      if (!seen.add(id)) {
        addError('$name[$i]: id en double "$id".');
      }
    }
  }

  // Valide le fichier "formulas.json" (objet)
  Future<void> validateFormulas() async {
    const name = 'formulas.json';
    final path = '$baseDir/$name';
    final raw = await File(path).readAsString();
    dynamic json;
    try {
      json = jsonDecode(raw);
    } catch (e) {
      addError('$name: JSON invalide ($e)');
      return;
    }
    if (json is! Map) {
      addError('$name: attendu un objet JSON ({}).');
      return;
    }
    // Clés minimales (souples au début)
    // Tu pourras renforcer plus tard (exiger des clés spécifiques).
  }

  // Exécute les validations pour chaque fichier présent
  for (final name in existing) {
    if (name == 'formulas.json') {
      validateFormulas();
    } else {
      validateArrayFile(name);
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('catalog_validate: ${errors.length} erreur(s) :');
    for (final e in errors) {
      stderr.writeln(' - $e');
    }
    exit(1);
  } else {
    print('catalog_validate: OK (${existing.length} fichier(s) validé(s)).');
  }
}
