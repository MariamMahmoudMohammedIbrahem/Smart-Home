import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mega/constants/constants.dart';
import 'package:mega/utils/functions.dart';
import 'package:mega/screens/rooms_screen.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * .07,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Image.asset(
                'images/light-control-light.gif',
              ),
            ),
            const Column(
              children: [
                AutoSizeText(
                  'Welcome to GlowGrid!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  minFontSize: 22,
                  maxFontSize: 24,
                ),
                AutoSizeText(
                  'your ultimate LED lighting control solution! Effortlessly customize your space with vibrant colors and dynamic effects. Transform your home into a captivating oasis of light and ambiance. ',
                  textAlign: TextAlign.center,
                  minFontSize: 18,
                  maxFontSize: 20,
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: width * .6,
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false)
                          .setFirstTime()
                          .then((value) {
                        sqlDb.insertApartment('My Home').then(
                                (value) => sqlDb.getAllApartments().then((value) {
                              final firstTimeCheck =
                                  Provider.of<AuthProvider>(context,
                                      listen: false)
                                      .firstTimeCheck;
                              if (!firstTimeCheck) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RoomsScreen(),
                                  ),
                                );
                              }
                            }));
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF087424),
                      foregroundColor: const Color(0xFF609e51),
                    ),
                    child: const AutoSizeText(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      minFontSize: 18,
                      maxFontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
