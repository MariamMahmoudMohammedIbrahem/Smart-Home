import 'package:flutter/material.dart';
import 'package:mega/db/sign_in.dart';

import '../db/sign_up.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .07),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(child: Image.asset('images/light-control.gif',),),
              const Column(
                children: [
                  Text(
                    'Welcome to GlowGrid!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'your ultimate LED lighting control solution! Effortlessly customize your space with vibrant colors and dynamic effects. Transform your home into a captivating oasis of light and ambiance. ',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: width*.6,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignIn(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade900,
                        foregroundColor: Colors.pink.shade700,
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 20,),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width*.6,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUp(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade900,
                        foregroundColor: Colors.pink.shade700,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 20,),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}
