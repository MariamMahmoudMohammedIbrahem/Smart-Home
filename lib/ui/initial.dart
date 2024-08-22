import 'package:flutter/material.dart';
import 'package:mega/constants.dart';
import 'package:mega/ui/rooms.dart';
import 'package:mega/ui/welcome_page.dart';
import 'package:provider/provider.dart';

import '../db/functions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    sqlDb.getAllDepartments().then((value) =>WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false)
          .checkFirstTime()
          .then((_) {
        final firstTimeCheck =
            Provider.of<AuthProvider>(context, listen: false).firstTimeCheck;
        if (firstTimeCheck) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Rooms()),
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const RoomDetail(roomName: 'living Room', macAddress: '84:F3:EB:20:8C:7A')),
          );
        }
      });
    }),);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.pink.shade900,)),
    );
  }
}
