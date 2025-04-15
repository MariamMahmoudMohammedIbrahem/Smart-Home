import '../commons.dart';

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
              // if(deviceStatus.isNotEmpty) {
                try {
                  Map<String, dynamic> jsonResponse = jsonDecode(response);
                  print('jsonResponse $jsonResponse');
                  commandResponse = jsonResponse['commands'];
                  addOrUpdateDevice(macVersion,{'mac_address':jsonResponse['mac_address'], 'firmware_version': jsonResponse['firmware_version'], 'status': ''}, context);
                  if (commandResponse == 'UPDATE_OK' ||
                      commandResponse == 'SWITCH_WRITE_OK' ||
                      commandResponse == 'SWITCH_READ_OK') {
                    if(deviceStatus.isNotEmpty) {
                      if (deviceStatus.firstWhere(
                            (device) =>
                        device['MacAddress'] == jsonResponse['mac_address'],
                      )['sw1'] !=
                          jsonResponse['sw0']) {
                        print('step1');
                        Provider.of<AuthProvider>(context, listen: false)
                            .setSwitch(
                            jsonResponse['mac_address'],
                            'sw1',
                            jsonResponse['sw0']);
                      }
                      if (deviceStatus.firstWhere(
                            (device) =>
                        device['MacAddress'] == jsonResponse['mac_address'],
                      )['sw2'] !=
                          jsonResponse['sw1']) {
                        print('step2');
                        Provider.of<AuthProvider>(context, listen: false)
                            .setSwitch(
                            jsonResponse['mac_address'],
                            'sw2',
                            jsonResponse['sw1']);
                      }
                      if (deviceStatus.firstWhere(
                            (device) =>
                        device['MacAddress'] == jsonResponse['mac_address'],
                      )['sw3'] !=
                          jsonResponse['sw2']) {
                        print('step3');
                        Provider.of<AuthProvider>(context, listen: false)
                            .setSwitch(
                            jsonResponse['mac_address'],
                            'sw3',
                            jsonResponse['sw2']);
                      }
                      if (deviceStatus.firstWhere(
                            (device) =>
                        device['MacAddress'] == jsonResponse['mac_address'],
                      )['led'] !=
                          jsonResponse['led']) {
                        print('step4');
                        Provider.of<AuthProvider>(context, listen: false)
                            .setSwitch(
                            jsonResponse['mac_address'],
                            'led',
                            jsonResponse['led']);
                      }
                    }
                    Provider.of<AuthProvider>(context, listen: false)
                        .addingDevice(commandResponse, jsonResponse);
                  }
                  else if (commandResponse == 'MAC_ADDRESS_READ_OK') {
                    Provider.of<AuthProvider>(context, listen: false)
                        .addingDevice('MAC_ADDRESS_READ_OK', jsonResponse);
                  }
                  else if (commandResponse == 'WIFI_CONFIG_FAILED') {
                    Provider.of<AuthProvider>(context, listen: false)
                        .addingDevice('WIFI_CONFIG_FAILED', {});
                  }
                  else if (commandResponse == 'WIFI_CONFIG_CONNECTING' ||
                      commandResponse == 'WIFI_CONFIG_SAME') {
                    Provider.of<AuthProvider>(context, listen: false)
                        .addingDevice('WIFI_CONFIG_CONNECTING', {});
                    if (commandResponse == 'WIFI_CONFIG_SAME') {
                      Platform.isIOS
                          ? showCupertinoSnackBar(context, "Same Wi-Fi network data")
                          : ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Same Wi-Fi network data")));
                    }
                  }
                  else if (commandResponse == 'WIFI_CONNECT_CHECK_OK') {
                    Provider.of<AuthProvider>(context, listen: false)
                        .addingDevice('WIFI_CONNECT_CHECK_OK', {});
                    Platform.isIOS
                        ? showCupertinoSnackBar(context, "Connected Successfully")
                        : ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Connected Successfully")));
                  }
                  else if (commandResponse == 'CHECK_FOR_NEW_FIRMWARE_OK' ||
                      commandResponse == 'CHECK_FOR_NEW_FIRMWARE_FAIL' ||
                      commandResponse == 'CHECK_FOR_NEW_FIRMWARE_SAME' ||
                      commandResponse == 'DOWNLOAD_NEW_FIRMWARE_SAME' ||
                      commandResponse == 'DOWNLOAD_NEW_FIRMWARE_START' ||
                      commandResponse == 'DOWNLOAD_NEW_FIRMWARE_OK' ||
                      commandResponse == 'DOWNLOAD_NEW_FIRMWARE_FAIL' ||
                      commandResponse.contains(
                          'DOWNLOAD_NEW_FIRMWARE_UPDATING')) {
                    Provider.of<AuthProvider>(context, listen: false)
                        .firmwareUpdating(jsonResponse, context);
                  }
                  else if (commandResponse == 'DEVICE_CONFIG_WRITE_OK' ||
                      commandResponse == 'WIFI_CONFIG_MISSED_DATA' ||
                      commandResponse == 'READ_OK' ||commandResponse == 'WIFI_CONFIG_OK'||commandResponse == 'RGB_READ_OK' ||
                      commandResponse == 'RGB_WRITE_OK'
                  ) {}
                } catch (e) {
                  throw Exception(
                      "Something went wrong while processing the data $e");
                }
              // }
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