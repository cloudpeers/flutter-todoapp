import 'package:fluent/fluent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

String i18n(BuildContext ctx, String key,
    [Map<String, dynamic> args = const {}]) {
  return FluentLocalizations.of(ctx)!.getMessage(key, args);
}

class FluentLocalizations {
  Locale locale;
  FluentBundle bundle;

  FluentLocalizations(this.locale, this.bundle);

  static Future<FluentLocalizations> load(Locale locale) async {
    final path = 'assets/i18n/$locale.ftl';
    final source = await rootBundle.loadString(path);
    final bundle = FluentBundle(locale.toString());
    bundle.addMessages(source);
    return FluentLocalizations(locale, bundle);
  }

  String getMessage(String key, [Map<String, dynamic> args = const {}]) {
    List<Error> errors = [];
    final translated = bundle.format(key, args: args, errors: errors);
    if (errors.length > 0) {
      throw "[ERROR] $errors";
    }
    return translated;
  }

  /// helper for getting [FluentLocalizations] object
  static FluentLocalizations? of(BuildContext context) =>
      Localizations.of<FluentLocalizations>(context, FluentLocalizations);
}

class FluentLocalizationsDelegate
    extends LocalizationsDelegate<FluentLocalizations> {
  final List<Locale> supportLocales;
  const FluentLocalizationsDelegate(this.supportLocales);

  @override
  bool isSupported(Locale locale) {
    return supportLocales
        .map((locale) => locale.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<FluentLocalizations> load(Locale locale) async {
    return await FluentLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<FluentLocalizations> old) {
    return false;
  }
}
