import 'package:flutter/material.dart';
import 'package:mega/constants.dart';
import 'package:mega/ui/rooms.dart';
import 'package:mega/ui/welcome_page.dart';
import 'package:provider/provider.dart';

import '../db/functions.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    sqlDb.readData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
            MaterialPageRoute(builder: (context) => Rooms()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.pink.shade900,)),
    );
  }
}
