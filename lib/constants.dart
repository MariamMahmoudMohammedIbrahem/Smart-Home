
import 'package:flutter/material.dart';

import 'db/sqldb.dart';
SqlDb sqlDb = SqlDb();
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';
/// *sign_in**
// GoogleSignIn googleSignIn = GoogleSignIn();
// bool notFound = false;
bool eye = false;
// bool rememberPassword = false;
// String usernameRetrieved = '';
// String errorMessage = '';
Color currentColor = Colors.amber;
Map<String, dynamic> items = {
  // '00:F3:00:20:00:7A': 'livingRoom',
  // '08:3A:8D:D0:AA:20': 'babyRoom',
};//retrieve from db
List values = [];
List<String> leds = ['switch1','switch2','switch3'];//couldn't know where should it be retrieved from
List icons = [Icons.ac_unit,Icons.lightbulb_circle_outlined,Icons.charging_station, Icons.colorize];
// bool rgb = false;
/// *add_devices**
bool saved = false;
// final StreamController<bool> controller = StreamController<bool>();
String roomName = 'livingRoom';
///*auto_signin**
// late SharedPreferences prefs;
// String prefsPassword = '';
// String prefsEmail = '';
// String usernameAuto = '';
///*Rooms.dart**
// String initial = '';
// bool signedOut = true;
bool toggle = false;
///*udp.dart**
String name = '';
String password = '';
String responseAll = 'no ';
final formKey = GlobalKey<FormState>();
final TextEditingController nameController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
// bool configured = false;
// bool readOnly = false;
bool navigate = false;
// bool connectionSuccess = false;
// bool roomConfig = false;
var commandResponse = '';
// String macAddress = "";
// String deviceType ="";
// String deviceLocation ="";
// String wifiSsid ="";
// String wifiPassword ="";