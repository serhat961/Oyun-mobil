import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static final TranslationService instance = TranslationService._internal();
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  final String _apiKey;

  TranslationService._internal() : _apiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  Future<String?> translate({required String text, required String targetLang}) async {
    if (_apiKey.isEmpty) return null;
    try {
      final uri = Uri.parse('$_endpoint?key=$_apiKey');
      final body = {
        'contents': [
          {
            'parts': [
              {'text': "Translate '$text' to $targetLang. Only provide the translated word."}
            ]
          }
        ]
      };
      final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final candidates = json['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first['content'];
          final parts = content['parts'] as List<dynamic>;
          return parts.first['text'] as String;
        }
      }
    } catch (e) {
      // ignore, will fallback
    }
    return null;
  }

  Future<String?> explanation({required String text, required String targetLang}) async {
    if (_apiKey.isEmpty) return null;
    try {
      final uri = Uri.parse('$_endpoint?key=$_apiKey');
      final body = {
        'contents': [
          {
            'parts': [
              {'text': "Explain the meaning and provide one example sentence for '$text' in $targetLang."}
            ]
          }
        ]
      };
      final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        final candidates = json['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first['content'];
          final parts = content['parts'] as List<dynamic>;
          return parts.first['text'] as String;
        }
      }
    } catch (_) {}
    return null;
  }
}