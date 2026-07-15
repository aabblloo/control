import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:control/models/academie.dart';
import 'package:control/models/etablissement.dart';
import 'package:control/models/eleve.dart';

class AuthService {
  AuthService({String? baseUrl}) : _baseUrl = baseUrl ?? 'http://10.0.2.2:8000';

  static String? _bearerToken;
  final String _baseUrl;

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_bearerToken != null) 'Authorization': 'Bearer $_bearerToken',
      };

  dynamic _parseBody(http.Response response) {
    final bytes = response.bodyBytes;
    if (bytes.isEmpty) {
      return {};
    }

    final decoders = <String Function()>[
      () => utf8.decode(bytes),
      () => latin1.decode(bytes),
      () => utf8.decode(bytes, allowMalformed: true),
      () => response.body,
    ];

    for (final decode in decoders) {
      try {
        return jsonDecode(decode());
      } catch (_) {
        continue;
      }
    }

    throw FormatException('Impossible de décoder le JSON de la réponse (${response.statusCode}).');
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final uri = Uri.parse('$_baseUrl/api/login');

    final response = await http.post(
      uri,
      headers: _defaultHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = _parseBody(response) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Échec de la connexion (${response.statusCode})');
    }

    final body = _parseBody(response) as Map<String, dynamic>;
    final token = body['token'] ?? body['access_token'] ?? body['data']?['token'];
    if (token is String && token.isNotEmpty) {
      _bearerToken = token;
    }

    return body;
  }

  Future<List<Academie>> fetchAcademies() async {
    final uri = Uri.parse('$_baseUrl/api/academies');

    if (_bearerToken == null || _bearerToken!.isEmpty) {
      throw Exception('Aucun jeton d’authentification. Veuillez vous connecter avant de charger les académies.');
    }

    final response = await http.get(
      uri,
      headers: _defaultHeaders,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les académies (${response.statusCode})');
    }

    final body = _parseBody(response);

    if (body is List) {
      return body.map((item) => Academie.fromJson(item as Map<String, dynamic>)).toList();
    }

    if (body is Map<String, dynamic>) {
      final list = body['academies'] ?? body['data'] ?? body['items'];
      if (list is List) {
        return list.map((item) => Academie.fromJson(item as Map<String, dynamic>)).toList();
      }
    }

    throw Exception('Format de réponse inattendu pour les académies.');
  }

  Future<List<Etablissement>> fetchEtablissements(int academieId) async {
    final uri = Uri.parse('$_baseUrl/api/etablissements/$academieId');
    if (_bearerToken == null || _bearerToken!.isEmpty) {
      throw Exception('Aucun jeton d’authentification. Veuillez vous connecter avant de charger les établissements.');
    }

    final response = await http.get(
      uri,
      headers: _defaultHeaders,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les établissements (${response.statusCode})');
    }

    final body = _parseBody(response);

    if (body is List) {
      return body.map((item) => Etablissement.fromJson(item as Map<String, dynamic>)).toList();
    }

    if (body is Map<String, dynamic>) {
      final list = body['etablissements'] ?? body['data'] ?? body['items'];
      if (list is List) {
        return list.map((item) => Etablissement.fromJson(item as Map<String, dynamic>)).toList();
      }
    }

    throw Exception('Format de réponse inattendu pour les établissements.');
  }

  Future<ElevesResponse> fetchEleves(int etablissementId) async {
    final uri = Uri.parse('$_baseUrl/api/eleves/$etablissementId');

    if (_bearerToken == null || _bearerToken!.isEmpty) {
      throw Exception('Aucun jeton d’authentification. Veuillez vous connecter avant de charger les élèves.');
    }

    final response = await http.get(
      uri,
      headers: _defaultHeaders,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les élèves (${response.statusCode})');
    }

    final body = _parseBody(response);

    if (body is Map<String, dynamic>) {
      return ElevesResponse.fromJson(body);
    }

    throw Exception('Format de réponse inattendu pour les élèves.');
  }
}
