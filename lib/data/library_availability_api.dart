import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_repository.dart';

class LibraryAvailabilityApi {
  final SettingsRepository _settings;

  LibraryAvailabilityApi(this._settings);

  Future<LibraryAvailabilityResponse?> checkAvailability({
    required String title,
    required String author,
    String? isbn,
  }) async {
    final baseUrl = _settings.libraryApiUrl;
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('URL de l\'API non configurée');
    }

    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'title': title,
        'author': author,
        if (isbn != null) 'isbn': isbn,
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return LibraryAvailabilityResponse.fromJson(json);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

class LibraryAvailabilityResponse {
  final bool available;
  final String availability;
  final List<LibraryDetail> details;
  final int lastCheck;

  LibraryAvailabilityResponse({
    required this.available,
    required this.availability,
    required this.details,
    required this.lastCheck,
  });

  factory LibraryAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return LibraryAvailabilityResponse(
      available: json['available'] as bool? ?? false,
      availability: json['availability'] as String? ?? 'unknown',
      details:
          (json['details'] as List<dynamic>?)
              ?.map((e) => LibraryDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastCheck:
          json['last_check'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class LibraryDetail {
  final String library;
  final String callNumber;
  final String status;
  final String loanCondition;
  final bool available;

  LibraryDetail({
    required this.library,
    required this.callNumber,
    required this.status,
    required this.loanCondition,
    required this.available,
  });

  factory LibraryDetail.fromJson(Map<String, dynamic> json) {
    return LibraryDetail(
      library: json['library'] as String? ?? '',
      callNumber: json['call_number'] as String? ?? '',
      status: json['status'] as String? ?? '',
      loanCondition: json['loan_condition'] as String? ?? '',
      available: json['available'] as bool? ?? false,
    );
  }
}

final libraryAvailabilityApiProvider = Provider<LibraryAvailabilityApi>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return LibraryAvailabilityApi(settings);
});
