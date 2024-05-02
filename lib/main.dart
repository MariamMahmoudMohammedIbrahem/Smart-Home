import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mega/constants.dart';
/*import 'package:mega/udp.dart';
import 'package:mega/ui/room_info.dart';
import 'package:mega/ui/rooms.dart';*/

import 'db/sign_in.dart';
import 'firebase_options.dart';

Future<void> main() async {
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: currentColor),
        useMaterial3: true,
      ),
      home: const SignIn(),
    );
  }
}