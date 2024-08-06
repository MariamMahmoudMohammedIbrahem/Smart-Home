import 'package:flutter/material.dart';
import 'package:mega/udp.dart';
import 'package:mega/ui/room_info.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../db/functions.dart';

class Rooms extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Rooms({super.key});

  @override
  Widget build(BuildContext context) {
    // sqlDb.readData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SocketManager().startListen(context);
    });
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
                          print('object $loading');
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
                ],
              ),
              Flexible(
                child: Provider.of<AuthProvider>(context)
                        .isLoading
                    ? CircularProgressIndicator(
                        color: Colors.pink.shade900,
                      )
                    : Provider.of<AuthProvider>(context).itemsEmpty
                        ? SizedBox(
                            child: Text(
                              'There is no data to show',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.pink.shade900,
                              ),
                            ),
                          )
                        : Provider.of<AuthProvider>(context).toggle
                            ? GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 15.0,
                                  crossAxisSpacing: 15.0,
                                ),
                                itemCount: values.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
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
                                          Icon(
                                            getIconName(values[index]),
                                            color: Colors.white,
                                            size: width * .25,
                                          ),
                                          /*Row(
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
                                              iconsSwitches[0],
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
                                              iconsSwitches[1],
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
                                              iconsSwitches[2],
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
                                              iconsSwitches[3],
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                        ],
                                      ),*/
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
                                                      entry.value ==
                                                      values[index])
                                                  .key),
                                        ),
                                      );
                                    },
                                    onLongPress: () {
                                      _showOptions(context, values[index]);
                                    },
                                  );
                                },
                              )
                            : ListView.builder(
                                itemCount:
                                    values.length, // total number of items
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 7.5, horizontal: 8.0),
                                    child: GestureDetector(
                                      child: Container(
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          color: Colors.pink.shade900,
                                        ),
                                        padding:
                                            const EdgeInsets.only(left: 15),
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
                              ),
              )
            ],
          ),
        ),
      ),
    );
  }

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
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
