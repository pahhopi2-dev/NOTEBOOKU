import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/note.dart';
import '../utils/constants.dart';

class SyncResult {
  final bool ok;
  final String message;

  const SyncResult({required this.ok, required this.message});
}

class SyncService {
  SyncService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = (baseUrl ?? apiBaseUrl).replaceAll(RegExp(r'/$'), '');

  final http.Client _client;
  final String _baseUrl;

  Future<List<Note>> fetchNotes(String userId) async {
    final response = await _client.get(_uri('/notes/$userId'));
    _ensureSuccess(response);

    final payload = jsonDecode(response.body);
    if (payload is! List) return const [];

    return payload
        .whereType<Map>()
        .map((item) => Note.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<SyncResult> pushNote(String userId, Note note) async {
    final response = await _client.put(
      _uri('/notes/$userId/${note.id}'),
      headers: _headers,
      body: jsonEncode(note.toJson()),
    );
    _ensureSuccess(response);

    return const SyncResult(ok: true, message: 'Catatan tersinkron.');
  }

  Future<SyncResult> deleteRemoteNote(String userId, String noteId) async {
    final response = await _client.delete(_uri('/notes/$userId/$noteId'));
    _ensureSuccess(response);

    return const SyncResult(ok: true, message: 'Catatan remote dihapus.');
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> get _headers => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    throw SyncException(
      'Sync gagal (${response.statusCode}): ${response.body}',
    );
  }
}

class SyncException implements Exception {
  final String message;

  const SyncException(this.message);

  @override
  String toString() => message;
}
