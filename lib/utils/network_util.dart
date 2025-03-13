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
void startListeningForNetworkChanges() {
  Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> connectivityResults) async {
    print('Connectivity changed: $connectivityResults');

    final info = NetworkInfo();

    if (connectivityResults.contains(ConnectivityResult.wifi)) {
      // Get the Wi-Fi IP address
      String? wifiIP = await info.getWifiIP();
      if (wifiIP != null) {
        ip = modifyIP(wifiIP);
        print("Connected to Wi-Fi. IP Address: $wifiIP, Modified IP: $ip");
      }
    }
  });
}

String modifyIP(String ip) {
  List<String> parts = ip.split('.');
  parts[3] = '255'; // Replace the last segment
  return parts.join('.');
}