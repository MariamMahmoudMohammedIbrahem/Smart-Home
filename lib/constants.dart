
import 'dart:math';

import 'package:flutter/material.dart';

import 'db/sqldb.dart';
SqlDb sqlDb = SqlDb();
var random = Random();
int min = 49152;
int max = 65535;
List<Map<String, dynamic>> apartmentMap = [];
var macMap = [];
bool eye = true;
Color currentColor = const Color(0xFF087424);
Color tempColor = const Color(0xFF047424);     // Temporary color during interaction
// List<Map<String, int>> tempColor = [];     // Temporary color during interaction
///items list of all macAddress
List<String> roomNames = [];
List<int>  roomIDs = [];
List<Map<String, dynamic>> deviceDetails = [];
List<Map<String, dynamic>> deviceStatus = [];
String macAddress = '';
/// *add_devices**
// bool saved = false;
String roomName = 'Living Room';
///*udp.dart**
String name = '';
String password = '';
final formKey = GlobalKey<FormState>();
final TextEditingController nameController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
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
String barcodeScanRes = '';
bool reformattingData = false;
String localFileName = '';
bool startUpdate = false;
String? firmwareInfo;
String? version;
String? info;
// bool isDarkMode = false;
// Custom Light Theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF047424),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  textTheme: TextTheme(
    bodyText1: const TextStyle(color: Colors.black, fontSize: 16),
    bodyText2: TextStyle(color: Colors.grey[800]),
  ),
  switchTheme: SwitchThemeData(
    // thumbColor: MaterialStateProperty.all(Colors.blue),
    // trackColor: MaterialStateProperty.all(Colors.blue[200]),
  ),
);

// Custom Dark Theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF047424),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  textTheme: TextTheme(
    bodyText1: const TextStyle(color: Colors.white, fontSize: 16),
    bodyText2: TextStyle(color: Colors.grey[300]),
  ),
  switchTheme: SwitchThemeData(
    // thumbColor: MaterialStateProperty.all(Colors.deepPurple),
    // trackColor: MaterialStateProperty.all(Colors.deepPurple[200]),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    // backgroundColor: Colors.deepPurple,
  ),
);
List ledInfo = ['light lamp', 'light lamp', 'RGB led', 'connection led'];
bool uploadFailed = false;