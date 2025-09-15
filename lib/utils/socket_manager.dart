import '../commons.dart';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  RawDatagramSocket? _socket;

  factory SocketManager() {
    return _instance;
  }

  SocketManager._internal();

  Future<void> startListen(BuildContext context) async {
    if (_socket != null) {
      return;
    }

    var commandResponse = '';
    try {
      RawDatagramSocket socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        8081,
      );
        _socket = socket;
        if(!context.mounted) return;
        Provider.of<AuthProvider>(context, listen: false)
            .setSocketBindFailed(false);
        socket.listen((RawSocketEvent event) {
          if (event == RawSocketEvent.read) {
            Datagram? datagram = socket.receive();
            if (datagram != null) {
              String response = String.fromCharCodes(datagram.data);
              if (response == "OK") {
                commandResponse = response;
              } else {
                try {
                  Map<String, dynamic> jsonResponse = jsonDecode(response);
                  final mac = jsonResponse['mac_address'];
                  final device = findDeviceByMac(deviceStatus, mac);
                  final selectedColor = Color.fromRGBO(
                    jsonResponse["red"],
                    jsonResponse["green"],
                    jsonResponse["blue"],
                    1.0,
                  );
                  commandResponse = jsonResponse['commands'];

                  if (deviceStatus.any(
                        (device) =>
                    device.macAddress == jsonResponse['mac_address'],
                  ) ||
                      deviceStatus.isEmpty) {
                    // here we update the map that contains the firmware version
                    // for each switch's macAddress
                    // to check later if this switch needs a firmware update or no
                    addOrUpdateDevice({
                      'mac_address': jsonResponse['mac_address'],
                      'firmware_version': jsonResponse['firmware_version'],
                      'command': '',
                      'time': DateTime.now(),
                      'isConnected': true,
                    }, context);
                  }
                  if (commandResponse == 'UPDATE_OK' ||
                      commandResponse == 'SWITCH_WRITE_OK' ||
                      commandResponse == 'SWITCH_READ_OK') {
                    if (device != null) {
                      if (device.sw1 != jsonResponse['sw0']) {
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).setSwitch(mac, (d) {
                          d.sw1 = jsonResponse['sw0'];
                        });
                      }
                      if (device.sw2 != jsonResponse['sw1']) {
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).setSwitch(mac, (d) {
                          d.sw2 = jsonResponse['sw1'];
                        });
                      }
                      if (device.sw3 != jsonResponse['sw2']) {
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).setSwitch(mac, (d) {
                          d.sw3 = jsonResponse['sw2'];
                        });
                      }
                      if (device.led != jsonResponse['led']) {
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).setSwitch(mac, (d) {
                          d.led = jsonResponse['led'];
                        });
                      }
                      if (device.currentColor != selectedColor) {
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).setSwitch(mac, (d) {
                          d.currentColor = selectedColor;
                        });
                      }
                      tempColor = device.currentColor;
                    }
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).addingDevice(commandResponse, jsonResponse);
                  } else if (commandResponse == 'MAC_ADDRESS_READ_OK') {
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).addingDevice('MAC_ADDRESS_READ_OK', jsonResponse);
                  } else if (commandResponse == 'WIFI_CONFIG_FAILED') {
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).addingDevice('WIFI_CONFIG_FAILED', {});
                  } else if (commandResponse == 'WIFI_CONFIG_CONNECTING' ||
                      commandResponse == 'WIFI_CONFIG_SAME') {
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).addingDevice('WIFI_CONFIG_CONNECTING', {});
                    if (commandResponse == 'WIFI_CONFIG_SAME') {
                      Platform.isIOS
                          ? showCupertinoSnackBar(
                        context,
                        "Same Wi-Fi network data",
                      )
                          : ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Same Wi-Fi network data"),
                        ),
                      );
                    }
                  } else if (commandResponse == 'WIFI_CONNECT_CHECK_OK') {
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).addingDevice('WIFI_CONNECT_CHECK_OK', {});
                    Platform.isIOS
                        ? showCupertinoSnackBar(
                        context, "Connected Successfully")
                        : ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Connected Successfully")),
                    );
                  } else if (commandResponse == 'CHECK_FOR_NEW_FIRMWARE_OK' ||
                      commandResponse == 'CHECK_FOR_NEW_FIRMWARE_FAIL' ||
                      commandResponse == 'CHECK_FOR_NEW_FIRMWARE_SAME' ||
                      commandResponse == 'DOWNLOAD_NEW_FIRMWARE_SAME' ||
                      commandResponse == 'DOWNLOAD_NEW_FIRMWARE_START' ||
                      commandResponse == 'DOWNLOAD_NEW_FIRMWARE_OK' ||
                      commandResponse == 'DOWNLOAD_NEW_FIRMWARE_FAIL' ||
                      commandResponse.contains(
                        'DOWNLOAD_NEW_FIRMWARE_UPDATING',
                      )) {
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).firmwareUpdating(jsonResponse, context);
                  } else if (commandResponse == 'DEVICE_CONFIG_WRITE_OK' ||
                      commandResponse == 'WIFI_CONFIG_MISSED_DATA' ||
                      commandResponse == 'READ_OK' ||
                      commandResponse == 'WIFI_CONFIG_OK' ||
                      commandResponse == 'RGB_READ_OK' ||
                      commandResponse == 'RGB_WRITE_OK') {
                    Provider.of<AuthProvider>(context, listen: false).setSwitch(
                      mac,
                          (d) {
                        d.currentColor = selectedColor;
                      },
                    );
                    if (device != null) tempColor = device.currentColor;
                  }
                } catch (e) {
                  throw Exception(
                    "Something went wrong while processing the data $e",
                  );
                }
              }
            }
          }
        });
    } on SocketException {
      // Could not bind to the port
      Provider.of<AuthProvider>(context, listen: false)
          .setSocketBindFailed(true);
      if (Platform.isIOS) {
        showCupertinoSnackBar(
          context,
          "Unable to start listener: Port already in use.",
        );
      }
    } catch (e) {
      // Any other unexpected error
      Provider.of<AuthProvider>(context, listen: false)
          .setSocketBindFailed(true);
      if (Platform.isIOS) {
        showCupertinoSnackBar(context, "Socket error: $e");
      }
    }
  }

  void close() {
    _socket?.close();
    _socket = null;
  }
}