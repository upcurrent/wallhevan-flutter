// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get favoritesTab {
    return Intl.message(
      'Favorites',
      name: 'favoritesTab',
      desc: '',
      args: [],
    );
  }

  /// `Mine`
  String get my {
    return Intl.message(
      'Mine',
      name: 'my',
      desc: '',
      args: [],
    );
  }

  /// `TopList`
  String get topList {
    return Intl.message(
      'TopList',
      name: 'topList',
      desc: '',
      args: [],
    );
  }

  /// `Hot`
  String get hot {
    return Intl.message(
      'Hot',
      name: 'hot',
      desc: '',
      args: [],
    );
  }

  /// `random`
  String get random {
    return Intl.message(
      'random',
      name: 'random',
      desc: '',
      args: [],
    );
  }

  /// `Latest`
  String get latest {
    return Intl.message(
      'Latest',
      name: 'latest',
      desc: '',
      args: [],
    );
  }

  /// `Views`
  String get views {
    return Intl.message(
      'Views',
      name: 'views',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get favorites {
    return Intl.message(
      'Favorites',
      name: 'favorites',
      desc: '',
      args: [],
    );
  }

  /// `Relevance`
  String get relevance {
    return Intl.message(
      'Relevance',
      name: 'relevance',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `Anime`
  String get anime {
    return Intl.message(
      'Anime',
      name: 'anime',
      desc: '',
      args: [],
    );
  }

  /// `People`
  String get people {
    return Intl.message(
      'People',
      name: 'people',
      desc: '',
      args: [],
    );
  }

  /// `Last Day`
  String get t_1d {
    return Intl.message(
      'Last Day',
      name: 't_1d',
      desc: '',
      args: [],
    );
  }

  /// `Last Three Days`
  String get t_3d {
    return Intl.message(
      'Last Three Days',
      name: 't_3d',
      desc: '',
      args: [],
    );
  }

  /// `Last Week`
  String get t_1w {
    return Intl.message(
      'Last Week',
      name: 't_1w',
      desc: '',
      args: [],
    );
  }

  /// `Last Month`
  String get t_1M {
    return Intl.message(
      'Last Month',
      name: 't_1M',
      desc: '',
      args: [],
    );
  }

  /// `Last 3 Months `
  String get t_3M {
    return Intl.message(
      'Last 3 Months ',
      name: 't_3M',
      desc: '',
      args: [],
    );
  }

  /// `Last 6 Months `
  String get t_6M {
    return Intl.message(
      'Last 6 Months ',
      name: 't_6M',
      desc: '',
      args: [],
    );
  }

  /// `Last Year`
  String get t_1y {
    return Intl.message(
      'Last Year',
      name: 't_1y',
      desc: '',
      args: [],
    );
  }

  /// `More like this`
  String get more {
    return Intl.message(
      'More like this',
      name: 'more',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
