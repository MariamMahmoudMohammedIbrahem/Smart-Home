/***connection_ip.dart***/
/*import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

Future<  List<String>> getConnectedDevicesIP() async {
  // Check if the device is connected to a Wi-Fi network
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult != ConnectivityResult.wifi) {
    return [];
  }

  // Retrieve Wi-Fi information
  // WifiInfoWrapper wifiInfo = await WifiInfo().getWifiInfo();
  String? ipAddress = await WifiInfo().getWifiIP();
  print('hii $ipAddress');

  // Extract subnet from IP address
  List<String>? parts = ipAddress?.split('.');
  print('hii1 $parts');
  String subnet = '${parts![0]}.${parts[1]}.${parts[2]}.';
  print('hii2 $subnet');

  // Ping all IP addresses in subnet to find active ones
  List<String> devicesIP = [];
  for (int i = 1; i < 255; i++) {
    String testIP = subnet + i.toString();
    // bool response = await WifiInfo().(testIP);
    // if (response) {
    print('hii $testIP');
    devicesIP.add(testIP);
    print('hii3 $devicesIP');
    // }
  }

  return devicesIP;
}

class ConnectionIP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Connected Devices IP'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                getConnectedDevicesIP();
              },
              child: Text(
                'function',
              ),
            ),
            Center(
              child: FutureBuilder(
                future: getConnectedDevicesIP(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<String>? devicesIP = snapshot.data;
                    return ListView.builder(
                      itemCount: devicesIP?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(devicesIP![index]),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/

/***NetworkScanner.dart***/
/*import 'package:flutter/services.dart';

class NetworkScanner {
  static const MethodChannel _channel = MethodChannel('com.example.insulin/network_scanner');

  static Future<List<String>> scanDevices() async {
    print('hey');
    List<String> devices =[];
    try {print('hey $devices []');
    final List<dynamic> result = await _channel.invokeMethod('scanDevices');
    devices = result.cast<String>();
    print('hey $devices ss');
    } on PlatformException catch (e) {
      print("Failed to scan devices: '${e.message}'.");
    }
    return devices;
  }
}*/
/*network_scanner.dart

import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/services.dart';

final DynamicLibrary nativeLib = DynamicLibrary.open('libnetwork_scanner.so');

typedef ScanLocalNetworkC = Pointer<Void> Function();
typedef ScanLocalNetworkDart = Pointer<Void> Function();

class NetworkScanner {
  static final MethodChannel _channel = MethodChannel('network_scanner');

  static Future<List<String>> scanLocalNetwork() async {
    List<String> activeDevices = [];
    try {
      print('active devices38 $activeDevices');
      await _channel.invokeMethod('scanLocalNetwork').then((value) => print('value $value'),);

      print('active devices42 $activeDevices');
    } catch (e) {
      print("Error: $e");
    }
    return activeDevices;
  }
}*/

/***wifi_list.dart***/
/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insulin/src/megasmart/udp_screen.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiListScreen extends StatefulWidget {
  const WifiListScreen({super.key});

  @override
  WifiListScreenState createState() => WifiListScreenState();
}

class WifiListScreenState extends State<WifiListScreen> {
  List<WiFiAccessPoint> _wifiNetworks = [];
  final passwordController = TextEditingController(text: '01019407823EOIP');
  String pass = '01019407823EOIP';
  bool connect = false;
  @override
  void initState() {
    super.initState();
    _scanWifiNetworks();
  }

  Future<void> _scanWifiNetworks() async {
    try {
      WiFiScan wifiScan = WiFiScan.instance;
      List<WiFiAccessPoint> wifiNetworks = await wifiScan.getScannedResults();
      setState(() {
        _wifiNetworks = wifiNetworks;
      });
    } catch (e) {
      print('Error scanning Wi-Fi networks: $e');
    }
  }

  // Connect to an open Wi-Fi network
  void connectToOpenWifi(String ssid, String password) async {
    try {
      await WiFiForIoTPlugin.connect(
        ssid,
        security: NetworkSecurity.WPA,
        password: password,
      );
      print(
        'Connected to $ssid',
      );
    } catch (e) {
      print(
        'Failed to connect to $ssid: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wi-Fi Networks',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.wifi_off,
            ),
            onPressed: () {
              WiFiForIoTPlugin.getSSID().then((ssid) async {
                print('ssid $ssid');
                await WiFiForIoTPlugin.disconnect();
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.wifi,
            ),
            onPressed: _scanWifiNetworks,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: _wifiNetworks.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: ExpansionTile(
                      title: Text(
                        _wifiNetworks[index].ssid ?? 'Unknown',
                      ),
                      subtitle: Text(
                        'BSSID: ${_wifiNetworks[index].bssid}, Signal Strength: ${_wifiNetworks[index].level}',
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextFormField(
                            controller: passwordController,
                            cursorColor: Colors.grey,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.grey),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.people,
                                color: Colors.grey,
                              ),
                              labelText: 'password',
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide(
                                  width: 3,
                                  color: Colors.grey,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                pass = value;
                              });
                            },
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                print('pass $pass');
                              },
                              child: const Text(
                                'print',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                connectToOpenWifi(
                                    _wifiNetworks[index].bssid, pass);
                              },
                              child: const Text(
                                'connect',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const UDPScreen(),),);
                },
                child: Text(
                  'udp',
                  style: TextStyle(color: Colors.white),
                ))
            */
/*Visibility(
              visible: connect,
              child: Column(
                children: [
                  TextFormField(
                    controller: passwordController,
                    cursorColor: Colors.grey,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.people,
                        color: Colors.grey,
                      ),
                      labelText: 'password',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(
                          width: 3,
                          color: Colors.grey,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    onChanged: (value) async {},
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        connectToOpenWifi(ssid,);
                      },
                      child: Text(
                        'connect',
                      ),
                    ),
                  ),
                ],
              ),
            ),*/
/*
          ],
        ),
      ),
    );
  }
}*/

/***udp.dart***/
// void test(){
//   ServerSocket.bind(InternetAddress.anyIPv4, 0).then((ServerSocket server) {
//     // Get the port the server is listening on
//     int port = server.port;
//     print('Server listening on port $port');
//
//     // Listen for incoming connections
//     server.listen((Socket client) {
//       print('Client connected from ${client.remoteAddress.address}:${client.remotePort}');
//
//       // Handle data from the client
//       client.listen((List<int> data) {
//         String message = String.fromCharCodes(data).trim();
//         print('Received: $message');
//
//         // Echo the received message back to the client
//         client.write('Echo: $message');
//       });
//
//       // Handle when the client disconnects
//       client.done.then((_) {
//         print('Client disconnected');
//       }).catchError((error) {
//         print('Error: $error');
//       });
//     });
//   }).catchError((error) {
//     print('Error starting server: $error');
//   });
// }

//receive
// void startServer(int port) {
//   RawDatagramSocket.bind(InternetAddress.anyIPv4, port)
//       .then((RawDatagramSocket socket) {
//     print('UDP server listening on port $port');
//
//     socket.listen((RawSocketEvent event) {
//       if (event == RawSocketEvent.read) {
//         Datagram? datagram = socket.receive();
//         if (datagram != null) {
//           String frame = String.fromCharCodes(datagram.data);
//           print('Received frame: $frame');
//
//           // Generate response
//           String response = 'Response to: $frame';
//           socket.send(response.codeUnits, datagram.address, datagram.port);
//         }
//       }
//     }).onDone(() {
//       socket.close();
//     });
//   });
// }

// Future<void> getWifiInfo() async {
//   var connectivityResult = await Connectivity().checkConnectivity();
//   print(connectivityResult);
//   if (connectivityResult == ConnectivityResult.wifi) {
//     // Connected to a Wi-Fi network
//     await (Connectivity().onConnectivityChanged.forEach((element) {
//       print('element $element');
//     }));
//   } else {
//     print('Not connected to a Wi-Fi network');
//   }
// }

// Future printIps() async {
//   for (var interface in await NetworkInterface.list()) {
//     print('== Interface: ${interface.name} ==');
//     for (var addr in interface.addresses) {
//       print(
//           '${addr.address} ${addr.host} ${addr.isLoopback} ${addr.rawAddress} ${addr.type.name}');
//     }
//   }
// }

// ipsSend() {
//   // List devicesIps = ['192.168.1.1', '192.168.1.2', '192.168.1.5', '192.168.1.7', '192.168.1.13', '192.168.1.14', '192.168.1.17', '192.168.1.21', '192.168.1.22', '192.168.1.23', '192.168.1.30', '192.168.1.38', '192.168.1.102', '192.168.1.251', '192.168.1.1', '192.168.1.2', '192.168.1.5', '192.168.1.14', '192.168.1.21', '192.168.1.30', '192.168.1.38', '192.168.1.102', '192.168.1.177', '192.168.1.251'];
//   for (int i = 0; i < devices.length; i++) {
//     sendFrame('WIFI_CONNECT_CHECK', devices[i], 8888);
//   }
// }

// Future<void> _scanNetwork() async {
//   List<String> activeDevices = await NetworkScanner.scanDevices();
//   setState(() {
//     devices = activeDevices;
//   });
// }
/*ElevatedButton(
              onPressed: () {
                startServer(12345);
              },
              child: const Text(
                'start',
              ),
            ),
            //get wifi info
            ElevatedButton(
              onPressed: () {
                getWifiInfo();
              },
              child: const Text(
                'get wifi info',
              ),
            ),
            //print Ips
            ElevatedButton(
              onPressed: () {
                printIps();
              },
              child: const Text(
                'print ips',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _scanNetwork();
                print('Discovered devices: $devices');
              },
              child: Text('Scan Network'),
            ),
            ElevatedButton(
              onPressed: () {
                ipsSend();
              },
              child: Text('Search for the ip'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> ConnectionIP()));
              },
              child: const Text(
                'connection_ip',
              ),
            ),*/
// List<String> devices = [];
// import 'package:insulin/src/megasmart/connection_ip.dart';

// import 'network_scanner.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

/***HexToRGB***/
/*String hexColor = "#FF5733"; // Example color

    // Convert hexadecimal color to RGB
    Color color = HexColor(hexColor);

    // Get RGB values
    int red = color.red;
    int green = color.green;
    int blue = color.blue;*/
/*
class HexColor extends Color {
  HexColor(String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }
}*/

/***main.dart***/
/*
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const ColorPick(),),);
              },
              child: const Text('Color Pick',),
            ),
          ],
        ),
      ),
    );
  }
}*/

/***NetworkScanner.kt***/
/*
package com.example.insulin

import android.content.Context
import android.os.AsyncTask
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import java.io.IOException
import java.net.InetAddress
import java.net.UnknownHostException

class NetworkScanner(private val context: Context, private val callback: NetworkScanCallback) :
AsyncTask<Void, Void, List<String>>() {

interface NetworkScanCallback {
fun onScanComplete(devices: List<String>)
}

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
override fun doInBackground(vararg voids: Void): List<String> {
val devices = ArrayList<String>()
try {
for (i in 1..255) {
val host = "192.168.1.$i" // Customize this subnet according to your network
val inetAddress: InetAddress = InetAddress.getByName(host)
if (inetAddress.isReachable(1000)) {
devices.add(inetAddress.hostAddress)
}
}
} catch (e: UnknownHostException) {
e.printStackTrace()
} catch (e: IOException) {
e.printStackTrace()
}
return devices
}

override fun onPostExecute(devices: List<String>) {
super.onPostExecute(devices)
callback.onScanComplete(devices)
}
}
*/

/***MainActivity.kt***/
/*
package com.example.insulin

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.insulin/network_scanner").setMethodCallHandler { call, result ->
            if (call.method == "scanDevices") {
                NetworkScanner(this, object : NetworkScanner.NetworkScanCallback {
                    override fun onScanComplete(devices: List<String>) {
                        result.success(devices)
                    }
                }).execute()
            } else {
                result.notImplemented()
            }
        }
    }
}
*/
/***UDPScreen.dart***/
/*//start listen
              ElevatedButton(
                onPressed: () {
                  startListen();
                },
                child: const Text(
                  'lits',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  startListen();
                },
                child: const Text(
                  'start listen',
                ),
              ),*/
/*//connect check

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
              ),*/
/*//send
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
  }*//*//mac address
              ElevatedButton(
                onPressed: () {
                  sendFrame(
                      'MAC_ADDRESS_READ', '255.255.255.255', 8888);
                },
                child: const Text(
                  'get configuration',
                ),
              ),
              Text(responseAll),
              Form(
                key: _formKey,
                autovalidateMode: !readOnly ? AutovalidateMode.always : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      enabled: !readOnly,
                      decoration: const InputDecoration(labelText: 'Name'),
                      readOnly: readOnly,
                      validator: (value) {
                        if (value!.isEmpty && !readOnly) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      onChanged: (value){
                        name = _nameController.text;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !readOnly,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      readOnly: readOnly,
                      validator: (value) {
                        if (value!.isEmpty && !readOnly) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onChanged: (value){
                        password = _passwordController.text;
                      },
                    ),
                    //wifi config
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if(!readOnly){
                            if (_formKey.currentState!.validate()) {
                              sendFrame(
                                  'WIFI_CONFIG::[@MS_SEP@]::$name::[@MS&SEP@]::$password',
                                  '192.168.4.1',
                                  8888);
                            }
                          }
                        },
                        child: const Text(
                          'wifi config',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  sendFrame(
                      'WIFI_CONNECT_CHECK', '255.255.255.255', 8888);
                  */
/*if(navigate){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Rooms(),
                      ),
                    );
                  }*//*
                },
                child: const Text(
                  'wifi connect check',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if(navigate){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Rooms(),
                      ),
                    );
                  }
                },
                child: const Text(
                  'navigate',
                ),
              ),*/
