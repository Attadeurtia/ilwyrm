import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Tous les textes du modèle (français) existent dans chaque langue, avec les
/// mêmes variables : une traduction oubliée ou cassée fait échouer le test.
void main() {
  Map<String, dynamic> load(String lang) =>
      jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
          as Map<String, dynamic>;

  Set<String> messageKeys(Map<String, dynamic> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  // Noms de variables d'un message ICU : « {nom} » ou « {nom, plural, … } ».
  Set<String> variables(String message) => RegExp(r'\{(\w+)(?=[,}])')
      .allMatches(message)
      .map((m) => m.group(1)!)
      .toSet();

  final template = load('fr');

  for (final lang in ['en', 'es', 'de']) {
    test('$lang : mêmes textes et mêmes variables que le français', () {
      final arb = load(lang);
      expect(messageKeys(arb), messageKeys(template));
      for (final key in messageKeys(template)) {
        expect(
          variables(arb[key] as String),
          variables(template[key] as String),
          reason: '$lang.$key',
        );
      }
    });
  }
}
