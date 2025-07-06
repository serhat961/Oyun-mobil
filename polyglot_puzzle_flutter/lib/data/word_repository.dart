import 'dart:math';
import 'package:sqflite/sqflite.dart';

import '../domain/sm2.dart';
import '../domain/vocab_word.dart';
import 'word_database.dart';

class WordRepository {
  static final WordRepository instance = WordRepository._internal();
  final Random _rand = Random();

  WordRepository._internal();

  Future<Database> get _db async => WordDatabase.instance.database;

  Future<List<VocabWord>> _query(String where, List<dynamic> args, [int limit = 10]) async {
    final db = await _db;
    final maps = await db.query('words', where: where, whereArgs: args, limit: limit);
    return maps.map(VocabWord.fromMap).toList();
  }

  Future<VocabWord> addWord(String term, String translation) async {
    final word = VocabWord(term: term, translation: translation);
    final db = await _db;
    final id = await db.insert('words', word.toMap());
    return word.copyWith(id: id);
  }

  Future<void> updateWord(VocabWord word) async {
    final db = await _db;
    await db.update('words', word.toMap(), where: 'id = ?', whereArgs: [word.id]);
  }

  Future<void> markExposure(VocabWord word) async {
    final updated = word.copyWith(exposureCount: word.exposureCount + 1);
    await updateWord(updated);
  }

  Future<void> review(VocabWord word, int quality) async {
    final reviewed = SM2Scheduler.review(word, quality).copyWith(
      successCount: quality >= 3 ? word.successCount + 1 : word.successCount,
    );
    await updateWord(reviewed);
  }

  Future<List<VocabWord>> getWordsForPieces(int count) async {
    // 70% due, 20% new, 10% challenge
    final dueCount = (count * 0.7).round();
    final newCount = (count * 0.2).round();
    final challengeCount = count - dueCount - newCount;

    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    final dueWords = await _query('next_due <= ?', [nowMillis], dueCount);
    final newWords = await _query('repetitions = 0', [], newCount);
    final challengeWords = await _query('easiness < ?', [2.0], challengeCount);

    var pool = [...dueWords, ...newWords, ...challengeWords];
    if (pool.length < count) {
      // If no words exist, seed sample vocabulary
      if (pool.isEmpty) {
        await _seedSampleWords();
        return getWordsForPieces(count);
      }
      // fallback: duplicate random words
      while (pool.length < count && pool.isNotEmpty) {
        pool.add(pool[_rand.nextInt(pool.length)]);
      }
    }
    pool.shuffle(_rand);
    return pool.take(count).toList();
  }

  Future<void> _seedSampleWords() async {
    const samples = [
      ['apple', 'elma'],
      ['book', 'kitap'],
      ['cat', 'kedi'],
      ['dog', 'köpek'],
      ['eat', 'yemek'],
      ['drink', 'içmek'],
      ['run', 'koşmak'],
      ['house', 'ev'],
    ];
    for (final s in samples) {
      await addWord(s[0], s[1]);
    }
  }
}