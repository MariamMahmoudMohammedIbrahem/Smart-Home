import '../commons.dart';

class NetworkService {
  Timer? _internetCheckTimer;

  void startMonitoring(BuildContext context) {
    _listenToConnectivityChanges(context);
    _startPeriodicInternetCheck(context);
  }

  void _listenToConnectivityChanges(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {

      if (results.contains(ConnectivityResult.wifi)) {
        String? wifiIP = await getLocalIpByInterface();
        if (wifiIP != null) {
          ip = modifyIP(wifiIP);
        }
      }
    });
  }

  void _startPeriodicInternetCheck(BuildContext context) {
    _internetCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      bool isOnline = await _hasInternetAccess();
      Provider.of<AuthProvider>(context, listen: false).toggling("internetStatus", isOnline);
      if(isOnline) checkFirmwareVersion('firmware-update/switch', 'firmware_version.txt', context);
    });
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void stopMonitoring() {
    _internetCheckTimer?.cancel();
  }
}

Future<String?> getLocalIpByInterface() async{
  for(var interface in await NetworkInterface.list()){
    if(interface.name.contains("wlan") || interface.name.contains("en")){
      for(var addr in interface.addresses) {
        if(addr.type == InternetAddressType.IPv4) {
          return addr.address;
        }
      }
    }
  }
  return null;
}

String modifyIP(String ip) {
  List<String> parts = ip.split('.');
  parts[3] = '255'; // Replace the last segment
  return parts.join('.');
}

Future<void> getWifiNetworks() async {
  List<WifiNetwork?> networks = await WiFiForIoTPlugin.loadWifiList();
  wifiNetworks = networks
      .where((network) => network != null && (network.frequency ?? 0) < 3000)
      .toList();

  wifiNetworks = networks;
}
