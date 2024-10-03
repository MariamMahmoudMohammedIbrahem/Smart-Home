import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mega/udp.dart';
import 'package:mega/ui/room_info.dart';
import 'package:mega/ui/settings.dart';
import 'package:mega/ui/upload_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
    as qr_scan;
import 'package:sqflite/sqflite.dart';
import '../constants.dart';
import '../db/functions.dart';
import '../help.dart';
import 'download_file.dart';

class Rooms extends StatefulWidget {
  const Rooms({super.key});

  @override
  State<Rooms> createState() => _RoomsState();
}

class _RoomsState extends State<Rooms> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Animation<double>? _animation;
  AnimationController? _animationController;
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  Future<void> scanQR() async {
    try {
      barcodeScanRes = await qr_scan.FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, qr_scan.ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = 'Failed to Scan QR Code';
    }
    if (!mounted) return;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SocketManager().startListen(context);
    });
    sqlDb
        .getRoomsByDepartmentID(context, departmentMap.first['DepartmentID'])
        .then((value) {
      setState(() {
        Provider.of<AuthProvider>(context, listen: false)
            .toggling('loading', false);
      });
    });
    print('inside init $roomNames');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController!);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _isMenuOpen = false;
    super.dispose();
  }

  String _status = 'Ready to export data';
  String? _uploadStatus;
  String downloadURL = '';

  @override
  Widget build(context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          departmentMap.isNotEmpty ? departmentMap.first['DepartmentName'] : '',
        ),
        titleTextStyle: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Color(0xFF047424),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const Setting()));
            },
            icon: const Icon(
              Icons.settings_rounded,
              color: Color(0xFF047424),
            ),
          )
          /*PopupMenuButton<int>(
            icon: const Icon(
              Icons.menu_open_rounded,
              color: Color(0xFF047424),
            ), // The 3-dot icon
            onSelected: (value) {
              if (value == 1) {
                Provider.of<AuthProvider>(context, listen: false)
                    .checkFirstTime()
                    .then((value) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UploadDatabase(),
                        )));
              } else if (value == 2) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScanPage(),
                    ));
              } else if( value == 3){
                Provider.of<AuthProvider>(context, listen: false)
                    .toggling('adding', false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UDPScreen(),
                  ),
                );
              }
              */
          /*else if (value == 3) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FirmwareScreen(),
                    ));
              }*/
          /*
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      color: Color(0xFF047424),
                    ),
                    Text(
                      'Create QR Code',
                      style: TextStyle(
                        color: Color(0xFF047424),
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Color(0xFF047424),
                    ),
                    Text(
                      'Scan',
                      style: TextStyle(
                        color: Color(0xFF047424),
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 3,
                child: Row(
                  children: [
                    Icon(
                      Icons.device_unknown,
                      color: Color(0xFF047424),
                    ),
                    Text(
                      'Add Device',
                      style: TextStyle(
                        color: Color(0xFF047424),
                      ),
                    ),
                  ],
                ),
              ),
             */ /* const PopupMenuItem(
                value: 3,
                child: Row(
                  children: [
                    Icon(
                      Icons.system_security_update_rounded,
                      color: Color(0xFF047424),
                    ),
                    Text(
                      'Firmware Update',
                      style: TextStyle(
                        color: Color(0xFF047424),
                      ),
                    ),
                  ],
                ),
              ),*/ /*
            ],
            offset: const Offset(
                0, 50), // Adjust the Y-axis offset to move the menu down
          ),*/
        ],
      ),
      /*floatingActionButton: FloatingActionBubble(
        items: <Bubble>[
          Bubble(
            title: "Add Device",
            iconColor: Colors.white,
            bubbleColor: const Color(0xFF047424),
            icon: Icons.device_unknown,
            titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              _animationController!.reverse();
              setState(() {
                _isMenuOpen = false;
              });
              Provider.of<AuthProvider>(context, listen: false)
                  .toggling('adding', false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UDPScreen(),
                ),
              );
            },
          ),
          Bubble(
            title: "Add Department",
            iconColor: Colors.white,
            bubbleColor: const Color(0xFF047424),
            icon: Icons.home,
            titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              _showDialog(context, 'addDepartment', 0);
            },
          ),
        ],
        animation: _animation!,
        onPress: () {
          _animationController!.isCompleted
              ? _animationController!.reverse()
              : _animationController!.forward();
          _toggleMenu();
        },
        backGroundColor: const Color(0xFF047424),
        iconColor: Colors.white,
        iconData: _isMenuOpen ? Icons.close : Icons.add,
      ),*/
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .05, vertical: 10),
          child: Column(
            children: [
              /*ElevatedButton(
                onPressed: () {
                  checkFirmwareVersion('firmware-update/switch','firmware_version.txt').then((value) {
                    if (firmwareInfo ==
                        Provider.of<AuthProvider>(context, listen: false)
                            .firmwareVersion) {
                      Provider.of<AuthProvider>(context, listen: false)
                          .firmwareUpdating("CHECK_FOR_NEW_FIRMWARE_SAME");
                    } else {
                      sendFrame({
                        "commands": "DOWNLOAD_NEW_FIRMWARE",
                        "mac_address": "08:3A:8D:D0:AA:20"
                      }, "255.255.255.255", 8888);
                      print('not similar');
                    }
                  });
                },
                child: const Text('get version name'),
              ),*/
              /*ElevatedButton(
                onPressed: () {
                  sqlDb
                      .insertRoom('Desk', departmentMap.first['DepartmentID'])
                      .then((value) {
                    sqlDb.getRoomsByDepartmentID(
                        context, departmentMap.first['DepartmentID']);
                    sqlDb.insertDevice(
                      '60:01:94:21:4B:06',
                      'Hardware_room',
                      '01019407823EOIP',
                      'switch',
                      value,
                    ).then((value) => sqlDb.exportData().then(
                            (value) => Provider.of<AuthProvider>(
                            context,
                            listen: false)
                            .toggling('adding', false)));
                  });
                },
                child: const Text(
                  'insert rooms and devices',
                ),
              ),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rooms',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: Color(0xFF047424),
                    ),
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, toggleProvider, child) {
                      return IconButton(
                        onPressed: () {
                          toggleProvider.toggling(
                              'toggling', !toggleProvider.toggle);
                        },
                        icon: Icon(
                          toggleProvider.toggle
                              ? Icons.grid_view_rounded
                              : Icons.list_outlined,
                          color: const Color(0xFF047424),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Consumer<AuthProvider>(
                builder: (context, loadingProvider, child) {
                  return Flexible(
                    child: loadingProvider.isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF047424),
                          )
                        : roomNames.isEmpty
                            ? const SizedBox(
                                child: Text(
                                  'There is no data to show',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Color(0xFF047424),
                                  ),
                                ),
                              )
                            : Provider.of<AuthProvider>(context).toggle
                                ? GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent:
                                          width * 0.45, //   crossAxisCount: 2,
                                      mainAxisSpacing: 15.0,
                                      crossAxisSpacing: 15.0,
                                      mainAxisExtent: height * .27,
                                    ),
                                    itemCount: roomNames.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            color: const Color(0xFF047424),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20.0),
                                                child: AutoSizeText(
                                                  roomNames[index],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  minFontSize: 23.0,
                                                  maxFontSize: 25.0,
                                                  maxLines: 2,
                                                ),
                                              ),
                                              Icon(
                                                getIconName(roomNames[index]),
                                                color: Colors.white,
                                                size: width * .25,
                                              ),
                                            ],
                                          ),
                                        ),
                                        onLongPress: () {
                                          _showOptions(context, index);
                                        },
                                        onTap: () {
                                          sqlDb
                                              .getDeviceDetailsByRoomID(
                                                  roomIDs[index])
                                              .then(
                                                (value) => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        RoomDetail(
                                                      roomName:
                                                          roomNames[index],
                                                      roomID: roomIDs[index],
                                                    ),
                                                  ),
                                                ),
                                              );
                                        },
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    itemCount: roomNames.length,
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
                                              color: const Color(0xFF047424),
                                            ),
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  getIconName(roomNames[index]),
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                                const SizedBox(
                                                  width: 5.0,
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: AutoSizeText(
                                                    roomNames[index],
                                                    style: const TextStyle(
                                                      fontSize: 18.0,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    minFontSize: 16.0,
                                                    maxFontSize: 18.0,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            sqlDb
                                                .getDeviceDetailsByRoomID(
                                                    roomIDs[index])
                                                .then(
                                                  (value) => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          RoomDetail(
                                                        roomName:
                                                            roomNames[index],
                                                        roomID: roomIDs[index],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                          },
                                          onLongPress: () {
                                            _showOptions(context, index);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(context, int index) {
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
                leading: const Icon(
                  Icons.edit,
                  color: Color(0xFF047424),
                ),
                title: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Color(0xFF047424),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDialog(context, 'editRoomName', index);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Color(0xFF047424),
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Color(0xFF047424),
                  ),
                ),
                onTap: () {
                  sqlDb.deleteRoomsAndDevices(roomIDs[index]).then((value) => {
                        sqlDb
                            .getRoomsByDepartmentID(
                                context, departmentMap.first['DepartmentID'])
                            .then((value) => {
                                  setState(() {
                                    Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .toggling('loading', false);
                                  }),
                                  Navigator.pop(context),
                                }),
                      });
                },
              ),
            ],
          ),
        );
      },
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showDialog(context, String type, int index) {
    showDialog(
        context: context,
        builder: (context) {
          IconData? selectedIconInDialog = getIconName(roomNames[index]);
          String? hintMessage;
          return type == 'addDepartment'
              ? AlertDialog(
                  title: const Text(
                    'Add New Department',
                    style: TextStyle(color: Color(0xFF047424)),
                  ),
                  content: TextFormField(),
                  actions: [
                    TextButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF047424),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel',
                          style: TextStyle(color: Color(0xFF047424))),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF047424)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              : StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: const Text(
                        'Edit Room Name',
                        style: TextStyle(color: Color(0xFF047424)),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            DropdownButton<IconData>(
                              value: selectedIconInDialog,
                              menuMaxHeight: 200,
                              icon: const Icon(
                                Icons.arrow_downward,
                                color: Color(0xFF047424),
                              ),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Color(0xFF047424)),
                              underline: Container(
                                height: 2,
                                color: const Color(0xFF047424),
                              ),
                              onChanged: (IconData? newValue) {
                                setStateDialog(() {
                                  selectedIconInDialog = newValue;
                                  selectedIcon = newValue!;
                                  String selectedRoomName =
                                      getRoomName(newValue);
                                  if (roomNames.contains(selectedRoomName)) {
                                    hintMessage =
                                        'This room name is already in use!';
                                  } else {
                                    hintMessage = null;
                                  }
                                  print('Selected Icon is => $selectedIcon');
                                });
                              },
                              items: iconsRooms.map<DropdownMenuItem<IconData>>(
                                  (IconData icon) {
                                return DropdownMenuItem<IconData>(
                                  value: icon,
                                  child: Row(
                                    children: [
                                      Icon(
                                        icon,
                                        color: const Color(0xFF455D56),
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(
                                        getRoomName(icon),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setStateDialog(() {
                                      roomName = getRoomName(icon);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            if (hintMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  hintMessage!,
                                  style: TextStyle(color: Colors.red.shade800),
                                ),
                              ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF047424),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel',
                              style: TextStyle(color: Color(0xFF047424))),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF047424)),
                          onPressed: () {
                            if (hintMessage == null) {
                              sqlDb
                                  .updateRoomName(
                                      departmentMap.first['DepartmentID'],
                                      roomName,
                                      roomNames[index])
                                  .then(
                                    (value) => sqlDb.getRoomsByDepartmentID(
                                        context,
                                        departmentMap.first['DepartmentID']),
                                  )
                                  .then((value) {
                                setState(() {
                                  Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .toggling('loading', false);
                                });
                                Navigator.pop(context);
                              });
                            }
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                );
        });
    _animationController!.reverse();
    setState(() {
      _isMenuOpen = false;
    });
  }
}
