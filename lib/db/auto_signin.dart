/*
import 'dart:ui';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mega/db/sign_in.dart';
import 'package:mega/ui/rooms.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';


class AutoSignIn extends StatefulWidget {
  const AutoSignIn({super.key});

  @override
  State<AutoSignIn> createState() => _AutoSignInState();
}

class _AutoSignInState extends State<AutoSignIn> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/light-control.gif'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('GlowGrid',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 55,color: Colors.brown.shade700,),),
                    const SizedBox(width: 15,),
                    Icon(Icons.mosque_sharp,size: 55,color: Colors.brown.shade700,),
                  ],
                ),
                const SizedBox(height: 30,),
                SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      color: Colors.brown.shade700,
                      strokeWidth: 10,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  */
/*void initState() {
    getStoredCredentials();
    super.initState();
  }*//*

  void signInWithEmailAndPassword() {

    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(
        email: prefsEmail,
        password: prefsPassword,
      ).then((value) async {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('user email', isEqualTo: prefsEmail)
            .get();
        usernameAuto = userSnapshot.docs.first.id;
      }).then((value) {
        if(usernameAuto.isNotEmpty){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const Rooms(userName: '',)));
        }
        else{

        }
      });
    } catch (e) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const SignIn()), (route) => false);
    }
  }
  */
/*void getStoredCredentials() async {
    prefs = await SharedPreferences.getInstance();
    prefsEmail = prefs.getString('email') ?? '';
    prefsPassword = prefs.getString('password') ?? '';
    checkStoredCredentials();
  }
  void checkStoredCredentials() {
    if (prefsEmail.isEmpty && prefsPassword.isEmpty) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const SignIn()), (route) => false);
    } else {
      // const AutoLogin();
      signInWithEmailAndPassword(prefsEmail, prefsPassword, rememberPassword);
    }
  }*//*

}*/
