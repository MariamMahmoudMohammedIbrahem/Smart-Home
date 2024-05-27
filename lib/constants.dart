
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';
/// *sign_in**
// GoogleSignIn googleSignIn = GoogleSignIn();
// bool notFound = false;
// bool eye = false;
// bool rememberPassword = false;
// String usernameRetrieved = '';
// String errorMessage = '';
Color currentColor = Colors.amber;
List<String> items = ['yhikeuw','yhikeuw','yhikeuw','yhikeuw','yhikeuw','yhikeuw','yhikeuw','yhikeuw','yhikeuw','yhikeuw','yhikeuw','yhikeuw'];//retrieve from db
List<String> leds = ['switch1','switch2','switch3','switch4'];//couldn't know where should it be retrieved from
List switches = [false,false,false,false];//couldn't know where should it be retrieved from
List icons = [Icons.ac_unit,Icons.lightbulb_circle_outlined,Icons.charging_station, Icons.colorize];
bool rgb = false;
/// *add_devices**
bool saved = false;
// final StreamController<bool> controller = StreamController<bool>();
String roomName = '';
///*auto_signin**
// late SharedPreferences prefs;
// String prefsPassword = '';
// String prefsEmail = '';
// String usernameAuto = '';
///*Rooms.dart**
// String initial = '';
// bool signedOut = true;
bool toggle = false;