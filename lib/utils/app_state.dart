import '../commons.dart';

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

  double downloadedBytesSize = 0;
  double totalByteSize = 0;
  int downloadPercentage = 0;
  bool _notification = false;
  bool get notificationMark => _notification;
  String? _firmwareVersion;
  String? get firmwareInfo => _firmwareVersion;

  bool _wifiConnected = false;
  bool get wifiConnected => _wifiConnected;
  bool _deviceConnected = false;
  bool get isDeviceConnected => _deviceConnected;

  bool _socketBindFailed = false;

  bool get socketBindFailed => _socketBindFailed;

  void setSocketBindFailed(bool value) {
    _socketBindFailed = value;
    notifyListeners();
  }
  void setSwitch(String macAddress, void Function(DeviceStatus device) updateFn) {
    for (var device in deviceStatus) {
      if (device.macAddress == macAddress) {
        updateFn(device);
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
    if (dataType == "internetStatus") {
      _wifiConnected = newValue;
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
    String command = jsonResponse['commands'];
    if(command.startsWith('DOWNLOAD_NEW_FIRMWARE_UPDATING')){
      RegExp regExp = RegExp(r'_(\d+)');
      List<RegExpMatch> matches = regExp.allMatches(command).toList();
      downloadedBytesSize = double.parse(matches[0].group(1)!);
      totalByteSize = double.parse(matches[1].group(1)!);
      double testingValue = downloadedBytesSize / totalByteSize * 100;
      downloadPercentage = testingValue.toInt();
      addOrUpdateDevice({'mac_address':jsonResponse['mac_address'], 'firmware_version': jsonResponse['firmware_version'], 'command': '${downloadPercentage.toDouble()}', 'time': DateTime.now()
        ,'isConnected': true,}, context);
    }
    else{
      addOrUpdateDevice({'mac_address':jsonResponse['mac_address'], 'firmware_version': jsonResponse['firmware_version'], 'command': command, 'time': DateTime.now(),
        'isConnected': true,}, context);
    }
    notifyListeners();
  }

  void checkingStatus (String macAddress) {
      // Find the map with matching MAC address
      final entry = macVersion.firstWhere(
            (item) => item['mac_address'] == macAddress,
        orElse: () => {}, // Return empty map if not found
      );

      // If no matching entry found, return false
      if (entry.isEmpty || entry['time'] == null) {
        _deviceConnected = false;
      }

      // Parse the stored time
      final DateTime storedTime = DateTime.parse(entry['time'].toString());

      // Calculate difference
      final Duration diff = DateTime.now().difference(storedTime);

      // Return whether >= 30 seconds passed
      _deviceConnected =  diff.inSeconds >= 30?false:true;
      notifyListeners();
  }

  Timer? _timer;

  AuthProvider() {
    // Check every second
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _updateConnectionStatuses();
    });
  }

  List<Map<String, dynamic>> get devices => macVersion;

  void _updateConnectionStatuses() {
    final now = DateTime.now();

    for (var device in macVersion) {
      final lastSeen = DateTime.parse(device['time'].toString());
      final diff = now.difference(lastSeen).inSeconds;
      device['isConnected'] = diff <= 30;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}