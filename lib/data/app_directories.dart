import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Dossier des données de l'app (base, photos de couvertures).
///
/// Sur téléphone : le dossier « documents » privé de l'app (emplacement
/// historique, conservé pour ne pas perdre de données). Sur ordinateur, ce
/// même dossier serait le Documents de l'utilisateur (`~/Documents` sous Linux) :
/// on utilise le dossier de données de l'app (`~/.local/share/<id>` sous Linux).
Future<Directory> appDataDirectory() => Platform.isAndroid || Platform.isIOS
    ? getApplicationDocumentsDirectory()
    : getApplicationSupportDirectory();
