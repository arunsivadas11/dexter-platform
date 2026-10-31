import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<http.Response> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('No Firebase user is signed in.');
    }

    // Get a Firebase ID token for the currently signed-in user.
    final idToken = await user.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Could not obtain a Firebase ID token.');
    }

    final response = await http
        .get(
          Uri.parse('$baseUrl/api/v1/auth/me'),
          headers: {
            'Authorization': 'Bearer $idToken',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));

    return response;
  }

  static String formatResponseBody(String body) {
    try {
      final decoded = jsonDecode(body);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return body.isEmpty ? '(empty response)' : body;
    }
  }
}
