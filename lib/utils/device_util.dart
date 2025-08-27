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
void addOrUpdateDevice(Map<String, dynamic> newDevice, BuildContext context) {
  String key = 'mac_address';
  bool exists = false;
  // device is already stored in the list
  // edit only when changed and command is not empty
  for (int i = 0; i < macVersion.length; i++) {
    if (macVersion[i][key] == newDevice[key]) {
      macVersion[i]['time'] = newDevice['time'];
      if ((macVersion[i]['command'] ?? '') != (newDevice['command'] ?? '') && (newDevice['command'] ?? '').isNotEmpty) {
        macVersion[i] = newDevice;
        if (macVersion[i]['command'] == 'DOWNLOAD_NEW_FIRMWARE_OK') {
          macVersion[i]['command'] = '';
        }
      }

      if(macVersion[i]['firmware_version'] != newDevice['firmware_version'] && newDevice['command'] == ''){
        macVersion[i] = newDevice;
      }

      /// checks if the firmware changed for any device
      if (!(double.tryParse(newDevice['command'] ?? '') != null ||
          newDevice['command'] == 'DOWNLOAD_NEW_FIRMWARE_START')) {
        checkAllFirmwareUpdates(context);
      }

      exists = true;
      continue;
    }
  }
  if (!exists) {
    macVersion.add(newDevice);
  }
}
