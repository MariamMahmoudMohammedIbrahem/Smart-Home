import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mega/constants.dart';

saveInDB(String collection) async {
  switch(collection){
    case 'Users':
      await FirebaseFirestore.instance
          .collection('Users')
          .doc('UserID')
          .set({
        'Name': "Mariam",
        'Email':"",
      }).then((value) => saved = true);
      break;
    case 'Devices':
      await FirebaseFirestore.instance
          .collection('Devices')
          .doc('MACAddress')
          .set({
        'Type': "Mariam",
        'Status':"",
      });
      break;
    case 'Homes':
      break;
    case 'UserDevice':
      break;
  }
}

retrieve(String collection) async {
  switch(collection){
    case 'Users':
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc('UserID')
          .get();
      break;
    case 'Devices':
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Devices')
          .doc('MACAddress')
          .get();
      break;
    case 'Homes':
      break;
    case 'UserDevice':
      break;
  }
}
/// *sign_in**
/*
Future<void> handleSignIn() async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      // Signed in successfully, get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential authResult =await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;
      if(user!=null){
        print('Signed in: ${user.displayName}');
      }
      else{
        print('error signing in');
      }
      // Now you can use this credential to sign in with Firebase
      // For example, you can use FirebaseAuth.signInWithCredential(credential)
    } else {
      print('User cancelled the sign-in process');
    }
  } catch (error) {
    print(error);
  }
}*/
Future<void> handleSignIn(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the Google credential
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      // Check if the user's email is verified
      if (user != null && !user.emailVerified) {
        // Send email verification
        await user.sendEmailVerification();
        // Display a message to the user to check their email for verification
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Please check your email to verify your account.'),
          ),
        );
      }

      // For demonstration purposes, navigate to Home screen after successful sign-in
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomeScreen()),
      // );
    } else {
      // User cancelled the sign-in process
      print('User cancelled sign-in');
    }
  } catch (error) {
    print('Error signing in: $error');
    // Handle error
  }
}
Future<void> handleSignOut() async {
  try {
    await googleSignIn.signOut();
    // After signing out, you can perform any other tasks if needed
    print('Signed out successfully');
  } catch (error) {
    print('Error signing out: $error');
    // Handle error
  }
}
