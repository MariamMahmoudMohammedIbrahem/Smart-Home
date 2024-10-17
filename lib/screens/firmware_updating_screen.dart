import 'dart:async';
import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../constants/constants.dart';
import '../utils/functions.dart';

class FirmwareScreen extends StatefulWidget {
  const FirmwareScreen({super.key});

  @override
  State<FirmwareScreen> createState() => _FirmwareScreenState();
}

class _FirmwareScreenState extends State<FirmwareScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: const Color(0xFF70AD61),
        shadowColor: const Color(0xFF609e51),
        backgroundColor: const Color(0xFF047424),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: const Text(
          'Firmware Updating',
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.delayed(const Duration(milliseconds: 10), () {
          checkFirmwareVersion('firmware-update/switch', 'firmware_version.txt')
              .then(
            (value) => firmwareInfo = firmwareInfo,
          );
        }),
        /*onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          checkFirmwareVersion('firmware-update/switch', 'firmware_version.txt')
              .then(
            (value) => firmwareInfo = firmwareInfo,
          );
          print('refresh indicator?');
        },*/
        child: SingleChildScrollView(
          child: SizedBox(
            height: height * .88,
            child: Center(
              child: firmwareInfo == null
                  ? isConnected
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            Text('Checking for Updates')
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.signal_wifi_connected_no_internet_4_rounded,
                              size: 50,
                              color: Colors.grey.shade600,
                            ),
                            Text(
                              'No Internet Connection.',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600),
                            ),
                          ],
                        )
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: width * .07, vertical: 20),
                          padding: EdgeInsets.all(width * .03),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFF047424)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey.shade100,
                                    backgroundImage:
                                        const AssetImage('images/appIcon.png'),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'Version $firmwareInfo',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              /*Text(
                                '$info',
                                softWrap: true,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),*/
                              /*const Divider(
                                color: Colors.black,
                                thickness: 2,
                              ),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF047424),
                                      foregroundColor: Colors.white),
                                  onPressed: () {
                                    Provider.of<AuthProvider>(context, listen: false)
                                        .startedDownload = true;
                                    sendFrame({"commands": 'DOWNLOAD_NEW_FIRMWARE'},
                                        '255.255.255.255', 8888);
                                  },
                                  child: const Text('Update Now'),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                        /*ElevatedButton(onPressed: (){Provider.of<AuthProvider>(context, listen: false)
                            .startedDownload = true;
                        sendFrame({"commands": 'DOWNLOAD_NEW_FIRMWARE',"mac_address": "08:3A:8D:D0:AA:20"},
                            '255.255.255.255', 8888);}, child: Text('update',),),
                        ElevatedButton(onPressed: (){Provider.of<AuthProvider>(context, listen:false).firmwareUpdating('DOWNLOAD_NEW_FIRMWARE_START');}, child: const Text('DOWNLOAD_NEW_FIRMWARE_START',),),
                        ElevatedButton(onPressed: (){Provider.of<AuthProvider>(context, listen:false).firmwareUpdating('DOWNLOAD_NEW_FIRMWARE_FAIL');}, child: const Text('DOWNLOAD_NEW_FIRMWARE_FAIL',),),
                        ElevatedButton(onPressed: (){Provider.of<AuthProvider>(context, listen:false).firmwareUpdating('DOWNLOAD_NEW_FIRMWARE_OK');}, child: const Text('DOWNLOAD_NEW_FIRMWARE_OK',),),
                        ElevatedButton(onPressed: (){Provider.of<AuthProvider>(context, listen:false).firmwareUpdating('DOWNLOAD_NEW_FIRMWARE_UPDATING_444688_444688');}, child: const Text('DOWNLOAD_NEW_FIRMWARE_UPDATING',),),*/
                        /*Consumer<AuthProvider>(
                            builder: (context, firmwareUpdating, child) {
                          return firmwareUpdating.similarityCheck
                              ? const Column(
                                  children: [
                                    Icon(Icons.file_download_off_rounded),
                                    Text('there is no updates'),
                                  ],
                                )
                              : Visibility(
                                  visible: true,
                                  child: firmwareUpdating.startedDownload
                                      ? const CircularProgressIndicator()
                                      : firmwareUpdating.downloadPercentage <= 100
                                          ? (firmwareUpdating.failedDownload
                                              ? const CircleAvatar(
                                                  radius: 50,
                                                  backgroundColor: Color(0xFF047424),
                                                  child: Icon(
                                                    Icons.running_with_errors_rounded,
                                                    color: Colors.white,
                                                    size: 50,
                                                  ),
                                                )
                                              : Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      height: 100,
                                                      child:
                                                          CircularProgressIndicator(
                                                        value:
                                                            downloadProgress, // Progress from 0.0 to 1.0
                                                        strokeWidth:
                                                            8, // Thickness of the circle
                                                        backgroundColor:
                                                            Colors.grey.shade200,
                                                        valueColor:
                                                            const AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Color(0xFF047424)),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${(downloadProgress * 100).toStringAsFixed(0)}%',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF047424),
                                                      ),
                                                    ),
                                                  ],
                                                ))
                                          : firmwareUpdating.completedDownload
                                              ? const CircleAvatar(
                                                  radius: 50,
                                                  backgroundColor: Color(0xFF047424),
                                                  child: Icon(
                                                    Icons.done,
                                                    color: Colors.white,
                                                    size: 50,
                                                  ),
                                                )
                                              : const CircularProgressIndicator(),
                                );
                        }),*/
                        /*ElevatedButton(
                          onPressed: () {
                            sendFrame({
                              "commands": "CHECK_FOR_NEW_FIRMWARE",
                              "mac_address": "60:01:94:21:4B:06"
                            }, '255.255.255.255', 8888);
                          },
                          child: const Text('check for new updates'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false).firmwareUpdating(
                                {"commands":'DOWNLOAD_NEW_FIRMWARE_UPDATING_14848_444576'});
                          },
                          child: const Text('check updating ui'),
                        ),*/
                        /*Consumer<AuthProvider>(
                            builder: (context, firmwareUpdating, child) {
                          return _buildWidgetBasedOnState(firmwareUpdating);
                        }),*/
                        Expanded(
                          child: ListView.builder(
                            itemCount: roomNames.length,
                            itemBuilder: (context, index) {
                              sqlDb.getDeviceDetailsByRoomID(roomIDs[index]);
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.07, vertical: 10),
                                child: ExpansionTile(
                                  title: Row(
                                    children: [
                                      Icon(
                                        getIconName(roomNames[index]),
                                        color: const Color(0xFF047424),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        roomNames[index],
                                      ),
                                    ],
                                  ),
                                  children: [
                                    FutureBuilder<List<Map<String, dynamic>>>(
                                      future: sqlDb.getDeviceDetailsByRoomID(
                                          roomIDs[index]),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator(); // Show loading indicator
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              "Error: ${snapshot.error}");
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return const Text(
                                              "No devices found.");
                                        } else {
                                          var deviceDetails = snapshot.data!;
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            itemCount: deviceDetails.length,
                                            itemBuilder: (content, innerIndex) {
                                              print('inner index is $innerIndex , $deviceDetails');
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0,
                                                    left: 8.0,
                                                    right: 8.0),
                                                child: Consumer<AuthProvider>(
                                                    builder: (context,
                                                        firmwareUpdating,
                                                        child) {
                                                      print('${macVersion.isEmpty}, ${
                                                      !macVersion
                                                          .contains({
    'MacAddress':
    deviceDetails[innerIndex]['MacAddress']
    })}');
                                                  return Column(
                                                    children: [
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons
                                                              .lightbulb_circle_outlined,
                                                          color:
                                                              Color(0xFF047424),
                                                        ),
                                                        title: Text(deviceDetails[
                                                                    innerIndex][
                                                                'deviceName'] ??
                                                            'Switch'),
                                                        trailing: macVersion
                                                                    .isNotEmpty &&
                                                                macVersion.firstWhere((device) => device['mac_address'] == deviceDetails[0]['MacAddress'], orElse: ()=>{'mac_address': ''},)['firmware_version'] ==
                                                                    firmwareInfo
                                                            ? const Text(
                                                                'up to date',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF047424)),
                                                              )
                                                            : firmwareUpdating
                                                                        .updating &&
                                                                    firmwareUpdating.macFirmware ==
                                                                        deviceDetails[innerIndex][
                                                                            'MacAddress']
                                                                ? _buildWidgetBasedOnState(
                                                                    firmwareUpdating)
                                                                : macVersion.isEmpty ||
                                                                        macVersion
                                                                            .contains({
                                                                          'MacAddress':
                                                                              deviceDetails[innerIndex]['MacAddress']
                                                                        })
                                                                    ? ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          sendFrame(
                                                                              {
                                                                                'commands': 'CHECK_FOR_NEW_FIRMWARE',
                                                                                'mac_address': deviceDetails[innerIndex]['MacAddress']
                                                                              },
                                                                              '255.255.255.255',
                                                                              8888);
                                                                        },
                                                                        child: const Text(
                                                                            'check'),
                                                                      )
                                                                    : ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          ///check if the version needs to be updated
                                                                          if (kDebugMode) {
                                                                            print('device details mac address of inner index ${deviceDetails[innerIndex]}');
                                                                          }
                                                                          /*if(macVersion.isEmpty){
                                                                sendFrame({
                                                                  "commands":
                                                                  'CHECK_FOR_NEW_FIRMWARE ',
                                                                  "mac_address":
                                                                  deviceDetails[innerIndex]
                                                                  ['MacAddress'],
                                                                }, '255.255.255.255', 8888);
                                                              }
                                                              else{
                                                                for (Map<String, bool> map in macVersion) {
                                                                  print('here => $map');
                                                                  if (map.containsKey(deviceDetails[innerIndex]['MacAddress'])) {
                                                                    print('map[deviceDetails[innerIndex]] => ${map[deviceDetails[innerIndex]['MacAddress']]}');
                                                                    if(!map[deviceDetails[innerIndex]['MacAddress']]!){
                                                                      Provider.of<AuthProvider>(
                                                                          context,
                                                                          listen: false)
                                                                          .startedDownload = true;
                                                                      sendFrame({
                                                                        "commands":
                                                                        'DOWNLOAD_NEW_FIRMWARE',
                                                                        "mac_address":
                                                                        deviceDetails[innerIndex]
                                                                        ['MacAddress']
                                                                      }, '255.255.255.255', 8888);
                                                                    }
                                                                    */ /*map[deviceDetails[innerIndex]]?sendFrame({
                                                              "commands":
                                                              'CHECK_FOR_NEW_FIRMWARE ',
                                                              "mac_address":
                                                              deviceDetails[innerIndex]
                                                              ['MacAddress'],
                                                              }, '255.255.255.255', 8888):Provider.of<AuthProvider>(
                                                                      context,
                                                                      listen: false)
                                                                      .startedDownload = true;
                                                                  sendFrame({
                                                                    "commands":
                                                                    'DOWNLOAD_NEW_FIRMWARE',
                                                                    "mac_address":
                                                                    deviceDetails[innerIndex]
                                                                    ['MacAddress']
                                                                  }, '255.255.255.255', 8888);*/ /*
                                                                  }
                                                                }
                                                              }*/
                                                                          ///download new firmware version
                                                                          Provider.of<AuthProvider>(context, listen: false).updating =
                                                                              true;
                                                                          Provider.of<AuthProvider>(context, listen: false).startedDownload =
                                                                              true;
                                                                          Fluttertoast.showToast(
                                                                              msg: 'wait a second',
                                                                              backgroundColor: const Color(0xFF047424),
                                                                              textColor: Colors.white);
                                                                          sendFrame(
                                                                              {
                                                                                "commands": 'DOWNLOAD_NEW_FIRMWARE',
                                                                                "mac_address": deviceDetails[innerIndex]['MacAddress']
                                                                              },
                                                                              '255.255.255.255',
                                                                              8888);
                                                                        },
                                                                        child: const Text(
                                                                            'Update'),
                                                                      ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          side: BorderSide(
                                                              color: Colors
                                                                  .green
                                                                  .shade100),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  bool isConnected = true;
  void extractDataFromJson(String jsonString) {
    // Parse the JSON string into a Map
    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    // Extract values and store them in variables
    setState(() {
      version = jsonData['firmware_version'];
      info = jsonData['info'];
    });

    // Use the variables as needed
    if (kDebugMode) {
      print('Firmware Version: $version');
      print('Info: $info');
    }
  }

  Future<String?> checkFirmwareVersion(
      String folderPath, String fileName) async {
    isConnected = await isConnectedToInternet();
    if (!isConnected) {
      setState(() {
        isConnected = false;
      });
      return '';
    }
    try {
      // Reference to the file in Firebase Storage (nested folder structure)
      Reference storageRef =
          FirebaseStorage.instance.ref().child('$folderPath/$fileName');

      // Download the file content as raw bytes (limit to 1 MB)
      final fileData = await storageRef.getData(1024 * 1024);

      if (fileData != null) {
        // Convert file data from bytes to string
        setState(() {
          firmwareInfo = utf8.decode(fileData);
        });
        if (kDebugMode) {
          print("File content: $firmwareInfo");
        }
        return firmwareInfo;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error reading file from Firebase: $e");
      }
    }
    return null;
  }

  bool failed = false;
  Timer? timerPeriodic;
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   SocketManager().startListen(context);
    // });
    checkFirmwareVersion('firmware-update/switch', 'firmware_version.txt').then(
      (value) => firmwareInfo = firmwareInfo,
    );
    // .then((value) {
    // if (firmwareInfo ==
    //     Provider.of<AuthProvider>(context, listen: false).firmwareVersion) {
    //   Provider.of<AuthProvider>(context, listen: false)
    //       .firmwareUpdating("CHECK_FOR_NEW_FIRMWARE_SAME");
    // } else {
    //   sendFrame({
    //     "commands": "DOWNLOAD_NEW_FIRMWARE",
    //     "mac_address": "08:3A:8D:D0:AA:20"
    //   }, "255.255.255.255", 8888);
    //   print('not similar');
    // }
    // });
  }

  AuthProvider? _authProvider;
  @override
  void didChangeDependencies() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _authProvider?.similarityDownload = false;
    _authProvider?.startedDownload = false;
    _authProvider?.failedDownload = false;
    _authProvider?.completedDownload = false;
    _authProvider?.downloadPercentage = 0;
    super.dispose();
  }

  Widget _buildWidgetBasedOnState(AuthProvider firmwareUpdating) {
    int state = 0;

    if (kDebugMode) {
      print(firmwareUpdating.similarityCheck);
      print(firmwareUpdating.startedDownload);
      print(firmwareUpdating.failedDownload);
      print(firmwareUpdating.downloadPercentage);
      print(firmwareUpdating.completedDownload);
    }
    if (firmwareUpdating.similarityCheck) {
      ///TODO: add case similarity
    } else if (firmwareUpdating.completedCheck) {
      ///TODO: add case complete check
    } else if (firmwareUpdating.failedCheck) {
      ///TODO: add case failed check
    } else if (firmwareUpdating.startedDownload) {
      state = 2;
    } else if (firmwareUpdating.failedDownload) {
      state = 3;
    } else if (firmwareUpdating.downloadPercentage < 100 &&
        !firmwareUpdating.similarityCheck) {
      if (kDebugMode) {
        print(
            'firmwareUpdating.downloadPercentage => ${firmwareUpdating.downloadPercentage}');
      }
      state = 4;
    } else if (firmwareUpdating.completedDownload) {
      state = 5;
    }
    if (kDebugMode) {
      print('state $state');
    }
    switch (state) {
      case 1:
        return const Column(
          children: [
            Icon(Icons.file_download_off_rounded),
            Text('There is no updates'),
          ],
        );

      case 2:
        return const CircularProgressIndicator();

      case 3:
        return CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFF047424),
          child: ElevatedButton(
              onPressed: () {
                sendFrame({
                  "commands": 'DOWNLOAD_NEW_FIRMWARE',
                  "mac_address": firmwareUpdating.macAddress
                }, '255.255.255.255', 8888);
              },
              child: const Row(children: [
                Icon(
                  Icons.running_with_errors_rounded,
                  color: Colors.white,
                  size: 50,
                ),
                Text('re-update'),
              ])),
        );

      case 4:
        double downloadProgress = firmwareUpdating.downloadPercentage / 100;
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: downloadProgress, // Progress from 0.0 to 1.0
                strokeWidth: 8, // Thickness of the circle
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF047424),
                ),
              ),
            ),
            Text(
              '${(downloadProgress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF047424),
              ),
            ),
          ],
        );

      case 5:
        return const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFF047424),
          child: Icon(
            Icons.done,
            color: Colors.white,
            size: 50,
          ),
        );

      default:
        return const SizedBox();
    }
  }
}
