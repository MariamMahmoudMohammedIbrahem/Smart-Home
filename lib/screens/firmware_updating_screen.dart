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
      body: SingleChildScrollView(
        child: SizedBox(
          height: height * .88,
          child: Center(
            child: Provider.of<AuthProvider>(context, listen: false)
                        .firmwareInfo ==
                    null
                ? Provider.of<AuthProvider>(context, listen: false).isConnected
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
                                Consumer(builder:
                                    (context, firmwareUpdating, child) {
                                  return Text(
                                    'Version ${Provider.of<AuthProvider>(context).firmwareInfo}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                                  /*FutureBuilder<List<Map<String, dynamic>>>(
                                    future: sqlDb.getDeviceDetailsByRoomID(
                                        roomIDs[index]),
                                    builder: (context, snapshot) {
                                      print('snapshot $snapshot');
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator(); // Show loading indicator
                                      } else if (snapshot.hasError) {
                                        return Text("Error: ${snapshot.error}");
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Text("No devices found.");
                                      } else {
                                        var deviceDetails = snapshot.data!;
                                        print(deviceDetails);
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemCount: deviceDetails.length,
                                          itemBuilder: (content, innerIndex) {
                                            final currentDevice =
                                                deviceDetails[innerIndex];
                                            final macAddress =
                                                currentDevice['MacAddress'];
// macVersion.any((device) => device['mac_address'] == deviceDetails[innerIndex]['MacAddress'] ,)? macVersion.firstWhere((device) =>device['mac_address'] == macAddress) : null;
                                            bool deviceInMacVersion =
                                                macVersion.any(
                                              (device) =>
                                                  device['mac_address'] ==
                                                  macAddress,
                                            );
                                            final macVersionItem =
                                                deviceInMacVersion
                                                    ? macVersion.firstWhere(
                                                        (device) =>
                                                            device[
                                                                'mac_address'] ==
                                                            macAddress)
                                                    : null;
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8.0,
                                                left: 8.0,
                                                right: 8.0,
                                              ),
                                              child: Consumer<AuthProvider>(
                                                builder: (context,
                                                    firmwareUpdating, child) {
                                                  return Column(
                                                    children: [
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons
                                                              .lightbulb_circle_outlined,
                                                          color:
                                                              Color(0xFF047424),
                                                        ),
                                                        title: Text(currentDevice[
                                                                'deviceName'] ??
                                                            'Switch'),

                                                        // Subtitle logic based on whether the device exists in macVersion
                                                        subtitle:
                                                            deviceInMacVersion
                                                                ? Text(
                                                                    '${macVersionItem!['firmware_version'] ?? 'disconnected'}',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  )
                                                                : const Text(
                                                                    'Device not connected',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .red),
                                                                  ),

                                                        // Trailing button logic based on macVersion status
                                                        trailing:
                                                            deviceInMacVersion
                                                                ? (macVersionItem?[
                                                                            'firmware_version'] ==
                                                                        Provider.of<AuthProvider>(context, listen: false)
                                                                            .firmwareInfo
                                                                    ? const Text(
                                                                        'up to date',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Color(0xFF047424),
                                                                        ),
                                                                      )
                                                                    : macVersion.firstWhere((device) => device['mac_address'] == deviceDetails[innerIndex]['MacAddress'],)['status'] == 'DOWNLOAD_NEW_FIRMWARE_START'
                                                                || macVersion.firstWhere((device) => device['mac_address'] == deviceDetails[innerIndex]['MacAddress'],)['status'] == 'DOWNLOAD_NEW_FIRMWARE_FAIL'
                                                                || macVersion.firstWhere((device) => device['mac_address'] == deviceDetails[innerIndex]['MacAddress'],)['status'] == 'DOWNLOAD_NEW_FIRMWARE_OK'
                                                                || '${macVersion.firstWhere((device) => device['mac_address'] == deviceDetails[innerIndex]['MacAddress'],)['status']}'.startsWith('updating')
                                                                        ? _buildWidgetBasedOnState(
                                                                            macVersionItem!)
                                                                        : ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              sendFrame({
                                                                                'commands': 'DOWNLOAD_NEW_FIRMWARE',
                                                                                'mac_address': macAddress,
                                                                              }, '255.255.255.255', 8888);
                                                                            },
                                                                            child:
                                                                                const Text('Update'),
                                                                          ))
                                                                : const SizedBox(), // Hide trailing with an empty SizedBox

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
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),*/
                                  FutureBuilder<List<Map<String, dynamic>>>(
                                    future: sqlDb.getDeviceDetailsByRoomID(roomIDs[index]),
                                    builder: (context, snapshot) {
                                      print('snapshot $snapshot');
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator(); // Show loading indicator
                                      } else if (snapshot.hasError) {
                                        return Text("Error: ${snapshot.error}");
                                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return const Text("No devices found.");
                                      } else {
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          itemCount: snapshot.data!.length,
                                          itemBuilder: (content, innerIndex) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8.0,
                                                left: 8.0,
                                                right: 8.0,
                                              ),
                                              child: Consumer<AuthProvider>(
                                                builder: (context, firmwareUpdating, child) {
                                                  final deviceMacAddress = snapshot.data![innerIndex]['MacAddress'];
                                                  final matchedDevice = macVersion.firstWhere(
                                                        (device) => device['mac_address'] == deviceMacAddress,
                                                    orElse: () => {}, // Provide a default value
                                                  );

                                                  final firmwareVersion = matchedDevice.isNotEmpty
                                                      ? matchedDevice['firmware_version'] ?? 'disconnected'
                                                      : 'Device not connected';

                                                  final deviceStatus = matchedDevice.isNotEmpty
                                                      ? matchedDevice['status'] ?? ''
                                                      : '';
                                                  print('total: $deviceMacAddress.\n '
                                                  '$macVersion.\n'
                                                      'updating: ${deviceStatus.toString().startsWith('updating')}${matchedDevice['status'] is double}');
                                                  return Column(
                                                    children: [
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons.lightbulb_circle_outlined,
                                                          color: Color(0xFF047424),
                                                        ),
                                                        title: Text(snapshot.data![innerIndex]['deviceName'] ?? 'Switch'),
                                                        subtitle: Text(
                                                          firmwareVersion,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: matchedDevice.isNotEmpty ? Colors.grey : Colors.red,
                                                          ),
                                                        ),
                                                        trailing: matchedDevice.isNotEmpty
                                                            ? (firmwareVersion == Provider.of<AuthProvider>(context, listen: false).firmwareInfo
                                                            ? const Text(
                                                          'up to date',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFF047424),
                                                          ),
                                                        )
                                                            : deviceStatus.toString().startsWith('updating') ||
                                                             deviceStatus is double ||
                                                            deviceStatus.toString() == 'DOWNLOAD_NEW_FIRMWARE_START' ||
                                                            deviceStatus.toString() == 'DOWNLOAD_NEW_FIRMWARE_FAIL' ||
                                                            deviceStatus.toString() == 'DOWNLOAD_NEW_FIRMWARE_OK'
                                                            ? _buildWidgetBasedOnState(matchedDevice)
                                                            : ElevatedButton(
                                                          onPressed: () {
                                                            Fluttertoast.showToast(
                                                              msg: 'wait a second',
                                                              backgroundColor: const Color(0xFF047424),
                                                              textColor: Colors.white,
                                                            );
                                                            sendFrame(
                                                              {
                                                                "commands": 'DOWNLOAD_NEW_FIRMWARE',
                                                                "mac_address": deviceMacAddress,
                                                              },
                                                              '255.255.255.255',
                                                              8888,
                                                            );
                                                          },
                                                          child: const Text('Update'),
                                                        ))
                                                            : ElevatedButton(
                                                          onPressed: () {
                                                            sendFrame(
                                                              {
                                                                'commands': 'CHECK_FOR_NEW_FIRMWARE',
                                                                'mac_address': deviceMacAddress,
                                                              },
                                                              '255.255.255.255',
                                                              8888,
                                                            );
                                                          },
                                                          child: const Text('check'),
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(20),
                                                          side: BorderSide(color: Colors.green.shade100),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
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
    );
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   SocketManager().startListen(context);
    // });
    checkFirmwareVersion(
            'firmware-update/switch', 'firmware_version.txt', context)
        .then(
      (value) => {
        print('inside initState'),
        /*setState(() {
          firmwareInfo = firmwareInfo;
        }),*/
        /*Provider.of<AuthProvider>(context).updateFirmwareVersion(value!),*/
      },
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

  Widget _buildWidgetBasedOnState(Map<String, dynamic> deviceStatus) {
    ///change firmware updating to the map
    int state = 0;
    if (deviceStatus['status'] == 'CHECK_FOR_NEW_FIRMWARE_SAME') {
      ///TODO: add case similarity
    } else if (deviceStatus['status'] == 'CHECK_FOR_NEW_FIRMWARE_OK') {
      ///TODO: add case complete check
    } else if (deviceStatus['status'] == 'CHECK_FOR_NEW_FIRMWARE_FAIL') {
      ///TODO: add case failed check
    } else if (deviceStatus['status'] == 'DOWNLOAD_NEW_FIRMWARE_START') {
      state = 2;
    } else if (deviceStatus['status'] == 'DOWNLOAD_NEW_FIRMWARE_FAIL') {
      state = 3;
    } else if ('${deviceStatus['status']}'.startsWith('updating')) {
      RegExp regExp =
          RegExp(r'_(\d+)'); // Match all numbers preceded by an underscore
      List<RegExpMatch> matches =
          regExp.allMatches(deviceStatus['status']).toList();
      for (var match in matches) {
        print('Match: ${match.group(1)}'); // Print each matched number
      }
      deviceStatus['status'] = double.parse(matches[0].group(1)!);
      print('is it double or not ${deviceStatus['status']}');
      state = 4;
    } else if(deviceStatus['status'] is double) {
      state = 4;
    }
    else if (deviceStatus['status'] == 'DOWNLOAD_NEW_FIRMWARE_OK') {
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
                  "mac_address": deviceStatus['mac_address']
                }, '255.255.255.255', 8888);
              },
              child: const Row(children: [
                Icon(
                  Icons.running_with_errors_rounded,
                  color: Colors.white,
                  size: 10,
                ),
                Text('retry'),
              ])),
        );

      case 4:
        double downloadProgress = deviceStatus['status'] / 100;
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
