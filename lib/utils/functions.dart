import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

import 'package:http/http.dart' as http;


void showSnack(BuildContext context, String message, String msg) {
  final currentTime = DateTime.now();

  print(snackBarCount);
  if (snackBarCount < maxSnackBarCount && (lastSnackBarTime == null || currentTime.difference(lastSnackBarTime!).inSeconds > 2)) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    lastSnackBarTime = currentTime;
    snackBarCount++;
  }
  if(snackBarCount == maxSnackBarCount){
    showHint(context, msg);
  }
}

void showHint(BuildContext context, String msg){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Hint'),
        content: Text(msg),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              if(currentStep == 0){
                Provider.of<AuthProvider>(context, listen: false).toggling('adding', false);
              }
              else if(currentStep == 2){
                snackBarCount = 0;
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
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
                print(response);
                print('commandResponse => $commandResponse');
                addOrUpdateDevice(macVersion,{'mac_address':jsonResponse['mac_address'], 'firmware_version': jsonResponse['firmware_version'], 'status': ''}, context);
                if (commandResponse == 'UPDATE_OK' || commandResponse == 'SWITCH_WRITE_OK' || commandResponse == 'SWITCH_READ_OK') {
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
                }
                else if (commandResponse == 'RGB_READ_OK' || commandResponse == 'RGB_WRITE_OK') {
                }
                else if (commandResponse == 'MAC_ADDRESS_READ_OK') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('MAC_ADDRESS_READ_OK', jsonResponse);
                }
                else if (commandResponse == 'WIFI_CONFIG_OK') {
                }
                else if (commandResponse == 'WIFI_CONFIG_FAILED') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('WIFI_CONFIG_FAILED', {});
                }
                else if (commandResponse == 'WIFI_CONFIG_CONNECTING' || commandResponse == 'WIFI_CONFIG_SAME') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('WIFI_CONFIG_CONNECTING', {});
                  if (commandResponse == 'WIFI_CONFIG_SAME') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Same Wi-Fi network data")));
                  }
                }
                else if (commandResponse == 'WIFI_CONFIG_MISSED_DATA') {
                }
                else if (commandResponse == 'WIFI_CONNECT_CHECK_OK') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('WIFI_CONNECT_CHECK_OK', {});
                  const snackBar =
                  SnackBar(content: Text('Connected Successfully'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                else if (commandResponse == 'DEVICE_CONFIG_WRITE_OK') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('DEVICE_CONFIG_WRITE_OK', jsonResponse);
                }
                else if (commandResponse == 'READ_OK') {}
                else if (commandResponse == 'CHECK_FOR_NEW_FIRMWARE_OK' ||
                    commandResponse == 'CHECK_FOR_NEW_FIRMWARE_FAIL' ||
                    commandResponse == 'CHECK_FOR_NEW_FIRMWARE_SAME' ||
                    commandResponse == 'DOWNLOAD_NEW_FIRMWARE_SAME' ||
                    commandResponse == 'DOWNLOAD_NEW_FIRMWARE_START' ||
                    commandResponse == 'DOWNLOAD_NEW_FIRMWARE_OK' ||
                    commandResponse == 'DOWNLOAD_NEW_FIRMWARE_FAIL' ||
                    commandResponse.contains('DOWNLOAD_NEW_FIRMWARE_UPDATING') ) {
                  print('updating......$commandResponse');
                  /*macVersion.add({
                    'MacAddress': jsonResponse['mac_address'],
                    'FirmwareVersion': jsonResponse['firmware_version'],
                  });
                  print('macVersion is => $macVersion');*/
                  // macVersion = [];
                  Provider.of<AuthProvider>(context, listen: false)
                      .firmwareUpdating(jsonResponse, context);
                }
                else{
                  print('else');
                  Provider.of<AuthProvider>(context, listen: false)
                    .firmwareUpdating(jsonResponse, context);}
              } catch (e) {
                print('error in catch $e');
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
  print(jsonFrame);
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
  bool _connecting = false;
  bool get isConnected => _connecting;
  bool _notification = false;
  bool get notificationMark => _notification;
  String? _firmwareVersion;
  String? get firmwareInfo => _firmwareVersion;

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
    if (dataType == 'connecting') {
      _connecting = newValue;
    }
    if(dataType == 'notification') {
      _notification = newValue;
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

  void updateFirmwareVersion (String newVersion){
    _firmwareVersion = newVersion;
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

  void firmwareUpdating(Map<String, dynamic> jsonResponse, BuildContext context) {
    similarityDownload = false;
    startedDownload = false;
    failedDownload = false;
    completedDownload = false;
    downloadPercentage = 0;
    macFirmware = jsonResponse['mac_address'];
    String command = jsonResponse['commands'];
    print('command......$command');
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
        addOrUpdateDevice(macVersion,{'mac_address':jsonResponse['mac_address'], 'firmware_version': jsonResponse['firmware_version'], 'status': 'DOWNLOAD_NEW_FIRMWARE_SAME'}, context);
        break;
      case 'DOWNLOAD_NEW_FIRMWARE_START':
        updating = true;
        startedDownload = true;
        addOrUpdateDevice(macVersion,{'mac_address':jsonResponse['mac_address'], 'firmware_version': jsonResponse['firmware_version'], 'status': 'DOWNLOAD_NEW_FIRMWARE_START'}, context);
        break;
      case 'DOWNLOAD_NEW_FIRMWARE_FAIL':
        failedDownload = true;
        addOrUpdateDevice(macVersion,{'mac_address':jsonResponse['mac_address'], 'firmware_version': jsonResponse['firmware_version'], 'status': 'DOWNLOAD_NEW_FIRMWARE_FAIL'}, context);
        break;
      case 'DOWNLOAD_NEW_FIRMWARE_OK':
        updating = false;
        completedDownload = true;
        addOrUpdateDevice(macVersion,{'mac_address':jsonResponse['mac_address'], 'firmware_version': jsonResponse['firmware_version'], 'status': 'DOWNLOAD_NEW_FIRMWARE_OK'}, context);
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
        print('testing value $testingValue, download percentage $downloadPercentage');
        addOrUpdateDevice(macVersion,{'mac_address':jsonResponse['mac_address'], 'firmware_version': jsonResponse['firmware_version'], 'status': 'updating_$downloadPercentage'}, context);
        if(downloadPercentage == 100){
          completedDownload = true;
          updating = false;
        }
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

void addOrUpdateDevice(List<Map<String, dynamic>> deviceList, Map<String, dynamic> newDevice, BuildContext context) {
  print('NEWDEVICE $newDevice');
  String key = 'mac_address';
  bool exists = false;

  // device is already stored in the list
  // edit only when changed and status is not empty
  for (int i = 0; i < deviceList.length; i++) {
    // print('deviceList[i] ${deviceList[i]}, newDevice[key] ${newDevice}');
    if(deviceList[i]['status'] != '' && deviceList[i]['status'] != 'DOWNLOAD_NEW_FIRMWARE_START'&& deviceList[i]['status'] != 'DOWNLOAD_NEW_FIRMWARE_OK'&& deviceList[i]['status'] != 'DOWNLOAD_NEW_FIRMWARE_FAIL' && !deviceList[i]['status'].toString().startsWith('updating')){
      // print("deviceList[i]['status'] => ${deviceList[i]['status']}");
      deviceList[i]['status'] = 'updating_${double.parse('${deviceList[i]['status']}').toInt()}';

    }
    if (deviceList[i][key] == newDevice[key]) {

       if(deviceList[i]['status'] != newDevice['status'] && newDevice['status'] != ''){
        print('status changing $newDevice');
        deviceList[i] = newDevice;
        if(deviceList[i]['status'] == 'DOWNLOAD_NEW_FIRMWARE_OK'){
          deviceList[i]['status'] = '';
        }
      }
      else if(deviceList[i]['firmware_version'] != newDevice['firmware_version'] && newDevice['status'] == ''){
        print('version changing');
        deviceList[i] = newDevice;
      }
      exists = true;
      continue;
    }
  }

  if (!exists) {
    deviceList.add(newDevice);
    checkFirmwareUpdates(macVersion, Provider.of<AuthProvider>(context, listen: false).firmwareInfo!, context);
    print('newDevice is $newDevice');
  }
  print('macVersion is => $macVersion');
}

///*check firmware version in firebase storage**
Future<String?> checkFirmwareVersion(
    String folderPath, String fileName, BuildContext context) async {
   bool isConnected = await isConnectedToInternet();
  if (!isConnected) {
    Provider.of<AuthProvider>(context, listen: false).toggling('connection', false);
    print('Provider of connection value ${Provider.of<AuthProvider>(context, listen:false).isConnected}');
    return '';
  }
  try {
    // Reference to the file in Firebase Storage (nested folder structure)
    Reference storageRef =
    FirebaseStorage.instance.ref().child('$folderPath/$fileName');

    // Download the file content as raw bytes (limit to 1 MB)
    final fileData = await storageRef.getData(1024 * 1024);

    if (fileData != null) {
      // Convert file data from bytes to string
      // setState(() {
      Provider.of<AuthProvider>(context, listen: false).updateFirmwareVersion(utf8.decode(fileData));
        // firmwareInfo = utf8.decode(fileData);
      // });
      if (kDebugMode) {
        print("File content: ${Provider.of<AuthProvider>(context, listen: false).firmwareInfo}");
      }
      return utf8.decode(fileData);
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error reading file from Firebase: $e");
    }
  }
  return null;
}

///*compare last version in devices with the version in the storage**
void checkFirmwareUpdates(List<Map<String, dynamic>> devices, String firmwareInfo, BuildContext context) {
  bool shouldToggleNotification = false;
  for (var device in devices) {
    if (device['firmware_version'] != firmwareInfo) {
      shouldToggleNotification = true;
      break;
    }
  }
  print('shouldToggleNotification $shouldToggleNotification');
  Provider.of<AuthProvider>(context, listen: false).toggling('notification', shouldToggleNotification);
}
