import 'package:flutter/material.dart';
import 'package:mega/db/sign_up.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(child: Column(children: [],),),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUp(),),);
            },
            child: const Text(
              'Login',
            ),
          ),
          ElevatedButton(
            onPressed: () {

            },
            child: const Text(
              'sign in with google',
            ),
          ),
        ],
      ),
    );
  }
}
