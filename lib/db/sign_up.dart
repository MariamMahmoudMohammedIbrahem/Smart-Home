import 'package:flutter/material.dart';
import 'package:mega/udp.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>const SignUp(),),);
            },
            child: const Text(
              'Sign Up',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>const UDPScreen(),),);
            },
            child: const Text(
              'udp',
            ),
          ),
        ],
      ),
    );
  }
}
