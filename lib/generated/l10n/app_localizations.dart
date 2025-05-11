import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'FilmRandomizer'**
  String get app_title;

  /// No description provided for @missing_title.
  ///
  /// In en, this message translates to:
  /// **'Title missing!'**
  String get missing_title;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'Error occured!'**
  String get error_occurred;

  /// No description provided for @film_created_error.
  ///
  /// In en, this message translates to:
  /// **'Error occured during creation!'**
  String get film_created_error;

  /// No description provided for @film_updated_error.
  ///
  /// In en, this message translates to:
  /// **'Error occured during update!'**
  String get film_updated_error;

  /// No description provided for @film_delete_error.
  ///
  /// In en, this message translates to:
  /// **'Error occured during deletion!'**
  String get film_delete_error;

  /// No description provided for @username_required.
  ///
  /// In en, this message translates to:
  /// **'Username is required!'**
  String get username_required;

  /// No description provided for @password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required!'**
  String get password_required;

  /// No description provided for @username_short.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 4 characters long'**
  String get username_short;

  /// No description provided for @password_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 4 characters long'**
  String get password_short;

  /// No description provided for @login_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in, check username and password!'**
  String get login_error;

  /// No description provided for @films_missing.
  ///
  /// In en, this message translates to:
  /// **'Films missing! Add some to get started.'**
  String get films_missing;

  /// No description provided for @film_created_successfully.
  ///
  /// In en, this message translates to:
  /// **'Film created successfully!'**
  String get film_created_successfully;

  /// No description provided for @film_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Film updated successfully!'**
  String get film_updated_successfully;

  /// No description provided for @film_delete_success.
  ///
  /// In en, this message translates to:
  /// **'Film deleted successfully!'**
  String get film_delete_success;

  /// No description provided for @film_marked_as_watched.
  ///
  /// In en, this message translates to:
  /// **'Film marked as watched!'**
  String get film_marked_as_watched;

  /// No description provided for @delete_confirmation_title.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get delete_confirmation_title;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @select_categories.
  ///
  /// In en, this message translates to:
  /// **'Select Categories'**
  String get select_categories;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @select_genres.
  ///
  /// In en, this message translates to:
  /// **'Select Genres'**
  String get select_genres;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @is_watched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get is_watched;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @register_action.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register_action;

  /// No description provided for @login_action.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_action;

  /// No description provided for @show_watched.
  ///
  /// In en, this message translates to:
  /// **'Show watched films'**
  String get show_watched;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @app_version.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get app_version;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @include_watched.
  ///
  /// In en, this message translates to:
  /// **'Include watched films'**
  String get include_watched;

  /// No description provided for @switch_include_mode.
  ///
  /// In en, this message translates to:
  /// **'Switch include/exclude mode'**
  String get switch_include_mode;

  /// No description provided for @goto_register.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get goto_register;

  /// No description provided for @goto_login.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get goto_login;

  /// No description provided for @login_page.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login_page;

  /// No description provided for @register_page.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get register_page;

  /// No description provided for @settings_page.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_page;

  /// No description provided for @edit_page.
  ///
  /// In en, this message translates to:
  /// **'Edit film'**
  String get edit_page;

  /// No description provided for @add_page.
  ///
  /// In en, this message translates to:
  /// **'Add new Film'**
  String get add_page;

  /// No description provided for @randomizer_page.
  ///
  /// In en, this message translates to:
  /// **'Randomizer'**
  String get randomizer_page;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @category_series.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get category_series;

  /// No description provided for @category_animation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get category_animation;

  /// No description provided for @category_cartoon.
  ///
  /// In en, this message translates to:
  /// **'Cartoon'**
  String get category_cartoon;

  /// No description provided for @category_film.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get category_film;

  /// No description provided for @category_anime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get category_anime;

  /// No description provided for @genre_action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get genre_action;

  /// No description provided for @genre_adventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get genre_adventure;

  /// No description provided for @genre_comedy.
  ///
  /// In en, this message translates to:
  /// **'Comedy'**
  String get genre_comedy;

  /// No description provided for @genre_drama.
  ///
  /// In en, this message translates to:
  /// **'Drama'**
  String get genre_drama;

  /// No description provided for @genre_thriller.
  ///
  /// In en, this message translates to:
  /// **'Thriller'**
  String get genre_thriller;

  /// No description provided for @genre_documentary.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get genre_documentary;

  /// No description provided for @genre_musical.
  ///
  /// In en, this message translates to:
  /// **'Musical'**
  String get genre_musical;

  /// No description provided for @genre_romance.
  ///
  /// In en, this message translates to:
  /// **'Romance'**
  String get genre_romance;

  /// No description provided for @genre_scifi.
  ///
  /// In en, this message translates to:
  /// **'Scifi'**
  String get genre_scifi;

  /// No description provided for @genre_crime.
  ///
  /// In en, this message translates to:
  /// **'Crime'**
  String get genre_crime;

  /// No description provided for @genre_fantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get genre_fantasy;

  /// No description provided for @genre_fiction.
  ///
  /// In en, this message translates to:
  /// **'Fiction'**
  String get genre_fiction;

  /// No description provided for @genre_detective.
  ///
  /// In en, this message translates to:
  /// **'Detective'**
  String get genre_detective;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
