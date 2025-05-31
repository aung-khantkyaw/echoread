import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_my.dart';

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
    Locale('my')
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @about_us.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get about_us;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @add_another_audio_file.
  ///
  /// In en, this message translates to:
  /// **'Add another audio file'**
  String get add_another_audio_file;

  /// No description provided for @add_author.
  ///
  /// In en, this message translates to:
  /// **'Add Author'**
  String get add_author;

  /// No description provided for @add_book.
  ///
  /// In en, this message translates to:
  /// **'Add Book'**
  String get add_book;

  /// No description provided for @adding.
  ///
  /// In en, this message translates to:
  /// **'Adding . . . '**
  String get adding;

  /// No description provided for @audio_file.
  ///
  /// In en, this message translates to:
  /// **'Audio File'**
  String get audio_file;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'author'**
  String get author;

  /// No description provided for @author_name.
  ///
  /// In en, this message translates to:
  /// **'Author Name'**
  String get author_name;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'book'**
  String get book;

  /// No description provided for @book_count.
  ///
  /// In en, this message translates to:
  /// **'Book Count'**
  String get book_count;

  /// No description provided for @book_description.
  ///
  /// In en, this message translates to:
  /// **'Book Description'**
  String get book_description;

  /// No description provided for @book_name.
  ///
  /// In en, this message translates to:
  /// **'Book Name'**
  String get book_name;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirm_delete;

  /// No description provided for @confirm_deletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirm_deletion;

  /// No description provided for @currently_reading.
  ///
  /// In en, this message translates to:
  /// **'Currently Reading'**
  String get currently_reading;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account;

  /// No description provided for @delete_account_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get delete_account_confirm;

  /// No description provided for @delete_author.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this author?'**
  String get delete_author;

  /// No description provided for @delete_book.
  ///
  /// In en, this message translates to:
  /// **'Delete Book'**
  String get delete_book;

  /// No description provided for @delete_book_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this book?'**
  String get delete_book_confirm;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @ebook_file.
  ///
  /// In en, this message translates to:
  /// **'Ebook File'**
  String get ebook_file;

  /// No description provided for @email_address_change.
  ///
  /// In en, this message translates to:
  /// **'Email Address Change'**
  String get email_address_change;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @explore_authors.
  ///
  /// In en, this message translates to:
  /// **'Explore authors'**
  String get explore_authors;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @help_center.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get help_center;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @latest_books.
  ///
  /// In en, this message translates to:
  /// **'Latest Books'**
  String get latest_books;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @myHistory.
  ///
  /// In en, this message translates to:
  /// **'My History'**
  String get myHistory;

  /// No description provided for @my_library.
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get my_library;

  /// No description provided for @no_authors_found.
  ///
  /// In en, this message translates to:
  /// **'No authors found'**
  String get no_authors_found;

  /// No description provided for @no_books.
  ///
  /// In en, this message translates to:
  /// **'No books'**
  String get no_books;

  /// No description provided for @no_books_found.
  ///
  /// In en, this message translates to:
  /// **'No books found'**
  String get no_books_found;

  /// No description provided for @no_file_selected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get no_file_selected;

  /// No description provided for @password_reset.
  ///
  /// In en, this message translates to:
  /// **'Password Reset'**
  String get password_reset;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @save_book.
  ///
  /// In en, this message translates to:
  /// **'Save Book'**
  String get save_book;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @search_authors_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for authors'**
  String get search_authors_hint;

  /// No description provided for @search_books_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for books'**
  String get search_books_hint;

  /// No description provided for @select_author.
  ///
  /// In en, this message translates to:
  /// **'Select Author'**
  String get select_author;

  /// No description provided for @select_image.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get select_image;

  /// No description provided for @select_image_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose an image'**
  String get select_image_hint;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settings_screen.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get settings_screen;

  /// No description provided for @terms_of_service.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_of_service;

  /// No description provided for @unknown_author.
  ///
  /// In en, this message translates to:
  /// **'Unknown Author'**
  String get unknown_author;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @update_account.
  ///
  /// In en, this message translates to:
  /// **'Update Account'**
  String get update_account;

  /// No description provided for @update_author.
  ///
  /// In en, this message translates to:
  /// **'Update Author'**
  String get update_author;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating . . . '**
  String get updating;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @username_required.
  ///
  /// In en, this message translates to:
  /// **'Username Required'**
  String get username_required;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @enter_book_description.
  ///
  /// In en, this message translates to:
  /// **'Enter Book Description'**
  String get enter_book_description;

  /// No description provided for @select_an_author.
  ///
  /// In en, this message translates to:
  /// **'Select an Author'**
  String get select_an_author;

  /// No description provided for @enter_book_name.
  ///
  /// In en, this message translates to:
  /// **'Enter Book Name'**
  String get enter_book_name;

  /// No description provided for @update_book.
  ///
  /// In en, this message translates to:
  /// **'Update Book'**
  String get update_book;

  /// No description provided for @failed_to_update_book.
  ///
  /// In en, this message translates to:
  /// **'Failed to Update Book'**
  String get failed_to_update_book;

  /// No description provided for @book_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Book Updated Successfully'**
  String get book_updated_successfully;

  /// No description provided for @select_book_cover_hint.
  ///
  /// In en, this message translates to:
  /// **'Select Book Cover'**
  String get select_book_cover_hint;

  /// No description provided for @select_ebook_file_hint.
  ///
  /// In en, this message translates to:
  /// **'Select Ebook File'**
  String get select_ebook_file_hint;

  /// No description provided for @select_audio_file_hint.
  ///
  /// In en, this message translates to:
  /// **'Select Audio File'**
  String get select_audio_file_hint;

  /// No description provided for @select_author_hint.
  ///
  /// In en, this message translates to:
  /// **'Select an Author'**
  String get select_author_hint;

  /// No description provided for @validation_error.
  ///
  /// In en, this message translates to:
  /// **'Validation Error'**
  String get validation_error;

  /// No description provided for @audio_access_denied.
  ///
  /// In en, this message translates to:
  /// **'Audio Access Denied'**
  String get audio_access_denied;

  /// No description provided for @ebook_file_pick_error.
  ///
  /// In en, this message translates to:
  /// **'Ebook File Pick Error'**
  String get ebook_file_pick_error;

  /// No description provided for @no_ebook_file_selected.
  ///
  /// In en, this message translates to:
  /// **'No Ebook File Selected'**
  String get no_ebook_file_selected;

  /// No description provided for @image_access_denied.
  ///
  /// In en, this message translates to:
  /// **'Image Access Denied'**
  String get image_access_denied;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'my'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'my': return AppLocalizationsMy();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
