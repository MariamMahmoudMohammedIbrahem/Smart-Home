import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mega/db/functions.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../udp.dart';

class RoomDetail extends StatefulWidget {
  final String roomName;
  final String macAddress;

  const RoomDetail(
      {super.key, required this.roomName, required this.macAddress});

  @override
  State<RoomDetail> createState() => _RoomDetailState();
}

class _RoomDetailState extends State<RoomDetail> {
  void changeColor(Color color) {
    setState(() => currentColor = color);
  }

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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.roomName,
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => const UDPScreen(),
        //         ),
        //       );
        //     },
        //     iconSize: 30,
        //     color: Colors.pink.shade900,
        //     icon: const Icon(Icons.add_circle_sharp),
        //   ),
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .07, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height,
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // number of items in each row
                          mainAxisSpacing: 30.0, // spacing between rows
                          crossAxisSpacing: 30.0, // spacing between columns
                        ),
                        itemCount: leds.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.pink.shade900,
                                borderRadius: BorderRadius.circular(
                                  20,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    iconsSwitches[index],
                                    color: Colors.white,
                                    size: 40,
                                  ),
              
                                  ///TODO: timer
                                  Text(
                                    leds[index],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Consumer<AuthProvider>(
                                      builder: (context, switchesProvider, child) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          switchesProvider.switches[index]
                                              ? 'on'
                                              : 'off',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Switch(
                                          activeColor: Colors.pink.shade300,
                                          activeTrackColor: Colors.pink.shade100,
                                          inactiveThumbColor: Colors.grey.shade600,
                                          inactiveTrackColor: Colors.grey.shade400,
                                          splashRadius: 50.0,
                                          value: switchesProvider.switches[index],
                                          onChanged: (value) {
                                            //send packet
                                            if (index == 0) {
                                              sendFrame(
                                                {
                                                  "commands": 'SWITCH_WRITE',
                                                  "mac_address": widget.macAddress,
                                                  "sw0": !switchesProvider.switches[0]
                                                      ? 1
                                                      : 0,
                                                  // "sw1": switchesProvider.switches[1] ? 1 : 0,
                                                  // "sw2": switchesProvider.switches[2] ? 1 : 0,
                                                },
                                                '255.255.255.255',
                                                8888,
                                              );
                                            } else if (index == 1) {
                                              sendFrame(
                                                {
                                                  "commands": 'SWITCH_WRITE',
                                                  "mac_address": widget.macAddress,
                                                  // "sw0": switchesProvider.switches[0] ? 1 : 0,
                                                  "sw1": !switchesProvider.switches[1]
                                                      ? 1
                                                      : 0,
                                                  // "sw2": switchesProvider.switches[2] ? 1 : 0,
                                                },
                                                '255.255.255.255',
                                                8888,
                                              );
                                            } else {
                                              sendFrame(
                                                {
                                                  "commands": 'SWITCH_WRITE',
                                                  "mac_address": widget.macAddress,
                                                  // "sw0": switchesProvider.switches[0] ? 1 : 0,
                                                  // "sw1": switchesProvider.switches[1] ? 1 : 0,
                                                  "sw2": !switchesProvider.switches[2]
                                                      ? 1
                                                      : 0,
                                                },
                                                '255.255.255.255',
                                                8888,
                                              );
                                            }
                                            // setState(() {
                                            switchesProvider.setSwitch(index,
                                                !switchesProvider.switches[index]);
                                            // if (index == 1) {
                                            //   rgb = !rgb;
                                            //   _showColorPicker(context);
                                            // }
                                            // });
                                          },
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                            onLongPress: () {
                              if (index == 1 &&
                                  Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .switches[1]) {
                                // rgb = !rgb;
                                _showColorPicker(context);
                              }
                            },
                          );
                        },
                      ),
                    ),
                    Consumer<AuthProvider>(
                        builder: (context, switchesProvider, child) {
                      return switchesProvider.switches[1]
                          ? Container(
                              decoration: const BoxDecoration(
                                color: Colors
                                    .white, // Set the background color as needed
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50.0),
                                  topRight: Radius.circular(50.0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 15.0),
                                child: Wrap(
                                  children: <Widget>[
                                    HueRingPicker(
                                      pickerColor: currentColor,
                                      onColorChanged: changeColor,
                                    ),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          sendFrame(
                                            {
                                              "commands": "RGB_WRITE",
                                              "mac_address": widget.macAddress,
                                              "red": currentColor.red,
                                              "green": currentColor.green,
                                              "blue": currentColor.blue,
                                            },
                                            '255.255.255.255',
                                            8888,
                                          );
                                          // Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Save',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox();
                    }),
                    /*if(rgb)...[
                      Expanded(
                        child: HUEColorPicker(
                            pickerColor: currentColor, onColorChanged: changeColor),
                      ),
                    ],*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white, // Set the background color as needed
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.0),
              topRight: Radius.circular(50.0),
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            child: Wrap(
              children: <Widget>[
                HueRingPicker(
                  pickerColor: currentColor,
                  onColorChanged: changeColor,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      sendFrame(
                        {
                          "commands": "RGB_WRITE",
                          "mac_address": widget.macAddress,
                          "red": currentColor.red,
                          "green": currentColor.green,
                          "blue": currentColor.blue,
                        },
                        '255.255.255.255',
                        8888,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Save',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    saved = false;
    super.initState();
  }
}
