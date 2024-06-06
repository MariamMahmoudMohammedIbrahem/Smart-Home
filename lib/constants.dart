
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
Map<String, String> items = {
  '00:F3:00:20:00:7A': 'livingRoom',
  '08:3A:8D:D0:AA:20': 'babyRoom',
};//retrieve from db
final List<String> values = items.values.toList();
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