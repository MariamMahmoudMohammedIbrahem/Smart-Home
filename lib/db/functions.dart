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
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

// class SwitchesProvider extends ChangeNotifier{
//   List switches = [false,false,false];
//
//   void setSwitch(int no, bool state) {
//     switches[no] = state;
//
//     notifyListeners();
//   }
// }

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  RawDatagramSocket? _socket;
  Color currentColor = Colors.transparent;

  factory SocketManager() {
    return _instance;
  }

  SocketManager._internal();

  void startListen(BuildContext context) {
    if (_socket != null) {
      return; // If the socket is already initialized, do nothing
    }

    print("Enter listen out");
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081).then((RawDatagramSocket socket) {
      _socket = socket;
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            String response = String.fromCharCodes(datagram.data);
            print('response out $response');
            if (response == "OK") {
              commandResponse = response;
            }
            else {
              try {
                Map<String, dynamic> jsonResponse = jsonDecode(response);
                commandResponse = jsonResponse['commands'];
                print('commandResponse is => $commandResponse');
                if (commandResponse == 'SWITCH_READ_OK') {
                }
                else if (commandResponse == 'UPDATE_OK') {
                  print('update-ok');
                  Provider.of<AuthProvider>(context, listen: false).setSwitch(macAddress, 'sw1', jsonResponse['sw0']);
                  Provider.of<AuthProvider>(context, listen: false).setSwitch(macAddress, 'sw2', jsonResponse['sw1']);
                  Provider.of<AuthProvider>(context, listen: false).setSwitch(macAddress, 'sw3', jsonResponse['sw2']);
                  Provider.of<AuthProvider>(context, listen: false).addingDevice('UPDATE_OK', jsonResponse);
                  currentColor = Color.fromRGBO(jsonResponse['red'], jsonResponse['green'], jsonResponse['blue'], 1.0);
                  print(currentColor);
                }
                else if (commandResponse == 'SWITCH_WRITE_OK') {
                }
                else if (commandResponse == 'RGB_READ_OK') {
                }
                else if (commandResponse == 'RGB_WRITE_OK') {
                }
                else if (commandResponse == 'MAC_ADDRESS_READ_OK') {
                  Provider.of<AuthProvider>(context, listen: false).addingDevice('MAC_ADDRESS_READ_OK', jsonResponse);
                }
                else if (commandResponse == 'WIFI_CONFIG_OK') {
                }
                else if (commandResponse == 'WIFI_CONFIG_FAIL') {
                }
                else if (commandResponse == 'WIFI_CONFIG_CONNECTING') {
                  Provider.of<AuthProvider>(context, listen: false).addingDevice('WIFI_CONFIG_CONNECTING', {});
                }
                else if (commandResponse == 'WIFI_CONFIG_MISSED_DATA') {
                }
                else if (commandResponse == 'WIFI_CONFIG_SAME') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("WIFI_CONFIG_SAME")));
                }
                else if (commandResponse == 'WIFI_CONNECT_CHECK_OK') {
                  Provider.of<AuthProvider>(context, listen: false).addingDevice('WIFI_CONNECT_CHECK_OK', {});
                  const snackBar = SnackBar(content: Text('Connected Successfully'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                else if (commandResponse == 'DEVICE_CONFIG_WRITE_OK') {
                  Provider.of<AuthProvider>(context, listen: false).addingDevice('DEVICE_CONFIG_WRITE_OK', jsonResponse);
                }
              }
              catch (e) {
                print('Error decoding JSON: $e');
              }
            }
          }
        }
      });
    });
  }

  void close() {
    _socket?.close();
    _socket = null;
  }
}

class AuthProvider extends ChangeNotifier {
  bool? _isFirstTime;

  bool _toggle = true;

  bool roomConfig = false;
  bool connectionSuccess = false;
  bool configured = false;
  bool readOnly = false;
  String macAddress = '';
  String deviceType = '';
  // String deviceLocation = '';
  String wifiSsid = '';
  String wifiPassword = '';

  bool get firstTimeCheck => _isFirstTime ?? true;

  bool get toggle => _toggle;
  // List switches = [false,false,false];

  void setSwitch(String macAddress, String dataKey, int state) {
    // switches[index] = state;
    for (var device in deviceStatus) {
      if (device['MacAddress'] == macAddress) {
        // Update the specific data key (data1, data2, or data3)
        device[dataKey] = state;
        print('device$device');
        break;
      }
    }
    notifyListeners();
  }
  Future<bool> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('first_time') ?? true;
    return prefs.getBool('first_time') ?? true;
  }
  Future<void> setFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    _isFirstTime = false;
    print('Set first time to: $_isFirstTime');
    notifyListeners();
  }
  void toggling(bool newValue) {
    _toggle = newValue;
    notifyListeners();
  }
  void addingDevice(String command, Map<String, dynamic> jsonResponse){
    switch (command){
      case 'MAC_ADDRESS_READ_OK':
        macAddress = jsonResponse['mac_address'];
        readOnly = true;
        break;
      case 'WIFI_CONFIG_CONNECTING':
        configured = true;
        break;
      case 'WIFI_CONNECT_CHECK_OK':
        connectionSuccess = true;
        break;
      case 'DEVICE_CONFIG_WRITE_OK':
        roomConfig = true;
        saved = true;
        break;
      case 'UPDATE_OK':
        deviceType = jsonResponse["device_type"];
        wifiSsid = jsonResponse["wifi_ssid"];
        wifiPassword = jsonResponse["wifi_password"];
        break;
    }
    notifyListeners();
  }
}
String getRoomName(IconData icon) {
  if (icon == Icons.living) {
    return 'Living Room';
  } else if (icon == Icons.bedroom_baby) {
    return 'Baby Bedroom';
  } else if (icon == Icons.bedroom_parent) {
    return 'Parent Bedroom';
  } else if (icon == Icons.kitchen) {
    return 'Kitchen';
  } else if (icon == Icons.bathroom) {
    return 'Bathroom';
  } else if (icon == Icons.dining) {
    return 'Dining Room';
  } else if (icon == Icons.desk) {
    return 'Desk';
  } else if (icon == Icons.local_laundry_service) {
    return 'Laundry Room';
  } else if (icon == Icons.garage) {
    return 'Garage';
  } else /* if (icon == Icons.camera_outdoor) */ {
    return 'Outdoor';
  }
}
IconData getIconName(String name) {
  if (name == 'Living Room') {
    return Icons.living;
  } else if (name == 'Baby Bedroom') {
    return Icons.bedroom_baby;
  } else if (name == 'Parent Bedroom') {
    return Icons.bedroom_parent;
  } else if (name == 'Kitchen') {
    return Icons.kitchen;
  } else if (name == 'Bathroom') {
    return Icons.bathroom;
  } else if (name == 'Dining Room') {
    return Icons.dining;
  } else if (name == 'Desk') {
    return Icons.desk;
  } else if (name == 'Laundry Room') {
    return Icons.local_laundry_service;
  } else if (name =='Garage') {
    return Icons.garage;
  } else /* if (icon =='Outdoor' ) */ {
    return Icons.camera_outdoor;
  }
}

Future<void> setCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('first_time', true);
}