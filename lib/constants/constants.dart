import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import '../data/sqldb.dart';

///*multiple usage**
SqlDb sqlDb = SqlDb();
List<Map<String, dynamic>> apartmentMap = [];
var macMap = [];
bool eye = true;
Color currentColor = const Color(0xFF087424);
Color tempColor = currentColor;
List<String> roomNames = [];
List<int>  roomIDs = [];
List<Map<String, dynamic>> deviceDetails = [];
List<Map<String, dynamic>> deviceStatus = [];
String macAddress = '';
String roomName = 'Living Room';
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

///*device_configuration_screen.dart**
int currentStep = 0;
String name = '';
String password = '';
final formKey = GlobalKey<FormState>();
final TextEditingController nameController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
int snackBarCount = 0;
const int maxSnackBarCount = 3;
DateTime? lastSnackBarTime;
int pressCount = 0;

///*functions.dart**
var commandResponse = '';

///*import_data_screen.dart**
bool reformattingData = false;
String localFileName = '';
Timer? timer;

final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
late AnimationController controller;
late Animation<double> animation;
double progressValue = 0.0;
String displayMessage = "Starting download...";
int timeElapsed = 0;

///*main.dart**
// Custom Light Theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF047424),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF047424),
    secondary: Color(0xFF047424),
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  textTheme: TextTheme(
    bodyMedium: const TextStyle(color: Colors.black, fontSize: 16),
    bodySmall: TextStyle(color: Colors.grey[800]),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFF047424), // Set your desired cursor color here
    // selectionColor: Colors.blue, // Highlight color for selected text
    selectionHandleColor: Colors.green, // Color of the selection handle
  ),
  switchTheme: SwitchThemeData(
    splashRadius: 50.0,
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF609e51); // activeThumbColor
      }
      return Colors.grey.shade300; // inactiveThumbColor
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF047424); // activeTrackColor
      }
      return Colors.grey.shade800; // inactiveTrackColor
    }),
  ),
);

// Custom Dark Theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF047424),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF047424),
    onPrimary: Colors.white,
    secondary: Color(0xFF047424),
  ),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  textTheme: TextTheme(
    bodyMedium: const TextStyle(color: Colors.white, fontSize: 16),
    bodySmall: TextStyle(color: Colors.grey[300]),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFF047424), // Set your desired cursor color here
    // selectionColor: Colors.blue, // Highlight color for selected text
    selectionHandleColor: Colors.green, // Color of the selection handle
  ),
  switchTheme: SwitchThemeData(
    splashRadius: 50.0,
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF609e51); // activeThumbColor
      }
      return Colors.grey.shade300; // inactiveThumbColor
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF047424); // activeTrackColor
      }
      return Colors.grey.shade800; // inactiveTrackColor
    }),
  ),
);

///*room_details_screen.dart**
List ledInfo = ['light lamp', 'light lamp', 'RGB led', 'connection led'];
Timer? debounce;

///*export_data_screen.dart**
bool uploadFailed = false;
String? uploadStatus;
String downloadURL = '';
int uploadSteps = 0;
double uploadProgress = 0.0;

///*firmware_updating_screen.dart**
// String? firmwareInfo;
// String? version;
// String? info;
List<Map<String,dynamic>> macVersion = [];
bool failed = false;
Timer? timerPeriodic;

///*settings_screen.dart**
List<WifiNetwork?> wifiNetworks = [];