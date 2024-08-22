import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mega/constants.dart';
import 'package:mega/db/functions.dart';
import 'package:mega/ui/rooms.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // @override
  // void initState() {
  //   // Provider.of<AuthProvider>(context, listen: false).checkFirstTime();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .07),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Image.asset(
                'images/light-control.gif',
              ),
            ),
            const Column(
              children: [
                AutoSizeText(
                  'Welcome to GlowGrid!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    // fontSize: 24,
                  ),
                  minFontSize: 22,
                  maxFontSize: 24,
                ),
                AutoSizeText(
                  'your ultimate LED lighting control solution! Effortlessly customize your space with vibrant colors and dynamic effects. Transform your home into a captivating oasis of light and ambiance. ',
                  // style: TextStyle(
                  //   fontSize: 20,
                  // ),
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
                        sqlDb
                            .insertDepartment('My Home')
                            .then((value) => sqlDb.getAllDepartments().then((value) {
                          final firstTimeCheck =
                              Provider.of<AuthProvider>(context, listen: false)
                                  .firstTimeCheck;
                          if (!firstTimeCheck) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Rooms()),
                            );
                          }
                        }));
                      });
                      // Navigator.pop(context);
                      // .then((value) =>
                      //     Provider.of<AuthProvider>(context, listen: false)
                      //         .checkFirstTime());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade900,
                      foregroundColor: Colors.pink.shade700,
                    ),
                    child: const AutoSizeText(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        // fontSize: 20,
                      ),
                      minFontSize: 18,
                      maxFontSize: 20,
                    ),
                  ),
                ),
                /*SizedBox(
                    width: width * .6,
                    child: ElevatedButton(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        // Provider.of<AuthProvider>(context, listen: false)
                        //     .checkFirstTime();
                        print(
                        Provider.of<AuthProvider>(context, listen: false).firstTimeCheck);
                        print('welcome page${prefs.getBool('first_time')}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade900,
                        foregroundColor: Colors.pink.shade700,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),*/
              ],
            ),
          ],
        ),
      ),
    );
  }
}
