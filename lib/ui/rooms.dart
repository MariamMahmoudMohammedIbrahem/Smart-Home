import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:mega/services/weather_service.dart';
import 'package:mega/udp.dart';
import 'package:mega/ui/room_info.dart';

import '../constants.dart';

// import '../models/weather_model.dart';

class Rooms extends StatefulWidget {
  const Rooms({super.key});

  @override
  State<Rooms> createState() => _RoomsState();
}

class _RoomsState extends State<Rooms> {
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

  /*@override
  void initState() {
    super.initState();
    //fetch weather on startup
    _fetchWeather();
  }*/

  @override
  Widget build(BuildContext context) {
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
    double width = MediaQuery.of(context).size.width;
    /*initial = widget.userName.trim().isNotEmpty
        ? widget.userName.trim()[0].toUpperCase()
        : '';*/
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        /*leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.pink
                  .shade900,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: TextButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ),*/
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const UDPScreen()));
              },
              iconSize: 30,
              color: Colors.pink.shade900,
              icon: const Icon(Icons.add_circle_sharp)),
          /*Builder(
            builder: (context) => IconButton(
              iconSize: 35,
              color: Colors.pink.shade900,
              icon: const Icon(Icons.menu_open_outlined), // Change the icon here
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),*/
        ],
      ),
      /*endDrawer: Drawer(
        child: Container(
          color: Colors.brown.shade50,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(
                height: 150,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/light-control.gif'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'widget.userName',
                      style: TextStyle(
                        color: Colors.brown.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.home,
                  color: Colors.brown.shade700,
                  size: 30,
                ),
                title: Text(
                  'Rooms',
                  style: TextStyle(
                      color: Colors.brown.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                onTap: () {
                  _scaffoldKey.currentState?.closeEndDrawer();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(
                  height: 1,
                  indent: 0,
                  endIndent: 10,
                  thickness: 2,
                  color: Colors.brown.shade100,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.account_circle_outlined,
                  color: Colors.brown.shade700,
                  size: 30,
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(
                      color: Colors.brown.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                onTap: () {
                  _scaffoldKey.currentState?.closeEndDrawer();
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>const AccountDetails(userName: '',),),);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(
                  height: 1,
                  indent: 0,
                  endIndent: 10,
                  thickness: 2,
                  color: Colors.brown.shade100,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.key_sharp,
                  color: Colors.brown.shade700,
                  size: 30,
                ),
                title: Text(
                  'Reset Password',
                  style: TextStyle(
                      color: Colors.brown.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                onTap: () {
                  _scaffoldKey.currentState?.closeEndDrawer();
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>const PasswordReset(),),);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(
                  height: 1,
                  indent: 0,
                  endIndent: 10,
                  thickness: 2,
                  color: Colors.brown.shade100,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.logout_outlined,
                  color: Colors.brown.shade700,
                  size: 30,
                ),
                title: Text(
                  'Sign Out',
                  style: TextStyle(
                      color: Colors.brown.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                onTap: () {
                  //logout
                  _scaffoldKey.currentState?.closeEndDrawer();
                  // handleSignOut();

                },
              ),
            ],
          ),
        ),
      ),*/
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .05, vertical: 10),
          child: Column(
            children: [
              /*Text(_weather?.cityName ?? "loading city.."),
              Text("${_weather?.temperature.round()} c"),
              ElevatedButton(onPressed: _fetchWeather, child: const Text('fetch weather',),),*/
              /*Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.pink.shade900,
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: const Placeholder(
                  color: Colors.white,
                ),
              ),*/
              /*const Padding(
                padding: EdgeInsets.all(15.0),
                child: Divider(
                  height: 1,
                  color: Colors.pink,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
              ),*/
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
                  IconButton(
                    onPressed: () {
                      setState(() {
                        toggle = !toggle;
                      });
                    },
                    icon: Icon(
                      toggle ? Icons.grid_view_rounded : Icons.list_outlined,
                      color: Colors.pink.shade900,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: startListenJson,
                child: const Text(
                  'Start Listen',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  sendFrameJson(
                    {"commands": "DEVICE_CONFIG_WRITE","mac_address":"08:3A:8D:D0:AA:20","update_period":"0"},
                    '255.255.255.255',
                    8888,
                  );
                },
                child: const Text(
                  'Send Json',
                ),
              ),
              Flexible(
                child: toggle
                    ? ListView.builder(
                        itemCount: items.length, // total number of items
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
                                    items[index],
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
                                    builder: (context) =>
                                        RoomDetail(room: items[index]),
                                  ),
                                );
                              },
                              onLongPress: () {
                                _showOptions(context, items[index]);
                              },
                            ),
                          );
                        },
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // number of items in each row
                          mainAxisSpacing: 15.0, // spacing between rows
                          crossAxisSpacing: 15.0, // spacing between columns
                        ),
                        /*padding: const EdgeInsets.all(
                            8.0), // padding around the grid*/
                        itemCount: items.length, // total number of items
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                color: Colors.pink.shade900,
                              ),
                              child: Center(
                                child: Text(
                                  items[index],
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
                                  builder: (context) =>
                                      RoomDetail(room: items[index]),
                                ),
                              );
                            },
                            onLongPress: () {
                              _showOptions(context, items[index]);
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

  void startListenJson() {
    // Bind to any available IPv4 address and the specified port (8081)
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081)
        .then((RawDatagramSocket socket) {
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            // Convert the received data to a string
            String response = String.fromCharCodes(datagram.data);

            try {
              // Parse the JSON string to a Map
              Map<String, dynamic> jsonResponse = jsonDecode(response);
              print('Received JSON response: $jsonResponse');
            } catch (e) {
              print('Error decoding JSON: $e');
            }
          }
        }
      });
    });
  }

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
