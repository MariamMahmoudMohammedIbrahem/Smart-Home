import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

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
          }
        }
      });
    });
  }
  @override
  void initState(){
    super.initState();
    startListen();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                      "mac_address": "84:F3:EB:20:8C:7A",
                    },
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
                      "commands": "WIFI_CONFIG",
                      "mac_address": "84:F3:EB:20:8C:7A",
                      "wifi_ssid": "Hardware_room",
                      "wifi_password": '01019407823EOIP',
                    },
                    '192.168.4.1',
                    8888,
                  );
                },
                child: const Text('send wifi config packet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
