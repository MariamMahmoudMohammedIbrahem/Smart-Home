import '../commons.dart';

///*interaction with the hardware using json format**
void sendFrame(Map<String, dynamic> jsonFrame, String ipAddress, int port) {
  String frame = jsonEncode(jsonFrame);
  RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
      .then((RawDatagramSocket socket) {
    socket.broadcastEnabled = true;
    socket.send(frame.codeUnits, InternetAddress(ipAddress), port);
  });
}
void addOrUpdateDevice(List<Map<String, dynamic>> deviceList, Map<String, dynamic> newDevice, BuildContext context) {
  String key = 'mac_address';
  bool exists = false;

  // device is already stored in the list
  // edit only when changed and status is not empty
  for (int i = 0; i < deviceList.length; i++) {
    // if(deviceList[i]['status'] != '' && deviceList[i]['status'] != 'DOWNLOAD_NEW_FIRMWARE_START'&& deviceList[i]['status'] != 'DOWNLOAD_NEW_FIRMWARE_OK'&& deviceList[i]['status'] != 'DOWNLOAD_NEW_FIRMWARE_FAIL' && !deviceList[i]['status'].toString().startsWith('updating') && deviceList[i]['status'].toString() != 'OK'){
    //   deviceList[i]['status'] = 'updating_${double.parse('${deviceList[i]['status']}').toInt()}';
    // }
    print('${deviceList[i]}, $newDevice');
    if (deviceList[i][key] == newDevice[key]) {

      if(deviceList[i]['status'] != newDevice['status'] && newDevice['status'] != ''){
        deviceList[i] = newDevice;
        if(deviceList[i]['status'] == 'DOWNLOAD_NEW_FIRMWARE_OK'){
          deviceList[i]['status'] = '';
        }
      }
      else if(deviceList[i]['firmware_version'] != newDevice['firmware_version'] && newDevice['status'] == ''){
        deviceList[i] = newDevice;
        isConnectedToInternet().then((value) => {if(value){checkFirmwareUpdates(macVersion, Provider.of<AuthProvider>(context, listen: false).firmwareInfo!, context)}});
      }
      exists = true;
      continue;
    }
  }

  if (!exists) {
    deviceList.add(newDevice);
    isConnectedToInternet().then((value) => {if(value){checkFirmwareUpdates(macVersion, Provider.of<AuthProvider>(context, listen: false).firmwareInfo!, context)}});
  }
}
