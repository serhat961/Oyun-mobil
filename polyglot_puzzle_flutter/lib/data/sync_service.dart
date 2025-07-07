import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/vocab_word.dart';

class SyncService {
  static final SyncService instance = SyncService._internal();
  bool _initialized = false;

  SyncService._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    final url = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    final key = const String.fromEnvironment('SUPABASE_ANON', defaultValue: '');
    if (url.isEmpty || key.isEmpty) return;
    await Supabase.initialize(url: url, anonKey: key);
    _initialized = true;
  }

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> syncWord(VocabWord word) async {
    if (!_initialized) return;
    await _client.from('words').upsert({
      'id': word.id,
      'term': word.term,
      'translation': word.translation,
      'easiness': word.easiness,
      'repetitions': word.repetitions,
      'interval': word.interval,
      'next_due': word.nextDue.toIso8601String(),
      'exposure_count': word.exposureCount,
      'success_count': word.successCount,
    });
  }

  Future<void> syncEntitlements(Set<String> entitlements) async {
    if (!_initialized) return;
    await _client.from('entitlements').upsert({'id': 0, 'items': entitlements.toList()});
  }
}