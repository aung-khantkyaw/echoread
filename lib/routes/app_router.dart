import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/registration_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/forget_password_screen.dart';

import '../features/user/presentation/screens/home_screen.dart';
import '../features/user/presentation/screens/profile_screen.dart';

import '../features/admin/presentation/screens/admin_screen.dart';


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
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
