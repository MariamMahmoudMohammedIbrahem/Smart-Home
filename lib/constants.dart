
import 'package:flutter/material.dart';

import 'db/sqldb.dart';
SqlDb sqlDb = SqlDb();
// bool isFirstTime = true;
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
List<String> leds = ['ceiling','wall lamp','table lamp'];//couldn't know where should it be retrieved from
List iconsSwitches = [Icons.ac_unit,Icons.lightbulb_circle_outlined,Icons.charging_station, Icons.colorize];
// bool rgb = false;
/// *add_devices**
bool saved = false;
// final StreamController<bool> controller = StreamController<bool>();
String roomName = 'living Room';
///*auto_signin**
// late SharedPreferences prefs;
// String prefsPassword = '';
// String prefsEmail = '';
// String usernameAuto = '';
///*Rooms.dart**
// String initial = '';
// bool signedOut = true;
bool toggle = false;
bool loading = false;
///*udp.dart**
String name = '';
String password = '';
String responseAll = 'no ';
final formKey = GlobalKey<FormState>();
final TextEditingController nameController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
bool navigate = false;
var commandResponse = '';
List<IconData> iconsRooms = [
  Icons.living_sharp,
  Icons.bedroom_baby_sharp,
  Icons.bedroom_parent_sharp,
  Icons.kitchen_sharp,
  Icons.bathroom_sharp,
  Icons.dining_sharp,
  Icons.desk_sharp,
  Icons.local_laundry_service_sharp,
  Icons.garage_sharp,
  Icons.camera_outdoor_sharp,
];