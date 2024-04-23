import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mega/ui/rooms.dart';

class UDPScreen extends StatefulWidget {
  const UDPScreen({super.key});

  @override
  State<UDPScreen> createState() => _UDPScreenState();
}

class _UDPScreenState extends State<UDPScreen> {
  //send
  void sendFrame(String frame, String ipAddress, int port) {
    // ipAddress = '255.255.255.255';
    print('hello');
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .then((RawDatagramSocket socket) {
      print('hello2');
      socket.send(frame.codeUnits, InternetAddress(ipAddress), port);
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            String response = String.fromCharCodes(datagram.data);
            print('Received response: $response');
          }
        }
      });
    });
  }

  void sendFrameAfterConnection(String frame, String ipAddress, int port) {
    // Removed the ipAddress assignment

    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .then((RawDatagramSocket socket) {
      print('hello2');
      socket.broadcastEnabled = true;
      socket.send(frame.codeUnits, InternetAddress(ipAddress), port);
    });
  }

  void startListen() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081) //local port
        .then((RawDatagramSocket socket) {
      print('1 => ${socket.port}');
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            String response = String.fromCharCodes(datagram.data);
            print('Received response: $response');
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UDP'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //wifi config
            ElevatedButton(
              onPressed: () {
                sendFrame(
                    'WIFI_CONFIG::[@MS_SEP@]::Hardware_room::[@MS&SEP@]::01019407823EOIP',
                    '192.168.4.1',
                    8888);
              },
              child: const Text(
                'wifi config',
              ),
            ),
            //start listen
            ElevatedButton(
              onPressed: () {
                startListen();
              },
              child: const Text(
                'start listen',
              ),
            ),
            //mac address
            ElevatedButton(
              onPressed: () {
                sendFrameAfterConnection(
                    'MAC_ADDRESS_READ', '255.255.255.255', 8888);
              },
              child: const Text(
                'mac address',
              ),
            ),
            //connect check
            ElevatedButton(
              onPressed: () {
                sendFrameAfterConnection(
                    'WIFI_CONNECT_CHECK', '255.255.255.255', 8888);
              },
              child: const Text(
                'wifi connect check',
              ),
            ),
            //status read
            ElevatedButton(
              onPressed: () {
                sendFrameAfterConnection(
                    'STATUS_READ', '255.255.255.255', 8888);
              },
              child: const Text(
                'status read',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                sendFrameAfterConnection(
                    'STATUS_WRITE::[@MS_SEP@]::0::[@MS#SEP@]::0::[@MS&SEP@]::1::[@MS#SEP@]::0::[@MS&SEP@]::2::[@MS#SEP@]::0',
                    '255.255.255.255',
                    8888);
              },
              child: const Text(
                'status write',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                sendFrameAfterConnection('RGB_READ', '255.255.255.255', 8888);
              },
              child: const Text(
                'RGB_READ',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                sendFrameAfterConnection(
                    'RGB_WRITE::0::0::0', '255.255.255.255', 8888);
              },
              child: const Text(
                'listen test',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                sendFrameAfterConnection(
                    'RGB_WRITE::0::0::0', '255.255.255.255', 8888);
              },
              child: const Text(
                'RGB_WRITE',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const Rooms(),),);
              },
              child: const Text(
                'Room',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
