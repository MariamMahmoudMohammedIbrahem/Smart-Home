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

  // bool similarityCheck = false;
  // bool similarityDownload = false;
  // bool startedCheck = false;
  // bool startedDownload = false;
  // bool failedCheck = false;
  // bool failedDownload = false;
  // bool completedCheck = false;
  // bool completedDownload = false;
  double downloadedBytesSize = 0;
  double totalByteSize = 0;
  int downloadPercentage = 0;
  // bool updating = false;
  // String macFirmware = '';
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
    String command = jsonResponse['commands'];
    if(command.startsWith('DOWNLOAD_NEW_FIRMWARE_UPDATING')){
      RegExp regExp = RegExp(r'_(\d+)');
      List<RegExpMatch> matches = regExp.allMatches(command).toList();
      downloadedBytesSize = double.parse(matches[0].group(1)!);
      totalByteSize = double.parse(matches[1].group(1)!);
      double testingValue = downloadedBytesSize / totalByteSize * 100;
      downloadPercentage = testingValue.toInt();
      addOrUpdateDevice(macVersion,{'mac_address':jsonResponse['mac_address'], 'firmware_version': jsonResponse['firmware_version'], 'status': '${downloadPercentage.toDouble()}'}, context);
    }
    else{
      addOrUpdateDevice(macVersion,{'mac_address':jsonResponse['mac_address'], 'firmware_version': jsonResponse['firmware_version'], 'status': command}, context);
    }
    notifyListeners();
  }
}