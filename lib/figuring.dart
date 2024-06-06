import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mega/udp.dart';
import 'package:mega/ui/rooms.dart';

import 'constants.dart';

class Figuring extends StatefulWidget {
  const Figuring({super.key});

  @override
  State<Figuring> createState() => _FiguringState();
}

class _FiguringState extends State<Figuring> {
  String response = 'no response';
  void sendFrame(Map<String, dynamic> jsonFrame, String ipAddress, int port) {
    // Convert the Map to a JSON string
    String frame = jsonEncode(jsonFrame);

    // Bind to any available IPv4 address and port 0 (let the OS assign a port)
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .then((RawDatagramSocket socket) {
      print('Sending JSON frame');
      print(jsonFrame);
      socket.broadcastEnabled = true;

      // Send the JSON string as a list of bytes
      socket.send(frame.codeUnits, InternetAddress(ipAddress), port);
    });
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String name = '';
  String password = '';
  String macAddress = "";
  void startListen() {
    // Bind to any available IPv4 address and the specified port (8081)
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081)
        .then((RawDatagramSocket socket) {
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            setState(() {
              response = String.fromCharCodes(datagram.data);
            });
            // Convert the received data to a string
            print('response $response');
            Map<String, dynamic> jsonResponse = jsonDecode(response);
            macAddress = jsonResponse["mac_address"];
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startListen();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const UDPScreen()));
                  },
                  child: const Text(
                    'add device',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Rooms()));
                  },
                  child: const Text(
                    'rooms',
                  ),
                ),
                Text('response: $response'),
                ElevatedButton(
                  onPressed: () {
                    sendFrame(
                      {"commands": 'MAC_ADDRESS_READ'},
                      '255.255.255.255',
                      8888,
                    );
                  },
                  child: const Text('Sending Mac Address Packet'),
                ),
                ElevatedButton(
                  onPressed: () {
                    sendFrame(
                      {
                        "commands": 'WIFI_CONNECT_CHECK',
                        "mac_address": macAddress,
                      },
                      '255.255.255.255',
                      8888,
                    );
                  },
                  child: const Text('Sending Mac Address Packet'),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Wifi Network Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your Wifi Network\'s name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    name = _nameController.text;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Wifi Network Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          eye = !eye;
                        });
                      },
                      icon: Icon(
                        eye
                            ? Icons.remove_red_eye_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  obscureText: eye,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your Wifi Network\'s password';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    password = _passwordController.text;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    sendFrame(
                      {
                        "commands": "WIFI_CONFIG",
                        "mac_address": macAddress,
                        "wifi_ssid": name,
                        "wifi_password": password,
                      },
                      '255.255.255.255',
                      8888,
                    );
                  },
                  child: const Text('send wifi config packet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
