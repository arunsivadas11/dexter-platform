import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'statement_upload_response.dart';

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

  Future<StatementUploadResponse> uploadStatement({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const StatementUploadException(
        'You are not signed in. Please sign in and try again.',
      );
    }

    try {
      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw const StatementUploadException(
          'Your session could not be verified. Please sign in again.',
        );
      }

      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse('$baseUrl/api/v1/statements/upload'),
            )
            ..headers['Authorization'] = 'Bearer $idToken'
            ..headers['Accept'] = 'application/json'
            ..files.add(
              http.MultipartFile.fromBytes('file', bytes, filename: fileName),
            );

      // MultipartRequest sets the boundary-bearing Content-Type itself.
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 201) {
        throw _uploadExceptionForResponse(response);
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Expected a JSON object.');
        }
        return StatementUploadResponse.fromJson(decoded);
      } on FormatException {
        throw const StatementUploadException(
          'The server returned an invalid upload response. Please try again.',
        );
      } on TypeError {
        throw const StatementUploadException(
          'The server returned an incomplete upload response. Please try again.',
        );
      }
    } on StatementUploadException {
      rethrow;
    } on TimeoutException {
      throw const StatementUploadException(
        'The upload timed out. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const StatementUploadException(
        'Could not connect to Dexter Platform. Check your connection and try again.',
      );
    } on FirebaseAuthException {
      throw const StatementUploadException(
        'Your session could not be verified. Please sign in again.',
      );
    }
  }

  StatementUploadException _uploadExceptionForResponse(http.Response response) {
    final backendMessage = _readBackendMessage(response.body);
    switch (response.statusCode) {
      case 400:
        return StatementUploadException(
          backendMessage ?? 'This CSV is invalid or unsupported. Check the file and try again.',
        );
      case 401:
        return const StatementUploadException(
          'Authentication failed or your session expired. Please sign in again.',
        );
      case 403:
        return StatementUploadException(
          backendMessage ?? 'Access denied. Make sure your account is authorized and your email is verified.',
        );
      case 413:
        return StatementUploadException(
          backendMessage ?? 'The file exceeds the 10 MB upload limit.',
        );
      case 500:
        return StatementUploadException(
          backendMessage ?? 'The statement could not be uploaded due to a server error. Please try again later.',
        );
      default:
        return StatementUploadException(
          backendMessage ??
              'The upload failed (HTTP ${response.statusCode}). Please try again.',
        );
    }
  }

  String? _readBackendMessage(String body) {
    if (body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        for (final key in ['message', 'detail']) {
          final value = decoded[key];
          if (value is String && value.trim().isNotEmpty) return value.trim();
        }
        final error = decoded['error'];
        if (error is String &&
            error.trim().isNotEmpty &&
            !const {
              'bad request',
              'unauthorized',
              'forbidden',
              'payload too large',
              'internal server error',
            }.contains(error.trim().toLowerCase())) {
          return error.trim();
        }
      }
    } on FormatException {
      // Spring may return a plain-text message for some error responses.
      final message = body.trim();
      if (!message.startsWith('<') && message.length <= 300) return message;
    }
    return null;
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
