import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega/constants.dart';
import 'package:mega/db/functions.dart';
import 'package:mega/todoey.dart';
import 'package:mega/udp.dart';
import 'package:mega/ui/rooms.dart';
import 'package:mega/ui/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'figuring.dart';

Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => SwitchesProvider(),
      child: const MyApp(),
    ),
  );
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Rooms().startListen(context);
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'GlowGrid',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: currentColor),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isFirstTime
                ?  Rooms() //opposite ||
                : const WelcomePage();
          },
        ),
      ),
    );
  }
}
class AuthProvider extends ChangeNotifier {
  bool _isFirstTime = true;

  bool _toggle = true;

  bool _roomConfig = false;
  bool _connectionSuccess = false;
  bool _configured = false;
  bool _readOnly = false;
  String _macAddress = '';
  String _deviceType = '';
  String _deviceLocation = '';
  String _wifiSsid = '';
  String _wifiPassword = '';

  bool get isFirstTime => _isFirstTime;

  bool get toggle => _toggle;

  bool get roomConfig => _roomConfig;
  bool get connectionSuccess => _connectionSuccess;
  bool get configured => _configured;
  bool get readOnly => _readOnly;
  String get macAddress => _macAddress;
  String get deviceType => _deviceType;
  String get deviceLocation => _deviceLocation;
  String get wifiSsid => _wifiSsid;
  String get wifiPassword => _wifiPassword;

  Future<void> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('first_time') ?? true;
    notifyListeners();
  }
  void toggling(bool newValue) {
    _toggle = newValue;
    notifyListeners();
  }
  void addingDevice(String command, Map<String, dynamic> jsonResponse){
    switch (command){
      case 'MAC_ADDRESS_READ_OK':
        _macAddress = jsonResponse['mac_address'];
        _readOnly = true;
        break;
      case 'WIFI_CONFIG_CONNECTING':
        _configured = true;
        break;
      case 'WIFI_CONNECT_CHECK_OK':
        _connectionSuccess = true;
        break;
      case 'DEVICE_CONFIG_WRITE_OK':
        _roomConfig = true;
        _deviceType = jsonResponse["device_type"];
        _deviceLocation = jsonResponse["device_location"];
        _wifiSsid = jsonResponse["wifi_ssid"];
        _wifiPassword = jsonResponse["wifi_password"];
        print('_deviceType$_deviceLocation');
        break;
    }
    notifyListeners();
  }
}
/*class Mapper extends StatelessWidget {
  const Mapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isFirstTime
                ? const Rooms() //opposite ||
                : const WelcomePage();
          },
        ),
      ),
    );
  }
}*/
