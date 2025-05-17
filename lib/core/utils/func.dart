import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkIsLoggedIn() async {
  await Future.delayed(Duration(seconds: 3));
  final prefs = await SharedPreferences.getInstance();
  bool? isLoggedIn = prefs.getBool('isLoggedIn');
  return isLoggedIn ?? false;
}

Future<Map<String, dynamic>?> getUserDetail() async {
  final prefs = await SharedPreferences.getInstance();

  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  if (!isLoggedIn) return null;

  return {
    'uid': prefs.getString('userId') ?? '',
    'name': prefs.getString('userName') ?? '',
    'email': prefs.getString('userEmail') ?? '',
    'role': prefs.getString('userRole') ?? '',
    'profile_img': prefs.getString('userProfileImg') ?? '',
  };
}
