
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega/constants.dart';
import 'package:mega/db/functions.dart';
import 'package:mega/ui/initial.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'help.dart';
Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
  // runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     // Rooms().startListen(context);
//     // return ChangeNotifierProvider(
//     //   create: (context) => AuthProvider(),
//     //   child: MaterialApp(
//     //     title: 'GlowGrid',
//     //     debugShowCheckedModeBanner: false,
//     //     theme: ThemeData(
//     //       colorScheme: ColorScheme.fromSeed(seedColor: currentColor),
//     //       useMaterial3: true,
//     //     ),
//     //     home: Consumer<AuthProvider>(
//     //       builder: (context, authProvider, _) {
//     //         return authProvider.firstTimeCheck
//     //             ? const WelcomePage() //opposite ||
//     //             : Rooms();
//     //       },
//     //     ),
//     //   ),
//     // );
//     return const Initial();
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,  // Apply the custom light theme
      darkTheme: darkTheme,  // Apply the custom dark theme
      themeMode: Provider.of<AuthProvider>(context).isDarkMode ?? false ? ThemeMode.dark : ThemeMode.light,
      title: 'GlowGrid',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: currentColor),
      //   useMaterial3: true,
      // ),
      home: const HomeScreen(),
    );
  }
}
/*class Mapper extends StatelessWidget {
  const Mapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isFirstTime
                ? const Rooms() //opposite ||
                : const WelcomePage();
          },
        ),
      ),
    );
  }
}*/

