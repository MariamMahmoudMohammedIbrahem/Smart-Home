import 'commons.dart';

Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authProvider = AuthProvider();
  await authProvider.checkTheme();


  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const GlowGrid(),
    ),
  );
}