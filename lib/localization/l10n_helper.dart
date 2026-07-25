import 'package:flutter/widgets.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';

Locale _cachedAppLocale = const Locale('en');

/// Keep in sync with [appLocaleProvider] for sync lookups (providers/services).
void cacheAppLocale(Locale locale) {
  _cachedAppLocale = locale;
}

Locale get cachedAppLocale => _cachedAppLocale;

/// Resolve localized text without [BuildContext] (providers, services).
String l10nForLocale(
  Locale locale,
  String key, {
  Map<String, String> params = const {},
}) {
  var text = AppLocalizations(locale).t(key);
  for (final entry in params.entries) {
    text = text.replaceAll('{${entry.key}}', entry.value);
  }
  return text;
}

String l10nSync(
  String key, {
  Map<String, String> params = const {},
}) {
  return l10nForLocale(_cachedAppLocale, key, params: params);
}

String applyL10nParams(String text, Map<String, String> params) {
  for (final entry in params.entries) {
    text = text.replaceAll('{${entry.key}}', entry.value);
  }
  return text;
}
