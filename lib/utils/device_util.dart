import '../commons.dart';

///*interaction with the hardware using json format**
void sendFrame(Map<String, dynamic> jsonFrame, String ipAddress, int port) {
  print("sendFrame => $jsonFrame");
  print("$ipAddress, $port");
  String frame = jsonEncode(jsonFrame);
  RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
      .then((RawDatagramSocket socket) {
    socket.broadcastEnabled = true;
    socket.send(frame.codeUnits, InternetAddress(ipAddress), port);
  });
}
void addOrUpdateDevice(Map<String, dynamic> newDevice, BuildContext context) {
  String key = 'mac_address';
  bool exists = false;

  // device is already stored in the list
  // edit only when changed and status is not empty
  for (int i = 0; i < macVersion.length; i++) {
    if (macVersion[i][key] == newDevice[key]) {

      if(macVersion[i]['status'] != newDevice['status'] && newDevice['status'] != ''){
        macVersion[i] = newDevice;
        if(macVersion[i]['status'] == 'DOWNLOAD_NEW_FIRMWARE_OK'){
          macVersion[i]['status'] = '';
        }
      }
      else if(macVersion[i]['firmware_version'] != newDevice['firmware_version'] && newDevice['status'] == ''){
        macVersion[i] = newDevice;
        isConnectedToInternet().then((value) => {if(value){checkFirmwareUpdates(macVersion, Provider.of<AuthProvider>(context, listen: false).firmwareInfo!, context)}});
      }
      exists = true;
      continue;
    }
  }

  if (!exists) {
    macVersion.add(newDevice);
    isConnectedToInternet().then((value) => {if(value){checkFirmwareUpdates(macVersion, Provider.of<AuthProvider>(context, listen: false).firmwareInfo!, context)}});
  }
}
