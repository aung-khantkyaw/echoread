import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/firebase_config.dart';
import 'core/widgets/custom_gif_loading.dart';
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

class EchoReadApp extends StatefulWidget {
  const EchoReadApp({super.key});

  static Future<void> toggleLocale(BuildContext context) async {
    final _EchoReadAppState? state = context.findAncestorStateOfType<_EchoReadAppState>();

    if (state != null) {
      final currentLocale = state._locale.languageCode;
      final newLocale = currentLocale == 'en' ? const Locale('my') : const Locale('en');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', newLocale.languageCode);

      state.setLocale(newLocale);
    }
  }


  @override
  State<EchoReadApp> createState() => _EchoReadAppState();
}

class _EchoReadAppState extends State<EchoReadApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('locale') ?? 'en';

    setState(() {
      _locale = Locale(languageCode);
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = 1.0;

    if (_locale.languageCode == 'my') {
      textScaleFactor = 0.9;
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: textScaleFactor),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EchoRead',
        theme: ThemeData(fontFamily: 'AncizarSerif'),
        locale: _locale,
        supportedLocales: const [
          Locale('en'),
          Locale('my'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
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
          return const GifLoader();
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
