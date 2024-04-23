import 'package:flutter/material.dart';
import 'package:mega/constants.dart';
import 'package:mega/udp.dart';
import 'package:mega/ui/room_info.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: currentColor),
        useMaterial3: true,
      ),
      home: const RoomDetail(room: 'office',),
    );
  }
}