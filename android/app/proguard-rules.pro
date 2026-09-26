# Règles R8 propres à l'app (ajoutées aux règles par défaut de Flutter).

# ML Kit (reconnaissance de texte) : seul le script latin est embarqué. Le SDK
# référence aussi les modules optionnels chinois, devanagari, japonais et coréen,
# absents de l'app : sans ces lignes, R8 échoue sur ces classes manquantes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
