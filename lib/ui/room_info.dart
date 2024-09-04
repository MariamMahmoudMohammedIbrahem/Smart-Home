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
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.pink.shade100,
        shadowColor: Colors.pink.shade200,
        backgroundColor: Colors.pink.shade900,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20),),),
        title: Row(
          children: [
            Text(
              widget.roomName,
            ),
            const SizedBox(width: 5,),
            Icon(getIconName(widget.roomName)),
          ],
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .07, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Visibility(
                visible: deviceDetails.length > 1,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: deviceDetails.asMap().entries.map((entry) {
                      Map<String, dynamic> device = entry.value;
                      String macAddressDevice = device['MacAddress'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7.5),
                        child: ElevatedButton(
                          onPressed: () {
                            print('macAddress is => $deviceStatus');
                            print('macAddress is => $macAddressDevice');
                            setState(() {
                              macAddress = macAddressDevice;
                            });
                          },
                          onLongPress: (){
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: Icon(
                                          Icons.delete,
                                          color: Colors.pink.shade900,
                                        ),
                                        title: Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.pink.shade900,
                                          ),
                                        ),
                                        onTap: () {
                                          ///add delete switch function
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                            );
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
                        ),
                      );
                    }).toList(),
                  ),
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
                  crossAxisCount: 2,
                  mainAxisSpacing: 30.0,
                  crossAxisSpacing: 10.0,
                ),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Consumer<AuthProvider>(builder:
                        (context, switchesProvider, child) {
                     return Container(
                       decoration: BoxDecoration(
                         color: deviceStatus.firstWhere(
                               (device) => device['MacAddress'] == macAddress,
                         )['sw${index+1}']==1?Colors.pink.shade50:Colors.grey.shade200,
                         borderRadius: BorderRadius.circular(
                           20,
                         ),
                         border: Border.all(color: deviceStatus.firstWhere(
                               (device) => device['MacAddress'] == macAddress,
                         )['sw${index+1}']==1?Colors.pink.shade900:Colors.grey.shade800,),
                       ),
                       padding:
                       const EdgeInsets.symmetric(horizontal: 20),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             mainAxisAlignment:
                             MainAxisAlignment.spaceBetween,
                             children: [
                               Icon(
                                 Icons.lightbulb_circle,
                                 color: deviceStatus.firstWhere(
                                       (device) => device['MacAddress'] == macAddress,
                                 )['sw${index+1}']==1?Colors.pink.shade900:Colors.grey.shade800,
                                 size: 40,
                               ),
                               Row(
                                 mainAxisAlignment:
                                 MainAxisAlignment.spaceBetween,
                                 children: [
                                   Switch(
                                     activeColor: Colors.pink.shade300,
                                     activeTrackColor:
                                     Colors.pink.shade700,
                                     inactiveThumbColor:
                                     Colors.grey.shade300,
                                     inactiveTrackColor:
                                     Colors.grey.shade800,
                                     splashRadius: 50.0,
                                     value: deviceStatus.firstWhere(
                                           (device) => device['MacAddress'] == macAddress,
                                     )['sw${index+1}']==1?true:false,
                                     onChanged: (value) {
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
                                     },
                                   ),
                                 ],
                               ),
                               // }),
                             ],
                           ),
                           Text(
                             'light lamp',
                             style: TextStyle(
                                 color: deviceStatus.firstWhere(
                                       (device) => device['MacAddress'] == macAddress,
                                 )['sw${index+1}']==1?Colors.pink.shade900:Colors.grey.shade800,
                                 fontSize: 20,
                                 fontWeight: FontWeight.bold),
                           ),
                         ],
                       ),
                     );
                  }),
                  );
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
                              .white,
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

  @override
  void initState() {
    saved = false;
    super.initState();
  }
}
