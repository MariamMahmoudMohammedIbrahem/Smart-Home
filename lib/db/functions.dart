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
}*/

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
}*/
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
}*/

//validations for text form fields

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
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;
Future<void> uploadFile(File file) async {
  try {
    // Create a reference to the file location in Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('uploads/${file.path.split('/').last}');

    // Upload the file to Firebase Storage
    await storageRef.putFile(file);
    print('File uploaded successfully');
  } catch (e) {
    print('Error uploading file: $e');
  }
}
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
      return;
    }

    print("Enter listen out");
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081)
        .then((RawDatagramSocket socket) {
      _socket = socket;
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            String response = String.fromCharCodes(datagram.data);
            print('response out $response');
            if (response == "OK") {
              commandResponse = response;
            } else {
              try {
                Map<String, dynamic> jsonResponse = jsonDecode(response);
                commandResponse = jsonResponse['commands'];
                print('deviceStatus is => $deviceStatus');
                print('commandResponse is => $commandResponse');
                if (commandResponse == 'UPDATE_OK' ||
                    commandResponse == 'SWITCH_WRITE_OK' ||
                    commandResponse == 'SWITCH_READ_OK') {
                  print('update-ok');
                  if (deviceStatus.firstWhere(
                        (device) =>
                            device['MacAddress'] == jsonResponse['mac_address'],
                      )['sw1'] !=
                      jsonResponse['sw0']) {
                    print('code works correctly');
                    Provider.of<AuthProvider>(context, listen: false)
                        .setSwitch(macAddress, 'sw1', jsonResponse['sw0']);
                  }
                  if (deviceStatus.firstWhere(
                        (device) =>
                            device['MacAddress'] == jsonResponse['mac_address'],
                      )['sw2'] !=
                      jsonResponse['sw1']) {
                    Provider.of<AuthProvider>(context, listen: false)
                        .setSwitch(macAddress, 'sw2', jsonResponse['sw1']);
                    currentColor = Color.fromRGBO(jsonResponse['red'],
                        jsonResponse['green'], jsonResponse['blue'], 1.0);
                  }
                  if (deviceStatus.firstWhere(
                        (device) =>
                            device['MacAddress'] == jsonResponse['mac_address'],
                      )['sw3'] !=
                      jsonResponse['sw2']) {
                    Provider.of<AuthProvider>(context, listen: false)
                        .setSwitch(macAddress, 'sw3', jsonResponse['sw2']);
                  }
                  if (deviceStatus.firstWhere(
                        (device) =>
                            device['MacAddress'] == jsonResponse['mac_address'],
                      )['led'] !=
                      jsonResponse['led']) {
                    Provider.of<AuthProvider>(context, listen: false)
                        .setSwitch(macAddress, 'led', jsonResponse['led']);
                  }
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice(commandResponse, jsonResponse);
                  print(currentColor);
                } else if (commandResponse == 'RGB_READ_OK' ||
                    commandResponse == 'RGB_WRITE_OK') {
                  // Provider.of<AuthProvider>(context, listen: false).setSwitch(macAddress, 'sw2', jsonResponse['sw1']);
                  currentColor = Color.fromRGBO(jsonResponse['red'],
                      jsonResponse['green'], jsonResponse['blue'], 1.0);
                } else if (commandResponse == 'MAC_ADDRESS_READ_OK') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('MAC_ADDRESS_READ_OK', jsonResponse);
                } else if (commandResponse == 'WIFI_CONFIG_OK') {
                } else if (commandResponse == 'WIFI_CONFIG_FAIL') {
                } else if (commandResponse == 'WIFI_CONFIG_CONNECTING' ||
                    commandResponse == 'WIFI_CONFIG_SAME') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('WIFI_CONFIG_CONNECTING', {});
                  if (commandResponse == 'WIFI_CONFIG_SAME') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("WIFI_CONFIG_SAME")));
                  }
                } else if (commandResponse == 'WIFI_CONFIG_MISSED_DATA') {
                } else if (commandResponse == 'WIFI_CONNECT_CHECK_OK') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('WIFI_CONNECT_CHECK_OK', {});
                  const snackBar =
                      SnackBar(content: Text('Connected Successfully'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else if (commandResponse == 'DEVICE_CONFIG_WRITE_OK') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('DEVICE_CONFIG_WRITE_OK', jsonResponse);
                } else if (commandResponse == 'CHECK_FOR_NEW_FIRMWARE_OK' ||
                    commandResponse == 'CHECK_FOR_NEW_FIRMWARE_FAIL' ||
                    commandResponse == 'CHECK_FOR_NEW_FIRMWARE_SAME' ||
                    commandResponse == 'DOWNLOAD_NEW_FIRMWARE_SAME' ||
                    commandResponse == 'DOWNLOAD_NEW_FIRMWARE_START' ||
                    commandResponse
                        .contains('DOWNLOAD_NEW_FIRMWARE_UPDATING') ||
                    commandResponse == 'DOWNLOAD_NEW_FIRMWARE_OK' ||
                    commandResponse == 'DOWNLOAD_NEW_FIRMWARE_FAIL') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .firmwareUpdating(jsonResponse);
                } else if (commandResponse == 'READ_OK') {}
              } catch (e) {
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

void sendFrame(Map<String, dynamic> jsonFrame, String ipAddress, int port) {
  String frame = jsonEncode(jsonFrame);

  RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
      .then((RawDatagramSocket socket) {
    print(jsonFrame);
    socket.broadcastEnabled = true;
    socket.send(frame.codeUnits, InternetAddress(ipAddress), port);
  });
}

class AuthProvider extends ChangeNotifier {
  String? _isFirstTime;

  bool _toggle = true;
  bool _loading = false;
  bool get isLoading => _loading;
  bool roomConfig = false;
  bool connectionSuccess = false;
  bool configured = false;
  bool readOnly = false;
  String macAddress = '';
  String deviceType = '';
  String wifiSsid = '';
  String wifiPassword = '';
  String firmwareVersion = '';

  bool get firstTimeCheck => _isFirstTime?.isEmpty ?? true;

  bool get toggle => _toggle;

  void setSwitch(String macAddress, String dataKey, int state) {
    // switches[index] = state;
    print('device BEFORE$deviceStatus');
    for (var device in deviceStatus) {
      if (device['MacAddress'] == macAddress) {
        // Update the specific data key (data1, data2, or data3)
        //CHECK IF STATE IS THE SAME AS THE PREVIOUS
        device[dataKey] = state;
        print('device AFTER$device');
        break;
      }
    }
    notifyListeners();
  }

  Future<String?> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getString('first_time') ?? ''; // Return the saved string or an empty string if not set
    localFileName = prefs.getString('first_time') ?? '';
    return _isFirstTime;
  }

  Future<void> setFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Generate a 6-character random string
    String randomString = getRandomString(6);

    // Get the current time in microseconds
    int microseconds = DateTime.now().microsecondsSinceEpoch;

    // Combine the random string and microseconds
    String firstTimeValue = '$randomString$microseconds';

    // Save the concatenated string
    await prefs.setString('first_time', firstTimeValue);

    _isFirstTime = firstTimeValue;
    print('Set first time to: $_isFirstTime');

    notifyListeners();
  }

  void toggling(String dataType, bool newValue) {
    if (dataType == 'toggling') {
      _toggle = newValue;
    }
    if (dataType == 'loading') {
      _loading = newValue;
    }
    if (dataType == 'adding') {
      wifiPassword = '';
      wifiSsid = '';
      deviceType = '';
      macAddress = '';
      readOnly = newValue;
      configured = newValue;
      connectionSuccess = newValue;
      roomConfig = newValue;
    }
    notifyListeners();
  }

  void addingDevice(String command, Map<String, dynamic> jsonResponse) {
    switch (command) {
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
        firmwareVersion = jsonResponse["firmware_version"];
        break;
    }
    notifyListeners();
  }

  bool similarityCheck = false;
  bool similarityDownload = false;
  bool startedCheck = false;
  bool startedDownload = false;
  bool failedCheck = false;
  bool failedDownload = false;
  bool completedCheck = false;
  bool completedDownload = false;
  double downloadedBytesSize = 0;
  double totalByteSize = 0;
  int downloadPercentage = 0;
  bool updating = false;
  String macFirmware = '';
  void firmwareUpdating(Map<String, dynamic> jsonResponse) {
    similarityDownload = false;
    startedDownload = false;
    failedDownload = false;
    completedDownload = false;
    downloadPercentage = 0;
    macFirmware = jsonResponse['mac_address'];
    String command = jsonResponse['commands'];
    switch (command) {
      case 'CHECK_FOR_NEW_FIRMWARE_OK':
        completedCheck = true;
        break;
      case 'CHECK_FOR_NEW_FIRMWARE_SAME':
        similarityCheck = true;
        // macVersion[jsonResponse['mac_address']] = true;
        break;
      case 'CHECK_FOR_NEW_FIRMWARE_FAIL':
        failedCheck = true;
        break;
      case 'DOWNLOAD_NEW_FIRMWARE_SAME':
        similarityDownload = true;
        break;
      case 'DOWNLOAD_NEW_FIRMWARE_START':
        updating = true;
        startedDownload = true;
        break;
      case 'DOWNLOAD_NEW_FIRMWARE_FAIL':
        failedDownload = true;
        break;
      case 'DOWNLOAD_NEW_FIRMWARE_OK':
        updating = false;
        completedDownload = true;
        sqlDb.updateVersionByMacAddress(jsonResponse['mac_address'], jsonResponse['firmware_version']);
        break;
      default:
        RegExp regExp = RegExp(r'_(\d+)'); // Match all numbers preceded by an underscore
        List<RegExpMatch> matches = regExp.allMatches(command).toList();
        for (var match in matches) {
          print('Match: ${match.group(1)}'); // Print each matched number
        }
        downloadedBytesSize = double.parse(matches[0].group(1)!);
        totalByteSize = double.parse(matches[1].group(1)!);
        double testingValue = downloadedBytesSize / totalByteSize * 100;
        downloadPercentage = testingValue.toInt();
        if(downloadPercentage == 100){
          completedDownload = true;
          updating = false;
          sqlDb.updateVersionByMacAddress(jsonResponse['mac_address'], jsonResponse['firmware_version']);
        }
        print('downloaded $downloadPercentage');
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
  } else {
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
  } else if (name == 'Garage') {
    return Icons.garage;
  } else {
    return Icons.camera_outdoor;
  }
}

Future<void> setCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('first_time', true);
}

///*firebase_cloud**
Future<void> storeListOfIds(String documentId, List<String> ids) async {
  CollectionReference collection = FirebaseFirestore.instance.collection('your_collection_name');

  try {
    await collection.doc(documentId).set({
      'ids': ids,
    });
    print("List of IDs successfully stored!");
  } catch (e) {
    print("Error storing list of IDs: $e");
  }
}
Future<List<String>?> getListOfIds(String documentId) async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('your_collection_name').doc(documentId).get();

  if (snapshot.exists) {
    List<String> ids = List<String>.from(snapshot['ids']);
    return ids;
  }
  return null;
}

///*upload functions**
// Helper function to generate a random string of a given length
String getRandomString(int length) {
  const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  Random random = Random();
  return String.fromCharCodes(Iterable.generate(
    length, (_) => characters.codeUnitAt(random.nextInt(characters.length)),
  ));
}

String convertDataToJson(Map<String, dynamic> data) {
  return jsonEncode(data);
}

Future<void> saveJsonToFile(String jsonData) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$localFileName.json');

  // Upload the JSON file to Firebase (optional)
  // uploadDatabaseToFirebase();

  // Save the file locally
  await file.writeAsString(jsonData);
  print("JSON file saved to ${file.path}");
}


Future<Map<String, dynamic>> getLatestFirmwareInfo() async {
  final response = await http.get(Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/smart-home-aae4e.appspot.com/o/firmware-update%2Fswitch%2Ffirmware_version.txt?alt=media&token=43405f1e-187c-420c-8137-9fd34c9d566c'));
print('response $response');
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load latest firmware info');
  }
}
Future<bool> isConnectedToInternet() async {
  // Check connection type (Wi-Fi, mobile, etc.)
  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.none) {
    // No connection
    return false;
  }

  // Perform a simple ping to Google to verify actual internet access
  try {
    final response = await http.get(Uri.parse('https://www.google.com')).timeout(
      const Duration(seconds: 5),
    );

    if (response.statusCode == 200) {
      // Successfully connected to the internet
      return true;
    } else {
      // Server responded, but not reachable
      return false;
    }
  } catch (e) {
    // Couldn't reach the server, no internet
    return false;
  }
}