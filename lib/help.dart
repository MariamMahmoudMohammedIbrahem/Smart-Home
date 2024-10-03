import 'dart:async';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'constants.dart';
import 'db/functions.dart';

/*class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  OtpScreenState createState() => OtpScreenState();
}

class OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(5, (_) => TextEditingController());

  void _submitOtp() {
    String otp = _controllers.map((controller) => controller.text).join();
    // Implement OTP validation logic with the complete OTP string
    print("Entered OTP is: $otp");
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Enter the OTP on the other mobile',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _controllers[index],
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 4) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitOtp,
              child: const Text('Submit'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                int randomPort = min + random.nextInt(max - min + 1);

                print('Random port: $randomPort');
              },
              child: const Text('generate random number'),
            ),
          ],
        ),
      ),
    );
  }
}*/

double downloadProgress = 0.0;

class FirmwareScreen extends StatefulWidget {
  const FirmwareScreen({super.key});

  @override
  FirmwareScreenState createState() => FirmwareScreenState();
}

class FirmwareScreenState extends State<FirmwareScreen> {
  /*Future<void> fetchFirmwareInfo() async {
    try {
      final info = await getLatestFirmwareInfo();
      setState(() {
        firmwareInfo = info['name'];
      });
    } catch (e) {
      print('Error fetching firmware info: $e');
    }
  }*/
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
    print('Firmware Version: $version');
    print('Info: $info');
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
        print("File content: $firmwareInfo");
        return firmwareInfo;
      }
    } catch (e) {
      print("Error reading file from Firebase: $e");
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

    print(firmwareUpdating.similarityCheck);
    print(firmwareUpdating.startedDownload);
    print(firmwareUpdating.failedDownload);
    print(firmwareUpdating.downloadPercentage);
    print(firmwareUpdating.completedDownload);
    if(firmwareUpdating.similarityCheck){
    ///TODO: add case similarity
    }else if (firmwareUpdating.completedCheck) {
      ///TODO: add case complete check
    }else if (firmwareUpdating.failedCheck) {
      ///TODO: add case failed check
    } else if (firmwareUpdating.startedDownload) {
      state = 2;
    } else if (firmwareUpdating.failedDownload) {
      state = 3;
    }
    else if (firmwareUpdating.downloadPercentage < 100 && !firmwareUpdating.similarityCheck) {
      print(
          'firmwareUpdating.downloadPercentage => ${firmwareUpdating.downloadPercentage}');
      state = 4;
    } else if (firmwareUpdating.completedDownload) {
      state = 5;
    }
    print('state $state');
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: const Color(0xFF70ad61),
        shadowColor: const Color(0xFF609E51),
        backgroundColor: const Color(0xFF047424),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        )),
        title: const Text(
          'Firmware Update',
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
                              color: Colors.green.shade50),
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
                                    /*ListView.builder(
                                        shrinkWrap:
                                            true, // This prevents infinite height error
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: deviceDetails.length,
                                        itemBuilder: (content, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0, left: 8.0, right: 8.0),
                                            child: ListTile(
                                              leading: const Icon(
                                                Icons.lightbulb_circle_outlined,
                                                color: Color(0xFF047424),
                                              ),
                                              title: const Text('switch1'),
                                              trailing: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  side: BorderSide(
                                                      color: Colors.green.shade100),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    // isUpdating = true;
                                                  });
                                                },
                                                child: const Text(
                                                  'update',
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  20,
                                                ),
                                                side: BorderSide(
                                                  color: Colors.green.shade100,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),*/
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
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0,
                                                    left: 8.0,
                                                    right: 8.0),
                                                child: Consumer<AuthProvider>(
                                                    builder: (context,
                                                        firmwareUpdating,
                                                        child) {
                                                  return Column(
                                                    children: [
                                                      Text('${deviceDetails[
                                                      innerIndex]
                                                      [
                                                      'FirmwareVersion'] ==
                                                          firmwareInfo ||
                                                          firmwareUpdating
                                                              .completedDownload &&
                                                              firmwareUpdating
                                                                  .macFirmware ==
                                                                  deviceDetails[
                                                                  innerIndex]
                                                                  [
                                                                  'MacAddress']}'),
                                                      Text('${deviceDetails[innerIndex]['FirmwareVersion']}-1-$firmwareInfo-2-${firmwareUpdating.completedDownload}-3-${firmwareUpdating.macFirmware}-4-${deviceDetails[innerIndex]['MacAddress']}'),
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons
                                                              .lightbulb_circle_outlined,
                                                          color: Color(0xFF047424),
                                                        ),
                                                        title: Text(deviceDetails[
                                                                    innerIndex]
                                                                ['deviceName'] ??
                                                            'Switch'),
                                                        trailing: deviceDetails[
                                                                            innerIndex]
                                                                        [
                                                                        'FirmwareVersion'] ==
                                                                    firmwareInfo ||
                                                                firmwareUpdating
                                                                        .completedDownload &&
                                                                    firmwareUpdating
                                                                            .macFirmware ==
                                                                        deviceDetails[
                                                                                innerIndex]
                                                                            [
                                                                            'MacAddress']
                                                            ? const Text(
                                                                'up to date',
                                                                style: TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF047424)),
                                                              )
                                                            : firmwareUpdating
                                                                        .updating &&
                                                                    firmwareUpdating
                                                                            .macFirmware ==
                                                                        deviceDetails[
                                                                                innerIndex]
                                                                            [
                                                                            'MacAddress']
                                                                ? /*const CircularProgressIndicator()
                                                                    : */
                                                                _buildWidgetBasedOnState(
                                                                    firmwareUpdating)
                                                                : ElevatedButton(
                                                                    onPressed: () {
                                                                      ///check if the version needs to be updated
                                                                      print(
                                                                          'device details mac address of inner index ${deviceDetails[innerIndex]}');
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
                                                                      Provider.of<AuthProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .updating = true;
                                                                      Provider.of<AuthProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .startedDownload = true;
                                                                      Fluttertoast.showToast(
                                                                          msg:
                                                                              'wait a second',
                                                                          backgroundColor:
                                                                              const Color(
                                                                                  0xFF047424),
                                                                          textColor:
                                                                              Colors
                                                                                  .white);
                                                                      sendFrame({
                                                                        "commands":
                                                                            'DOWNLOAD_NEW_FIRMWARE',
                                                                        "mac_address":
                                                                            deviceDetails[innerIndex]
                                                                                [
                                                                                'MacAddress']
                                                                      }, '255.255.255.255',
                                                                          8888);
                                                                    },
                                                                    child: const Text(
                                                                        'Update'),
                                                                  ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  20),
                                                          side: BorderSide(
                                                              color: Colors
                                                                  .green.shade100),
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
}

/*class AddingDevice extends StatefulWidget {
  const AddingDevice({super.key});

  @override
  State<AddingDevice> createState() => _AddingDeviceState();
}

class _AddingDeviceState extends State<AddingDevice> {
  // @override
  // void dispose() {
    // Provider.of<AuthProvider>(context, listen: false).loadingToggling(false);
    // super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          */
/*ElevatedButton(
            onPressed: () {
              sqlDb.insertRoom('Living Room', 2).then((value) {
                sqlDb.getRoomsByDepartmentID(2).then((value) {
                  setState(() {
                    loading = false;
                  });
                  Navigator.pop(context);
                });
              });
            },
            child: const Text(
              'add Living Room',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              sqlDb.insertRoom('Baby Bedroom', 2).then((value) {
                sqlDb.getRoomsByDepartmentID(2).then((value) {
                  setState(() {
                    loading = false;
                  });
                  Navigator.pop(context);
                });
              });
            },
            child: const Text(
              'add Baby Bedroom',
            ),
          ),*/
/*
          // ElevatedButton(
          //   onPressed: () {
          //     sqlDb.insertRoom('Parent Bedroom', 2).then((value) {
          //       sqlDb.getRoomsByDepartmentID(2).then((value) {
          //         // setState(() {
          //           // loading = false;
          //         // });
          //         Navigator.pop(context);
          //       });
          //     });
          //   },
          //   child: const Text(
          //     'add Parent Bedroom',
          //   ),
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //     sqlDb.insertRoom('Kitchen', 2).then((value) {
          //       sqlDb.getRoomsByDepartmentID(2);
          //     }).then((value) {
          //       // setState(() {
          //       //   loading = false;
          //       // });
          //       Navigator.pop(context);
          //     });
          //   },
          //   child: const Text(
          //     'add Kitchen',
          //   ),
          // ),
          */
/*ElevatedButton(
            onPressed: () {
              sqlDb.insertRoom('Bathroom', 2).then((value) {
                sqlDb.getRoomsByDepartmentID(2);
              }).then((value) {
                setState(() {
                  loading = false;
                });
                Navigator.pop(context);
              });
            },
            child: const Text(
              'add Bathroom',
            ),
          ),*/
/*ElevatedButton(
            onPressed: () {
              sqlDb.insertRoom('Dining Room', 2).then((value) {
                sqlDb.getRoomsByDepartmentID(2).then((value) {
                  setState(() {
                    loading = true;
                  });
                  Navigator.pop(context);
                });
              });
            },
            child: const Text(
              'add Dining Room',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              sqlDb.insertRoom('Garage', 2).then((value) {
                sqlDb.getRoomsByDepartmentID(context, 2).then((value) {
                  // setState(() {
                    Provider.of<AuthProvider>(context, listen: false).loadingToggling(false);
                    // loading = false;
                  // });
                  Navigator.pop(context);
                });
              });
            },
            child: const Text(
              'add Garage',
            ),
          ),*/
/*ElevatedButton(
            onPressed: () {
              setState(() {
                sqlDb.insertRoom('Desk', 2).then((value) {
                  sqlDb.getRoomsByDepartmentID(context, 2).then((value) {
                  // setState(() {
                  //   Provider.of<AuthProvider>(context, listen: false).loadingToggling(false);
                  // });
                  Navigator.pop(context);
                });
                });
              });
            },
            child: const Text(
              'add Desk',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              sqlDb.insertRoom('Laundry Room', 2).then((value) {
                sqlDb.getRoomsByDepartmentID(context, 2).then((value) {
                  // setState(() {
                  //   Provider.of<AuthProvider>(context, listen: false).loadingToggling(false);
                  // });
                  Navigator.pop(context);
                });
              });
            },
            child: const Text(
              'add Laundry Room',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              sqlDb.insertRoom('Outdoor', 2).then((value) {
                sqlDb.getRoomsByDepartmentID(context, 2).then((value) {
                  // setState(() {
                  //   Provider.of<AuthProvider>(context, listen: false).loadingToggling(false);
                  // });
                  Navigator.pop(context);
                });
              });
            },
            child: const Text(
              'add Outdoor',
            ),
          ),*/
/*
        ],
      ),
    );
  }
}

int departmentID = 0;
int roomID = 0;
bool deviceSuccess = false;
var tableList = [];
int count = 0;

class HelpDataBase extends StatefulWidget {
  const HelpDataBase({super.key});

  @override
  State<HelpDataBase> createState() => _HelpDataBaseState();
}

class _HelpDataBaseState extends State<HelpDataBase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          */
/*ElevatedButton(
            onPressed: () async {
              // Insert a department
              bool exist = await sqlDb.searchDepartmentByName("IT Department");
              if(exist){
                print('this department name is taken');
              }
              else{
                departmentID = await sqlDb.insertDepartment("IT Department");
              }
            },
            child: const Text(
              'insert into department',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Insert a room in the department
              if(departmentID != 0) {
                roomID = await sqlDb.insertRoom("Server Room", departmentID);
              }
            },
            child: const Text(
              'insert into rooms',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Insert a device in the room
              deviceSuccess = await sqlDb.insertDevice(
                "Router",
                "00:1A:2B:3C:4D:5E",
                "OfficeWifi",
                "password123",
                "Networking Device",
                roomID,
              );
            },
            child: const Text(
              'insert into devices',
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text('department Id : $departmentID'),
          ),
          Align(
            alignment: Alignment.center,
            child: Text('room Id : $roomID'),
          ),
          Align(
            alignment: Alignment.center,
            child: Text('device Id : $deviceSuccess'),
          ),
          ElevatedButton(
            onPressed: () async {
              tableList = await sqlDb.getDepartmentsAndRooms();
            },
            child: const Text('retrieve departments and rooms'),
          ),
          Align(
            alignment: Alignment.center,
            child: Text('$tableList'),
          ),
          ElevatedButton(onPressed: () async {await sqlDb.getAllDepartments();}, child: Text('print departments'),),
          ElevatedButton(onPressed: () async {var listlst = await sqlDb.getAllRooms();print(listlst);}, child: Text('print rooms'),),
          ElevatedButton(onPressed: () async {var listlst = await sqlDb.getAllDevices();print(listlst);}, child: Text('print devices'),),*/
/*ElevatedButton(
            onPressed: () async {
              int internalCount = await sqlDb.getDepartmentCount();
              setState(() {
                count = internalCount;
              });
            },
            child: const Text('retrieve departments count'),
          ),
          Align(
            alignment: Alignment.center,
            child: Text('$count'),
          ),
          ElevatedButton(
            onPressed: () async {
              var internalCount = await sqlDb.getAllDepartments();
              print('internal Count all departments $internalCount');
            },
            child: const Text('retrieve all departments'),
          ),
          ElevatedButton(
            onPressed: () async {
              var internalCount = await sqlDb.getAllRooms();
              print('internal Count all rooms $internalCount');
            },
            child: const Text('retrieve all rooms'),
          ),*/
/*
        ],
      ),
    );
  }
}*/

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
/*connect check

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
/*send
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
  }*/
/*mac address
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
                  }*/
/*
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

/**sign_in.dart*/
/*TextFormField(
                          controller: userController,
                          keyboardType: TextInputType.name,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: const TextStyle(),
                          validator: (value) {

                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.people, color: Colors.brown.shade700,),
                            labelText: 'username',
                            floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                                    (Set<MaterialState> states) {
                                  final Color color = states.contains(MaterialState.error)
                                      ? Theme.of(context).colorScheme.error
                                      : Colors.brown.shade700;
                                  return TextStyle(color: color, letterSpacing: 1.3,fontWeight: FontWeight.bold,fontSize: 18);
                                }),
                            labelStyle: MaterialStateTextStyle.resolveWith(
                                    (Set<MaterialState> states) {
                                  final Color color = states.contains(MaterialState.error)
                                      ? Theme.of(context).colorScheme.error
                                      : Colors.brown.shade700;
                                  return TextStyle(color: color, letterSpacing: 1.3);
                                }),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(width: 3, color: Colors.brown.shade800 ,),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(width: 1, color: Colors.brown ,),
                            ),
                          ),
                          onChanged: (value) async {

                          },
                        ),*/
