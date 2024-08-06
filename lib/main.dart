import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega/constants.dart';
import 'package:mega/db/functions.dart';
import 'package:mega/ui/initial.dart';
import 'package:mega/ui/rooms.dart';
import 'package:mega/ui/welcome_page.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'GlowGrid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: currentColor),
        useMaterial3: true,
      ),
      home: HomeScreen(),
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
