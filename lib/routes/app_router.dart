import 'package:echoread/features/admin/presentation/screens/book_manage_screen.dart';
import 'package:echoread/features/library/presentation/screens/explore_screen.dart';
import 'package:flutter/material.dart';

import '../features/admin/presentation/widgets/download_history_screen.dart';
import '../features/auth/presentation/screens/registration_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/forget_password_screen.dart';

import '../features/user/presentation/screens/home_screen.dart';
import '../features/user/presentation/screens/my_library_screen.dart';
import '../features/user/presentation/screens/setting_screen.dart';

import '../features/library/presentation/screens/author_profile_screen.dart';
import '../features/library/presentation/screens/book_detail_screen.dart';

import '../features/admin/presentation/screens/admin_screen.dart';
import '../features/admin/presentation/screens/author_manage_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RegistrationPage.routeName:
        return MaterialPageRoute(builder: (_) => RegistrationPage());
      case LoginPage.routeName:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case ForgetPasswordPage.routeName:
        return MaterialPageRoute(builder: (_) => ForgetPasswordPage());

      case HomePage.routeName:
        return MaterialPageRoute(builder: (_) => HomePage());
      case ExplorePage.routeName:
        return MaterialPageRoute(builder: (_) => ExplorePage());
      case MyLibraryPage.routeName:
        return MaterialPageRoute(builder: (_) => MyLibraryPage());
      case SettingPage.routeName:
        return MaterialPageRoute(builder: (_) => SettingPage());

      case AdminPage.routeName:
        return MaterialPageRoute(builder: (_) => AdminPage());
      case AuthorManagePage.routeName:
        return MaterialPageRoute(builder: (_) => AuthorManagePage());
      case BookManagePage.routeName:
        return MaterialPageRoute(builder: (_) => BookManagePage());

      case DownloadHistoryScreen.routeName:
        return MaterialPageRoute(builder: (_) => DownloadHistoryScreen());
      case AuthorProfilePage.routeName:
        final args = settings.arguments as Map<String, dynamic>?;
        final authorId = args?['authorId'];
        return MaterialPageRoute(
          builder: (_) => AuthorProfilePage(
            key: ValueKey(authorId),
            authorId: authorId,
          ),
          settings: settings,
        );
      case BookDetailPage.routeName:
        final args = settings.arguments as Map<String, dynamic>?;
        final bookId = args?['bookId'];
        return MaterialPageRoute(
          builder: (_) => BookDetailPage(
            key: ValueKey(bookId),
            bookId: bookId,
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}