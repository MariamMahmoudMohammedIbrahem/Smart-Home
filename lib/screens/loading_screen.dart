import 'package:flutter/material.dart';
import 'package:mega/constants/constants.dart';
import 'package:mega/screens/rooms_screen.dart';
import 'package:mega/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';

import '../utils/functions.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF047424),
      body: Center(
        child: Image.asset(
          'assets/images/loading-animate.gif',
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<AuthProvider>(context, listen: false)
        .checkTheme();
    sqlDb.getAllApartments().then((value) => {

      sqlDb.getAllMacAddresses().then(
            (value) => WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<AuthProvider>(context, listen: false)
              .checkFirstTime()
              .then((_) {
            final firstTimeCheck =
                Provider.of<AuthProvider>(context, listen: false)
                    .firstTimeCheck;
            Future.delayed(const Duration(seconds: 5), () {
              if (firstTimeCheck) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoomsScreen(),
                  ),
                );
              }
            });
          });
        }),
      ),
    });
  }
}
