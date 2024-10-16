import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

import 'package:http/http.dart' as http;


void showSnack(BuildContext context, String message) {
  final currentTime = DateTime.now();

  if (snackBarCount < maxSnackBarCount && (lastSnackBarTime == null || currentTime.difference(lastSnackBarTime!).inSeconds > 2)) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    lastSnackBarTime = currentTime;
    snackBarCount++;
  }
}

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  RawDatagramSocket? _socket;

  factory SocketManager() {
    return _instance;
  }

  SocketManager._internal();

  void startListen(BuildContext context) {
    if (_socket != null) {
      return;
    }

    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081)
        .then((RawDatagramSocket socket) {
      _socket = socket;
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            String response = String.fromCharCodes(datagram.data);
            if (response == "OK") {
              commandResponse = response;
            } else {
              try {
                Map<String, dynamic> jsonResponse = jsonDecode(response);
                commandResponse = jsonResponse['commands'];
                if (commandResponse == 'UPDATE_OK' ||
                    commandResponse == 'SWITCH_WRITE_OK' ||
                    commandResponse == 'SWITCH_READ_OK') {
                  if (deviceStatus.firstWhere(
                        (device) =>
                    device['MacAddress'] == jsonResponse['mac_address'],
                  )['sw1'] !=
                      jsonResponse['sw0']) {
                    Provider.of<AuthProvider>(context, listen: false).setSwitch(
                        jsonResponse['mac_address'],
                        'sw1',
                        jsonResponse['sw0']);
                  }
                  if (deviceStatus.firstWhere(
                        (device) =>
                    device['MacAddress'] == jsonResponse['mac_address'],
                  )['sw2'] !=
                      jsonResponse['sw1']) {
                    Provider.of<AuthProvider>(context, listen: false).setSwitch(
                        jsonResponse['mac_address'],
                        'sw2',
                        jsonResponse['sw1']);
                  }
                  if (deviceStatus.firstWhere(
                        (device) =>
                    device['MacAddress'] == jsonResponse['mac_address'],
                  )['sw3'] !=
                      jsonResponse['sw2']) {
                    Provider.of<AuthProvider>(context, listen: false).setSwitch(
                        jsonResponse['mac_address'],
                        'sw3',
                        jsonResponse['sw2']);
                  }
                  if (deviceStatus.firstWhere(
                        (device) =>
                    device['MacAddress'] == jsonResponse['mac_address'],
                  )['led'] !=
                      jsonResponse['led']) {
                    Provider.of<AuthProvider>(context, listen: false).setSwitch(
                        jsonResponse['mac_address'],
                        'led',
                        jsonResponse['led']);
                  }
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice(commandResponse, jsonResponse);
                } else if (commandResponse == 'RGB_READ_OK' ||
                    commandResponse == 'RGB_WRITE_OK') {
                } else if (commandResponse == 'MAC_ADDRESS_READ_OK') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('MAC_ADDRESS_READ_OK', jsonResponse);
                } else if (commandResponse == 'WIFI_CONFIG_OK') {
                } else if (commandResponse == 'WIFI_CONFIG_FAILED') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('WIFI_CONFIG_FAILED', {});
                } else if (commandResponse == 'WIFI_CONFIG_CONNECTING' ||
                    commandResponse == 'WIFI_CONFIG_SAME') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('WIFI_CONFIG_CONNECTING', {});
                  if (commandResponse == 'WIFI_CONFIG_SAME') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Same Wi-Fi network data")));
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
                } else if (commandResponse == 'READ_OK') {}
              } catch (e) {}
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
    socket.broadcastEnabled = true;
    socket.send(frame.codeUnits, InternetAddress(ipAddress), port);
  });
}

class AuthProvider extends ChangeNotifier {
  String? _isFirstTime;

  bool _toggle = true;
  bool _isDarkMode = false;
  bool _loading = false;
  bool get isLoading => _loading;
  bool roomConfig = false;
  bool connectionSuccess = false;
  bool configured = false;
  bool connectionFailed = false;
  bool readOnly = false;
  String macAddress = '';
  String deviceType = '';
  String wifiSsid = '';
  String wifiPassword = '';
  bool get firstTimeCheck => _isFirstTime?.isEmpty ?? true;

  bool get toggle => _toggle;
  bool get isDarkMode => _isDarkMode;

  void setSwitch(String macAddress, String dataKey, int state) {
    for (var device in deviceStatus) {
      if (device['MacAddress'] == macAddress) {
        device[dataKey] = state;
        break;
      }
    }
    notifyListeners();
  }

  Future<void> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getString('first_time') ?? '';
    localFileName = _isFirstTime!;
  }

  Future<void> setFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String randomString = getRandomString(6);
    int microseconds = DateTime.now().microsecondsSinceEpoch;
    String firstTimeValue = '$randomString$microseconds';
    localFileName = firstTimeValue;
    await prefs.setString('first_time', firstTimeValue);
    _isFirstTime = firstTimeValue;

    notifyListeners();
  }

  Future<void> checkTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_theme') ?? false;

    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = isDark;
    await prefs.setBool('dark_theme', isDark);
    notifyListeners();
  }

  void toggling(String dataType, bool newValue) {
    if (dataType == 'toggling') {
      _toggle = newValue;
    }
    if (dataType == 'darkMode') {
      _isDarkMode = newValue;
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
        connectionFailed = false;
        break;
      case 'WIFI_CONFIG_FAILED':
        connectionFailed = true;
        break;
      case 'WIFI_CONNECT_CHECK_OK':
        connectionSuccess = true;
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

///*functions.dart**
String getRandomString(int length) {
  const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  Random random = Random();
  return String.fromCharCodes(Iterable.generate(
    length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
  ));
}

///*sqldb.dart**
String convertDataToJson(Map<String, dynamic> data) {
  return jsonEncode(data);
}

Future<void> saveJsonToFile(String jsonData) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$localFileName.json');
  await file.writeAsString(jsonData);
}

///*export_data_screen.dart**
Future<bool> isConnectedToInternet() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.first == ConnectivityResult.none) {
    return false;
  }

  try {
    final response =
    await http.get(Uri.parse('https://www.google.com')).timeout(
      const Duration(seconds: 5),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<void> deleteSpecificFile(String fileName) async {
  try {
    final Reference storageRef =
    FirebaseStorage.instance.ref().child('databases/');
    final ListResult result = await storageRef.listAll();

    for (var item in result.items) {
      if (item.name.contains(fileName)) {
        try {
          await item.delete();
        } catch (e) {}
      } else {}
    }
  } catch (e) {}
}


Future<File?> getLocalDatabaseFile() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final dbFile = File('${directory.path}/$localFileName.json');
    if (await dbFile.exists()) {
      return dbFile;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

///*import_data_screen.dart**
Future<void> deleteOldFiles() async {
  try {
    final Reference storageRef =
    FirebaseStorage.instance.ref().child('databases/');
    final ListResult result = await storageRef.listAll();
    final now = DateTime.now().millisecondsSinceEpoch;
    const oneHourInMs = 60 * 60;

    for (var item in result.items) {
      final metadata = await item.getMetadata();
      final uploadTimeStr = metadata.customMetadata?['uploadTime'];

      if (uploadTimeStr != null) {
        try {
          final uploadTime =
              DateTime.parse(uploadTimeStr).millisecondsSinceEpoch;

          if (now - uploadTime > oneHourInMs) {
            await item.delete();
          }
        } catch (e) {}
      } else {}
    }
  } catch (e) {}
}


final List<Map<String, dynamic>> messages = [
  {"time": 2, "message": "Preparing files..."},
  {"time": 5, "message": "Downloading..."},
  {"time": 8, "message": "Almost there..."},
  {"time": 10, "message": "Download complete!"}
];
