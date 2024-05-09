import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega/constants.dart';
import 'package:mega/db/sign_in.dart';
import 'package:mega/db/sign_up.dart';
import 'package:mega/ui/rooms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'db/auto_signin.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlowGrid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: currentColor),
        useMaterial3: true,
      ),
      home: const Mapper(),
    );
  }
}
class AuthProvider extends ChangeNotifier {
  bool _isFirstTime = true;
  bool _isLoggedIn = false;

  bool get isFirstTime => _isFirstTime;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('first_time') ?? true;
    notifyListeners();
  }

  Future<void> checkCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefsEmail = prefs.getString('email')!;
    prefsPassword = prefs.getString('password')!;
    _isLoggedIn = prefsEmail != null && prefsPassword != null;
    notifyListeners();
  }
}
class Mapper extends StatelessWidget {
  const Mapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isFirstTime
                ? const Rooms(userName: '',)
                : authProvider.isLoggedIn
                ? const AutoSignIn()
                : const SignUp();
          },
        ),
      ),
    );
  }
}
