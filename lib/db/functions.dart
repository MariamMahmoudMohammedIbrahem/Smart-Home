/*
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:mega/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/rooms.dart';

*/
/*saveInDB(String collection) async {
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
}*//*

/// *sign_in**
*/
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
}*//*

*/
/*Future<void> loginUser(BuildContext context, String email, String password) async {
  try {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown.shade50,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.brown.shade700,),
            const SizedBox(height: 16.0),
            Text('logging in', style: TextStyle(fontSize: 17,color: Colors.brown.shade700),),
          ],
        ),
      ),
    );
    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).then((value) async {
      // Authentication successful
      if (rememberPassword) {
        // Store email and password securely
        await setCredentials(email, password);
      }
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('user email', isEqualTo: email)
          .get();
      usernameRetrieved = userSnapshot.docs.first.id;

      // Navigate to the next screen
      if (usernameRetrieved.isNotEmpty) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Rooms(userName: '',),
          ),
              (route) => false,
        );
      }
    }).catchError((exception) {
      // Handle errors from signInWithEmailAndPassword
      if (exception is FirebaseAuthException) {
        switch (exception.code) {
          case 'email-already-in-use':
            errorMessage = 'The email address is already in use by another account.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is invalid.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'The requested operation is not allowed.';
            break;
          case 'user-not-found':
            errorMessage = '"User not found. Please check your email and try again.';
            break;
          case 'wrong-password':
            errorMessage = 'Invalid password. Please try again.';
            break;
          case 'user-disabled':
            errorMessage = 'The user account has been disabled by an administrator.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many requests. Please try again later.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again later.';
        }
      } else {
        errorMessage = 'An error occurred. Please try again later.';
      }
      Navigator.pop(context);
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.brown.shade50,
          title: const Text(
            'Error',
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade600,
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      );
    });
  }
  catch (e) {
    // Hide loading dialog
    Navigator.pop(context);
    // Show error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown.shade50,
        title: const Text('Error', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),),
        content: const Text('Failed to login. Please Try Again' , style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
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
    bool googleSign = await googleSignIn.isSignedIn();
    if(googleSign){
      await googleSignIn.signOut();
    }
    else{
      try{
        FirebaseAuth.instance.signOut();
      }
      catch (error){
        print('Error While Signing Out');
      }
    }
    print('Signed out successfully');
  } catch (error) {
    print('Error signing out: $error');
  }
}
class SigningOut extends ChangeNotifier {
  bool _isSignedOut = true;

  bool get isSignedOut => _isSignedOut;

  Future<void> signOut() async {
    _isSignedOut = true;
    notifyListeners();
  }
}
Future<void> setCredentials(String email, String password) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('email', email);
  await prefs.setString('password', password);
}*//*

*/
/*void signInWithEmailAndPassword(
    String email, String password, bool rememberMe) {

  try {
    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).then((value) async {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('user email', isEqualTo: email)
          .get();
      usernameAuto = userSnapshot.docs.first.id;
    }).then((value) {
      if(usernameAuto.isNotEmpty){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const Rooms()));
      }
      else{

      }
    });
  } catch (e) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const SignIn()), (route) => false);
  }
}
void getStoredCredentials() async {
  prefs = await SharedPreferences.getInstance();
  prefsEmail = prefs.getString('email') ?? '';
  prefsPassword = prefs.getString('password') ?? '';
  checkStoredCredentials();
}
void checkStoredCredentials() {
  if (prefsEmail.isEmpty && prefsPassword.isEmpty) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const SignIn()), (route) => false);
  } else {
    signInWithEmailAndPassword(prefsEmail, prefsPassword, rememberPassword);
  }
}*//*

//validations for text form fields
*/
/*
bool isEmailValid(String email) {
  final RegExp emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  return emailRegex.hasMatch(email);
}

bool isPhoneValid(String number){
  final RegExp phoneRegex = RegExp(
    r'^01[0-9]{9}$',
  );
  return phoneRegex.hasMatch(number);
}

bool isUsernameValid(String username){
  final RegExp userNameRegex = RegExp(
    r'^[a-zA-Z0-9_]+$',
  );
  return userNameRegex.hasMatch(username);
}*/
import 'package:flutter/cupertino.dart';

class SwitchesProvider extends ChangeNotifier{
  List switches = [false,false,false];

  void setSwitch(int no, bool state) {
    switches[no] = state;

    notifyListeners();
  }
}
