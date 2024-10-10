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
    // Future.delayed(const Duration(seconds: 5 ),(){
      sqlDb.getAllApartments().then((value) =>
      {
        sqlDb.getAllMacAddresses().then((value) =>
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<AuthProvider>(context, listen: false)
            .checkTheme();
            Provider.of<AuthProvider>(context, listen: false)
                .checkFirstTime()
                .then((_) {
              final firstTimeCheck =
                  Provider.of<AuthProvider>(context, listen: false)
                      .firstTimeCheck;
              Future.delayed(const Duration(seconds: 3), () {
                if (firstTimeCheck) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomePage()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Rooms()),
                  );
                }
              });
            });
          }),),
        });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color(0xFF047424),
      body: Center(child: Image.asset('images/loading-animate.gif',),),
    );
  }
}
