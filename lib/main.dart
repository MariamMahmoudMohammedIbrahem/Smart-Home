import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega/constants/constants.dart';
import 'package:mega/utils/functions.dart';
import 'package:mega/screens/loading_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    checkFirmwareVersion('firmware-update/switch', 'firmware_version.txt', context);
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<AuthProvider>(context).isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      title: 'GlowGrid',
      debugShowCheckedModeBanner: false,
      home: const LoadingScreen(),
    );
  }
}
