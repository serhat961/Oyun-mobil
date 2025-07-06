import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class WordDatabase {
  static final WordDatabase instance = WordDatabase._internal();
  Database? _db;

  WordDatabase._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, 'words.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE words(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            term TEXT NOT NULL,
            translation TEXT NOT NULL,
            easiness REAL NOT NULL,
            repetitions INTEGER NOT NULL,
            interval INTEGER NOT NULL,
            next_due INTEGER NOT NULL,
            exposure_count INTEGER NOT NULL,
            success_count INTEGER NOT NULL
          )
        ''');
      },
    );
  }
}