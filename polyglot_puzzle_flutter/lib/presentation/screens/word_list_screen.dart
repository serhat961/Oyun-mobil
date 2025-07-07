import 'package:flutter/material.dart';
import '../../data/word_repository.dart';
import '../../domain/vocab_word.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<VocabWord> _words = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await WordRepository.instance.getAllWords();
    setState(() => _words = all);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _words.where((w) => w.term.contains(_search)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Words')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search'),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final w = filtered[i];
                return ListTile(
                  title: Text(w.term),
                  subtitle: Text(w.translation),
                  trailing: Text('✓${w.successCount}/${w.exposureCount}'),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}