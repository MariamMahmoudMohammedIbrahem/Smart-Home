
import 'package:flutter/material.dart';

import 'db/sqldb.dart';
SqlDb sqlDb = SqlDb();
var departmentMap = [];
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
///items list of all macAddress
List items = [];//retrieve from db
// ValueNotifier<List<String>> roomNames = ValueNotifier<List<String>>([]);
List<String> roomNames = [];
List<int>  roomIDs = [];
List<Map<String, dynamic>> deviceDetails = [];
List<Map<String, dynamic>> deviceStatus = [];
String macAddress = '';
List<String> leds = ['light lamp','light lamp','light lamp'];//couldn't know where should it be retrieved from
// List iconsSwitches = [Icons.lightbulb_circle_rounded,Icons.lightbulb_circle_rounded,Icons.lightbulb_circle_rounded];
// String selectedMacAddress = '';
// bool rgb = false;
/// *add_devices**
bool saved = false;
// final StreamController<bool> controller = StreamController<bool>();
String roomName = 'Living Room';
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
  Icons.living,
  Icons.bedroom_baby,
  Icons.bedroom_parent,
  Icons.kitchen,
  Icons.bathroom,
  Icons.dining,
  Icons.desk,
  Icons.local_laundry_service,
  Icons.garage,
  Icons.camera_outdoor,
];
IconData selectedIcon = Icons.living;