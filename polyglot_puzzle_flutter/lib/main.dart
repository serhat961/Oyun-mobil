import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/screens/game_screen.dart';
import 'presentation/view_models/game_view_model.dart';
import 'monetization/ad_manager.dart';
import 'monetization/purchase_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdManager.instance.initialize();
  await PurchaseManager.instance.initialize();
  runApp(const PolyglotPuzzleApp());
}

class PolyglotPuzzleApp extends StatelessWidget {
  const PolyglotPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameViewModel()),
      ],
      child: MaterialApp(
        title: 'Polyglot Puzzle',
        theme: ThemeData.dark().copyWith(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const GameScreen(),
      ),
    );
  }
}