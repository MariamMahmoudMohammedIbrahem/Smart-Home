import 'package:http/http.dart' as http;
import '../commons.dart';

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

///*retrieve the ip based on the current connected network**
void startListeningForNetworkChanges(BuildContext context) {
  Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> connectivityResults) async {
    print('Connectivity changed: $connectivityResults');

    if(connectivityResults.contains(ConnectivityResult.none)){
      Provider.of<AuthProvider>(context, listen: false).toggling("internetStatus", false);
    }
    else {
      Provider.of<AuthProvider>(context, listen: false).toggling("internetStatus", true);
    }
    if (connectivityResults.contains(ConnectivityResult.wifi)) {
      // Get the Wi-Fi IP address
      String? wifiIP = await getLocalIpByInterface();
      if (wifiIP != null) {
        ip = modifyIP(wifiIP);
      }
    }
  });
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
  print("here inside getWifiNetworks");
  List<WifiNetwork?> networks = await WiFiForIoTPlugin.loadWifiList();
  wifiNetworks = networks
      .where((network) => network != null && (network.frequency ?? 0) < 3000)
      .toList();

  wifiNetworks = networks;
}
