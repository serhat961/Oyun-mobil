import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/screens/game_screen.dart';
import 'presentation/view_models/game_view_model.dart';
import 'monetization/ad_manager.dart';
import 'monetization/purchase_manager.dart';
import 'monetization/hint_manager.dart';
import 'data/sync_service.dart';
import 'l10n/app_localizations.dart';
import 'presentation/view_models/settings_view_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdManager.instance.initialize();
  await PurchaseManager.instance.initialize();
  await HintManager.instance.initialize();
  await SyncService.instance.initialize();
  runApp(const PolyglotPuzzleApp());
}

class PolyglotPuzzleApp extends StatelessWidget {
  const PolyglotPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: Consumer<SettingsViewModel>(builder: (context, settings, _) {
        return MaterialApp(
          title: 'Polyglot Puzzle',
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: settings.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
          ),
          home: const GameScreen(),
        );
      }),
    );
  }
}