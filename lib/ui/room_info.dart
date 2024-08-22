import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mega/db/functions.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class RoomDetail extends StatefulWidget {
  final String roomName;
  final int roomID;

  const RoomDetail({super.key, required this.roomName, required this.roomID});

  @override
  State<RoomDetail> createState() => _RoomDetailState();
}

class _RoomDetailState extends State<RoomDetail> {


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.pink.shade100,
        shadowColor: Colors.pink.shade200,
        foregroundColor: Colors.pink.shade900,
        shape: BorderDirectional(bottom: BorderSide(color: Colors.pink.shade100, width: 0.4,),),
        title: Row(
          children: [
            Text(
              widget.roomName,
            ),
            SizedBox(width: 5,),
            Icon(getIconName(widget.roomName)),
          ],
        ),
        titleTextStyle: TextStyle(
          color: Colors.pink.shade900,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        // centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .07, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Visibility(
                visible: deviceDetails.length > 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: deviceDetails.asMap().entries.map((entry) {
                    Map<String, dynamic> device = entry.value;
                    String macAddressDevice = device['MacAddress']; // Retrieve macAddress for each device
                    return ElevatedButton(
                      onPressed: () {
                        print('macAddress is => $deviceStatus');
                        print('macAddress is => ${deviceStatus.firstWhere(
                              (device) => device['MacAddress'] == macAddressDevice,
                        )['sw1']}');
                        print('macAddress is => $macAddressDevice');
                        setState(() {
                          macAddress = macAddressDevice;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(
                          color: macAddress == macAddressDevice
                              ? Colors.pink.shade900
                              : Colors.grey,
                        ),
                        backgroundColor: macAddress == macAddressDevice
                            ? Colors.pink.shade100
                            : Colors.white,
                      ),
                      child: Text(
                        device['DeviceType'] ?? "Switch",
                        style: TextStyle(color: Colors.pink.shade900),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // number of items in each row
                  mainAxisSpacing: 30.0, // spacing between rows
                  crossAxisSpacing: 10.0, // spacing between columns
                ),
                itemCount: leds.length,
                itemBuilder: (context, index) {
                  // if(index==1) {
                  //         return Container(
                  //           color: Colors.red,
                  //         );
                  //       }
                  // else{
                  return GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.pink.shade900,
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.lightbulb_circle,
                                color: Colors.white,
                                size: 40,
                              ),
                              Consumer<AuthProvider>(builder:
                                  (context, switchesProvider, child) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Text(
                                    //   switchesProvider.switches[index]
                                    //       ? 'on'
                                    //       : 'off',
                                    //   style: const TextStyle(
                                    //     fontSize: 18,
                                    //     color: Colors.white,
                                    //   ),
                                    // ),
                                    Switch(
                                      activeColor: Colors.pink.shade300,
                                      activeTrackColor:
                                          Colors.pink.shade100,
                                      inactiveThumbColor:
                                          Colors.grey.shade600,
                                      inactiveTrackColor:
                                          Colors.grey.shade400,
                                      splashRadius: 50.0,
                                      value: deviceStatus.firstWhere(
                                            (device) => device['MacAddress'] == macAddress,
                                      )['sw${index+1}']==1?true:false,
                                      onChanged: (value) {
                                        //send packet
                                        if (index == 0) {
                                          sendFrame(
                                            {
                                              "commands":
                                                  'SWITCH_WRITE',
                                              "mac_address":
                                                  macAddress,
                                              "sw0": deviceStatus.firstWhere(
                                                    (device) => device['MacAddress'] == macAddress,
                                              )['sw1']==0?1:0,
                                            },
                                            '255.255.255.255',
                                            8888,
                                          );
                                        } else if (index == 1) {
                                          sendFrame(
                                            {
                                              "commands":
                                                  'SWITCH_WRITE',
                                              "mac_address":
                                                  macAddress,
                                              "sw1": deviceStatus.firstWhere(
                                                    (device) => device['MacAddress'] == macAddress,
                                              )['sw2']==0?1:0,
                                            },
                                            '255.255.255.255',
                                            8888,
                                          );
                                        } else {
                                          sendFrame(
                                            {
                                              "commands":
                                                  'SWITCH_WRITE',
                                              "mac_address":
                                                  macAddress,
                                              "sw2": deviceStatus.firstWhere(
                                                    (device) => device['MacAddress'] == macAddress,
                                              )['sw3']==0?1:0,
                                            },
                                            '255.255.255.255',
                                            8888,
                                          );
                                        }
                                        // setState(() {
                                        switchesProvider.setSwitch(
                                          macAddress,
                                            'sw${index+1}',
                                            deviceStatus.firstWhere(
                                                  (device) => device['MacAddress'] == macAddress,
                                            )['sw${index+1}']==0?1:0);
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

                          ///TODO: timer
                          Text(
                            leds[index],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    // onLongPress: () {
                    //   if (index == 1 &&
                    //       Provider.of<AuthProvider>(context,
                    //               listen: false)
                    //           .switches[1]) {
                    //     // rgb = !rgb;
                    //     _showColorPicker(context);
                    //   }
                    // },
                  );
                  // }
                },
              ),
              Consumer<AuthProvider>(
                  builder: (context, switchesProvider, child) {
                return deviceStatus.firstWhere(
                      (device) => device['MacAddress'] == macAddress,
                )['sw2'] == 1
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.pink.shade900,
                                  ),
                                  onPressed: () {
                                    sendFrame(
                                      {
                                        "commands": "RGB_WRITE",
                                        "mac_address":
                                            macAddress,
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
                                    style: TextStyle(color: Colors.white,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox();
              }),
            ],
          ),
        )
      ),
    );
  }
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
  /*void _showColorPicker(BuildContext context) {
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
                          "mac_address": macAddress,
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
  }*/

  @override
  void initState() {
    // sqlDb.getDeviceDetailsByRoomID(widget.roomID);
    saved = false;
    super.initState();
  }
}
