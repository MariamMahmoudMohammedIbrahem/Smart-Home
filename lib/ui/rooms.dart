import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:mega/services/weather_service.dart';
import 'package:mega/udp.dart';
import 'package:mega/ui/room_info.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../db/functions.dart';
import '../main.dart';

// import '../models/weather_model.dart';

/*
class Rooms extends StatefulWidget {
  Rooms({super.key});

  @override
  State<Rooms> createState() => _RoomsState();
}
*/

class Rooms extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /*//api key
  final _weatherService = WeatherService('7ef5de939aeeef2465e631149e968016');
  Weather? _weather;
  //fetch weather
  _fetchWeather() async {
    //get the current city
    String cityName = await _weatherService.getCurrentCity();
    print(cityName);
    //get weather for city
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }*/
  var commandResponse = '';

  int startListen(BuildContext context) {
    print("Enter listen out");
    // Bind to any available IPv4 address and the specified port (8081)
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081)
        .then((RawDatagramSocket socket) {
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            // Convert the received data to a string
            String response = String.fromCharCodes(datagram.data);
            print('response out $response');
            if (response == "OK") {
              commandResponse = response;
            } else {
              try {
                // Parse the JSON string to a Map
                Map<String, dynamic> jsonResponse = jsonDecode(response);

                commandResponse = jsonResponse['commands'];
                if (commandResponse == 'SWITCH_READ_OK') {
                } else if (commandResponse == 'UPDATE_OK') {
                  // setState(() {
                  //   context.read<SwitchesProvider>().setSwitch(0, jsonResponse['sw0'] != 0);
                  Provider.of<SwitchesProvider>(context, listen: false)
                      .setSwitch(0, jsonResponse['sw0'] != 0);
                  Provider.of<SwitchesProvider>(context, listen: false)
                      .setSwitch(1, jsonResponse['sw1'] != 0);
                  Provider.of<SwitchesProvider>(context, listen: false)
                      .setSwitch(2, jsonResponse['sw2'] != 0);

                  currentColor = Color.fromRGBO(jsonResponse['red'],
                      jsonResponse['green'], jsonResponse['blue'], 100);
                  print(currentColor);
                  // });
                } else if (commandResponse == 'SWITCH_WRITE_OK') {
                } else if (commandResponse == 'RGB_READ_OK') {
                } else if (commandResponse == 'RGB_WRITE_OK') {
                } else if (commandResponse == 'MAC_ADDRESS_READ_OK') {
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('MAC_ADDRESS_READ_OK', jsonResponse);
                } else if (commandResponse == 'WIFI_CONFIG_OK') {
                  // configured = true;
                } else if (commandResponse == 'WIFI_CONFIG_FAIL') {
                } else if (commandResponse == 'WIFI_CONFIG_CONNECTING') {
                  // configured = true;
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('WIFI_CONFIG_CONNECTING', {});
                } else if (commandResponse == 'WIFI_CONFIG_MISSED_DATA') {
                } else if (commandResponse == 'WIFI_CONFIG_SAME') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("WIFI_CONFIG_SAME"),
                  ));
                } else if (commandResponse == 'WIFI_CONNECT_CHECK_OK') {
                  // connectionSuccess = true;
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('WIFI_CONNECT_CHECK_OK', {});
                  const snackBar = SnackBar(
                    content: Text('Connected Successfully'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else if (commandResponse == 'DEVICE_CONFIG_WRITE_OK') {
                  // roomConfig = true;
                  Provider.of<AuthProvider>(context, listen: false)
                      .addingDevice('DEVICE_CONFIG_WRITE_OK', jsonResponse);
                }
              } catch (e) {
                print('Error decoding JSON: $e');
              }
            }
          }
        }
      });
    });

    return 0;
  }

  void close() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081) //local port
        .then((RawDatagramSocket socket) {
      socket.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    sqlDb.readData();
    close();
    startListen(context);
    Color getForegroundColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.focused)) return Colors.pink.shade600;
      if (states.contains(MaterialState.pressed)) return Colors.pink.shade400;
      return Colors.pink.shade800;
    }

    Color getBackgroundColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.focused)) return Colors.pink.shade700;
      if (states.contains(MaterialState.pressed)) return Colors.pink;
      return Colors.pink.shade900;
    }

    BorderSide getBorderSide(Set<MaterialState> states) {
      final color = getForegroundColor(states);
      return BorderSide(width: 3, color: color);
    }

    final foregroundColor = MaterialStateProperty.resolveWith<Color>(
        (states) => getForegroundColor(states));
    final backgroundColor = MaterialStateProperty.resolveWith<Color>(
        (states) => getBackgroundColor(states));
    final side = MaterialStateProperty.resolveWith<BorderSide>(
        (states) => getBorderSide(states));
    final style = ButtonStyle(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
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
    // final boolState = Provider.of<BooleanProvider>(context);
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'My Home',
        ),
        titleTextStyle: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UDPScreen(),
                  ),
                );
              },
              iconSize: 30,
              color: Colors.pink.shade900,
              icon: const Icon(Icons.add_circle_sharp)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .05, vertical: 10),
          child: Column(
            children: [
              Consumer<AuthProvider>(
                builder: (context, booleanProvider, child){
                  return ElevatedButton(
                    onPressed: () {
                      print('boolean provider${booleanProvider.deviceLocation}3');
                    },
                    child: const Text(
                      'Config',
                    ),
                  );
                },
              ),

              ElevatedButton(
                onPressed: () {
                  sqlDb.deleteMyDatabase();
                },
                child: Text('delete'),
              ),
              ElevatedButton(
                onPressed: () {
                  sqlDb.readData();
                },
                child: Text(
                  'read data',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print(items);
                },
                child: Text(
                  'print data',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rooms',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: Colors.pink.shade900,
                    ),
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, toggleProvider, child) {
                      return IconButton(
                        onPressed: () {
                          toggleProvider.toggling(!toggleProvider.toggle);
                        },
                        icon: Icon(
                          toggleProvider.toggle
                              ? Icons.grid_view_rounded
                              : Icons.list_outlined,
                          color: Colors.pink.shade900,
                        ),
                      );
                    },
                  ),
                  /*SizedBox(
                    width: 50,
                    height: 50,
                    child: Consumer<BooleanProvider>(
                      builder: (context, booleanProvider, child) => IconButton(
                        onPressed: () {
                          booleanProvider.toggling(!booleanProvider.toggle);
                        },
                        icon: Icon(
                          toggle ? Icons.grid_view_rounded : Icons.list_outlined,
                          color: Colors.pink.shade900,
                        ),
                      ),
                    ),
                  ),*/
/*
                  IconButton(
                    onPressed: () {
                      // setState(() { ///Todo: set state replacement
                      // toggle = !toggle;
                      // });
                      // boolState.toggling(!boolState.toggle);
                      Provider.of<BooleanProvider>(context).toggling(
                          !Provider.of<BooleanProvider>(context).toggle);
                    },
                    icon: Icon(
                      toggle ? Icons.grid_view_rounded : Icons.list_outlined,
                      color: Colors.pink.shade900,
                    ),
                  ),
*/
                ],
              ),
              Flexible(
                child: items.isEmpty
                    ? const SizedBox()
                    : Provider.of<AuthProvider>(context).toggle
                        ? ListView.builder(
                            itemCount: values.length, // total number of items
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 7.5, horizontal: 8.0),
                                child: GestureDetector(
                                  child: Container(
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25.0),
                                      color: Colors.pink.shade900,
                                    ),
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        values[index],
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RoomDetail(
                                            roomName: values[index],
                                            macAddress: items.entries
                                                .firstWhere((entry) =>
                                                    entry.value ==
                                                    values[index])
                                                .key),
                                      ),
                                    );
                                  },
                                  onLongPress: () {
                                    _showOptions(context, values[index]);
                                  },
                                ),
                              );
                            },
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // number of values in each row
                              mainAxisSpacing: 15.0, // spacing between rows
                              crossAxisSpacing: 15.0, // spacing between columns
                            ),
                            /*padding: const EdgeInsets.all(
                            8.0), // padding around the grid*/
                            itemCount: values.length, // total number of values
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    color: Colors.pink.shade900,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        values[index],
                                        style: const TextStyle(
                                          fontSize: 25.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              icons[0],
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              icons[1],
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              icons[2],
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              icons[3],
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RoomDetail(
                                          roomName: values[index],
                                          macAddress: items.entries
                                              .firstWhere((entry) =>
                                                  entry.value == values[index])
                                              .key),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  _showOptions(context, values[index]);
                                },
                              );
                            },
                          ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void sendFrameJson(
      Map<String, dynamic> jsonFrame, String ipAddress, int port) {
    // Convert the Map to a JSON string
    String frame = jsonEncode(jsonFrame);

    // Bind to any available IPv4 address and port 0 (let the OS assign a port)
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .then((RawDatagramSocket socket) {
      print('Sending JSON frame');
      socket.broadcastEnabled = true;

      // Send the JSON string as a list of bytes
      socket.send(frame.codeUnits, InternetAddress(ipAddress), port);
    });
  }

  // void startListenJson() {
  //   // Bind to any available IPv4 address and the specified port (8081)
  //   RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081)
  //       .then((RawDatagramSocket socket) {
  //     socket.listen((RawSocketEvent event) {
  //       if (event == RawSocketEvent.read) {
  //         Datagram? datagram = socket.receive();
  //         if (datagram != null) {
  //           // Convert the received data to a string
  //           String response = String.fromCharCodes(datagram.data);
  //
  //           try {
  //             // Parse the JSON string to a Map
  //             Map<String, dynamic> jsonResponse = jsonDecode(response);
  //             print('Received JSON response: $jsonResponse');
  //           } catch (e) {
  //             print('Error decoding JSON: $e');
  //           }
  //         }
  //       }
  //     });
  //   });
  // }

  void _showOptions(BuildContext context, String room) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: <Widget>[
            Text(
              room,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                // edit name "based on db"
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                // delete container "based on  database"
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
