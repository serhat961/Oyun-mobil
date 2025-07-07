import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'score': 'Score',
      'refresh': 'Refresh',
      'store': 'Store',
      'hints': 'Hints',
      'remove_ads': 'Remove Ads',
      'premium_pack': 'Premium Languages',
      'hint_bundle': 'Hint Bundle',
      'monthly_sub': 'Subscription',
      'purchased': 'Purchased',
      'buy': 'Buy',
    },
    'tr': {
      'score': 'Skor',
      'refresh': 'Yenile',
      'store': 'Mağaza',
      'hints': 'İpuçları',
      'remove_ads': 'Reklamları Kaldır',
      'premium_pack': 'Premium Diller',
      'hint_bundle': 'İpucu Paketi',
      'monthly_sub': 'Abonelik',
      'purchased': 'Satın Alındı',
      'buy': 'Satın Al',
    }
  };

  String _get(String key) => _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key]!;

  String get score => _get('score');
  String get refresh => _get('refresh');
  String get store => _get('store');
  String get hints => _get('hints');
  String get removeAds => _get('remove_ads');
  String get premiumPack => _get('premium_pack');
  String get hintBundle => _get('hint_bundle');
  String get monthlySub => _get('monthly_sub');
  String get purchased => _get('purchased');
  String get buy => _get('buy');

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales => const [Locale('en'), Locale('tr')];
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'tr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}