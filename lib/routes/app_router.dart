import 'package:flutter/material.dart';

import 'package:echoread/features/admin/presentation/screens/book_manage_screen.dart';
import 'package:echoread/features/admin/presentation/widgets/download_history_screen.dart';
import 'package:echoread/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:echoread/features/auth/presentation/screens/login_screen.dart';
import 'package:echoread/features/auth/presentation/screens/registration_screen.dart';

import 'package:echoread/features/user/presentation/screens/home_screen.dart';
import 'package:echoread/features/user/presentation/screens/my_library_screen.dart';
import 'package:echoread/features/user/presentation/screens/setting_screen.dart';

import 'package:echoread/features/library/presentation/screens/author_profile_screen.dart';
import 'package:echoread/features/library/presentation/screens/book_detail_screen.dart';
import 'package:echoread/features/library/presentation/screens/explore_screen.dart';

import 'package:echoread/features/admin/presentation/screens/admin_screen.dart';
import 'package:echoread/features/admin/presentation/screens/author_manage_screen.dart';

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

      case AdminPage.routeName:
        return MaterialPageRoute(builder: (_) => AdminPage());
      case AuthorManagePage.routeName:
        return MaterialPageRoute(builder: (_) => AuthorManagePage());
      case BookManagePage.routeName:
        return MaterialPageRoute(builder: (_) => BookManagePage());

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: const Color(0xFFFFF4ED),
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No route defined for ${settings.name}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'AncizarSerifBold',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 200,
                        height: 45,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("Go Back Home"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFE2C4),
                            foregroundColor: const Color(0xFF4B1E0A),
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );

    }
  }
}