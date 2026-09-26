import 'package:http/http.dart' as http;

/// Client HTTP partagé par les API de livres : réutilise les connexions
/// (keep-alive) au lieu d'ouvrir une nouvelle connexion TLS à chaque requête.
/// Une recherche interroge 4 sources en parallèle puis enchaîne des requêtes
/// complémentaires (auteur, éditions…) : la réutilisation évite autant de
/// poignées de main TLS sur le réseau mobile.
final http.Client sharedHttpClient = http.Client();
