import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../view_models/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: Theme.of(context).textTheme.titleMedium),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (v) => settings.setThemeMode(v!),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (v) => settings.setThemeMode(v!),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (v) => settings.setThemeMode(v!),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Performance Overlay'),
              value: settings.showPerformance,
              onChanged: (v) => settings.setShowPerformance(v),
            ),
            const Divider(),
            Text('Language', style: Theme.of(context).textTheme.titleMedium),
            ...AppLocalizations.supportedLocales.map((locale) => RadioListTile<Locale>(
                  title: Text(locale.languageCode.toUpperCase()),
                  value: locale,
                  groupValue: settings.locale,
                  onChanged: (v) => settings.setLocale(v!),
                )),
          ],
        ),
      ),
    );
  }
}