import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/firebase_config.dart';
import 'routes/app_router.dart';
import 'core/utils/func.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseConfig.webOptions,
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const EchoReadApp());
}

class EchoReadApp extends StatelessWidget {
  const EchoReadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EchoRead',
      // theme: ThemeData(fontFamily: ''),
      home: const SplashScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<bool> _isLoggedInFuture;

  @override
  void initState() {
    super.initState();
    _isLoggedInFuture = checkIsLoggedIn();
  }

  Future<void> _navigateBasedOnRole() async {
    final user = await getUserDetail();
    if (!mounted) return;

    final role = user?['role'] ?? '';

    if (role == 'admin') {
      Navigator.of(context).pushReplacementNamed('/admin');
    } else if (role == 'user') {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/unauthorized');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          if (snapshot.hasData && snapshot.data == true) {
            _navigateBasedOnRole();
          } else {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        });

        return const SizedBox.shrink();
      },
    );
  }
}
