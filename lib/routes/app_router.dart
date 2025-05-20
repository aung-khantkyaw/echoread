import 'package:echoread/features/admin/presentation/screens/book_manage_screen.dart';
import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/registration_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/forget_password_screen.dart';

import '../features/user/presentation/screens/home_screen.dart';
import '../features/user/presentation/screens/profile_screen.dart';
import '../features/user/presentation/screens/author_list_screen.dart';
import '../features/user/presentation/screens/author_book_screen.dart';
import '../features/user/presentation/screens/book_detail_screen.dart'; // Import the new screen

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
      case ProfilePage.routeName:
        return MaterialPageRoute(builder: (_) => ProfilePage());
      case AdminPage.routeName:
        return MaterialPageRoute(builder: (_) => AdminPage());
      case AuthorManagePage.routeName:
        return MaterialPageRoute(builder: (_) => AuthorManagePage());
      case BookManagePage.routeName:
        return MaterialPageRoute(builder: (_) => BookManagePage());
      case AuthorListScreen.routeName:
        return MaterialPageRoute(builder: (_) => AuthorListScreen());
      case AuthorBookScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AuthorBookScreen(key: ValueKey(args?['authorId']),),
          settings: settings,
        );
      case BookDetailScreen.routeName: // New Route Case
        final args = settings.arguments as String?; // Expecting bookId as a String
        return MaterialPageRoute(
          builder: (_) => BookDetailScreen(key: ValueKey(args)), // Pass bookId as key
          settings: settings, // Pass settings to retain arguments
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