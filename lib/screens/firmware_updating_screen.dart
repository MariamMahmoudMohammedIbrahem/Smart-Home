import '../commons.dart';

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
        surfaceTintColor: MyColors.greenLight1,
        shadowColor: MyColors.greenLight2,
        backgroundColor: MyColors.greenDark1,
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
            child: Provider.of<AuthProvider>(context).firmwareInfo == null
                ? Provider.of<AuthProvider>(context).isConnected
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
                            color: MyColors.greenDark1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey.shade100,
                                  backgroundImage:
                                      const AssetImage('assets/images/appIcon.png'),
                                ),
                                width20,
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
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 10),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Icon(
                          getIconName(roomNames[index]),
                          color: MyColors.greenDark1,
                        ),
                        width10,
                        Text(roomNames[index]),
                      ],
                    ),
                    children: [
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: getDevices([roomIDs[index]]),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text("No devices found.");
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, innerIndex) {
                                final deviceMacAddress = snapshot.data![innerIndex]['MacAddress'];
                                final matchedDevice = macVersion.firstWhere(
                                      (device) => device['mac_address'] == deviceMacAddress,
                                  orElse: () => {},
                                );
                                final firmwareVersion = matchedDevice.isNotEmpty
                                    ? matchedDevice['firmware_version'] ?? 'disconnected'
                                    : 'Device not connected';

                                final deviceStatus = matchedDevice.isNotEmpty
                                    ? matchedDevice['status'] ?? ''
                                    : '';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                                  child: Consumer<AuthProvider>(
                                    builder: (context, firmwareUpdating, child) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            leading: const Icon(
                                              Icons.lightbulb_circle_outlined,
                                              color: MyColors.greenDark1,
                                            ),
                                            title: Text(
                                              snapshot.data![innerIndex]['deviceName'] ?? 'Switch',
                                            ),
                                            subtitle: Text(
                                              firmwareVersion,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: matchedDevice.isNotEmpty
                                                    ? Colors.grey
                                                    : Colors.red,
                                              ),
                                            ),
                                            trailing: matchedDevice.isNotEmpty
                                                ? (firmwareVersion ==
                                                Provider.of<AuthProvider>(context, listen: false)
                                                    .firmwareInfo
                                                ? const Text(
                                              'up to date',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: MyColors.greenDark1,
                                              ),
                                            )
                                                : deviceStatus.toString() == 'OK' ||
                                                deviceStatus.toString() == 'DOWNLOAD_NEW_FIRMWARE_START' ||
                                                deviceStatus.toString() == 'DOWNLOAD_NEW_FIRMWARE_FAIL' ||
                                                deviceStatus.toString() == 'DOWNLOAD_NEW_FIRMWARE_OK' ||
                                                double.tryParse(deviceStatus) != null
                                                ? _buildWidgetBasedOnState(matchedDevice)
                                                : (macVersion.isEmpty ||
                                                !macVersion.any((element) =>
                                                element['mac_address'] ==
                                                    snapshot.data![innerIndex]['MacAddress']))
                                                ? ElevatedButton(
                                              onPressed: () {
                                                sendFrame(
                                                  {
                                                    'commands': 'CHECK_FOR_NEW_FIRMWARE',
                                                    'mac_address': deviceMacAddress,
                                                  },
                                                  ip,
                                                  port,
                                                );
                                              },
                                              child: const Text('check'),
                                            )
                                                : ElevatedButton(
                                              onPressed: () {
                                                Fluttertoast.showToast(
                                                  msg: 'wait a second',
                                                  backgroundColor: MyColors.greenDark1,
                                                  textColor: Colors.white,
                                                );
                                                sendFrame(
                                                  {
                                                    "commands": 'DOWNLOAD_NEW_FIRMWARE',
                                                    "mac_address": deviceMacAddress,
                                                  },
                                                  ip,
                                                  port,
                                                );
                                                setState(() {
                                                  addOrUpdateDevice(macVersion,{'mac_address': deviceMacAddress, 'firmware_version': firmwareVersion, 'status': 'OK'}, context);
                                                  Future.delayed(const Duration(seconds: 5), () {
                                                    if(deviceStatus.toString() == 'OK') {
                                                      addOrUpdateDevice(
                                                          macVersion, {
                                                        'mac_address': deviceMacAddress,
                                                        'firmware_version': firmwareVersion,
                                                        'status': ''
                                                      }, context);
                                                    }
                                                  });
                                                });
                                              },
                                              child: const Text('Update'),
                                            ))
                                                : kEmptyWidget,
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

  Widget _buildWidgetBasedOnState(Map<String, dynamic> deviceStatus) {
    ///change firmware updating to the map
    int state = 0;
    if (deviceStatus['status'] == 'CHECK_FOR_NEW_FIRMWARE_SAME') {
      ///TODO: add case similarity
    } else if (deviceStatus['status'] == 'CHECK_FOR_NEW_FIRMWARE_OK') {
      ///TODO: add case complete check
    } else if (deviceStatus['status'] == 'CHECK_FOR_NEW_FIRMWARE_FAIL') {
      ///TODO: add case failed check
    } else if (deviceStatus['status'] == 'OK'){
      state = 2;
    } else if (deviceStatus['status'] == 'DOWNLOAD_NEW_FIRMWARE_START') {
      state = 3;
    } else if (deviceStatus['status'] == 'DOWNLOAD_NEW_FIRMWARE_FAIL') {
      state = 4;
    } /*else if ('${deviceStatus['status']}'.startsWith('updating')) {
      RegExp regExp =
          RegExp(r'_(\d+)');
      List<RegExpMatch> matches =
          regExp.allMatches(deviceStatus['status']).toList();
      deviceStatus['status'] = double.parse(matches[0].group(1)!);
      state = 5;
    }*/ else if (double.tryParse(deviceStatus['status']) != null) {
      state = 5;
    } else if (deviceStatus['status'] == 'DOWNLOAD_NEW_FIRMWARE_OK') {
      state = 6;
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
        return const Text('Waiting...', style: TextStyle(color: MyColors.greenDark1,),);

      case 3:
        return const CircularProgressIndicator();

      case 4:
        return CircleAvatar(
          radius: 50,
          backgroundColor: MyColors.greenDark1,
          child: ElevatedButton(
              onPressed: () {
                sendFrame({
                  "commands": 'DOWNLOAD_NEW_FIRMWARE',
                  "mac_address": deviceStatus['mac_address']
                }, ip, port);
                setState(() {
                  addOrUpdateDevice(macVersion,{'mac_address': deviceStatus['mac_address'], 'firmware_version': deviceStatus['firmware_version'], 'status': 'OK'}, context);
                  Future.delayed(const Duration(seconds: 5), () {
                    if(deviceStatus.toString() == 'OK') {
                      addOrUpdateDevice(
                          macVersion, {
                        'mac_address': deviceStatus['mac_address'],
                        'firmware_version': deviceStatus['firmware_version'],
                        'status': ''
                      }, context);
                    }
                  });
                });
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

      case 5:
        double downloadProgress = double.parse(deviceStatus['status']) / 100;
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: downloadProgress,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  MyColors.greenDark1,
                ),
              ),
            ),
            Text(
              '${(downloadProgress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: MyColors.greenDark1,
              ),
            ),
          ],
        );

      case 6:
        return const CircleAvatar(
          radius: 50,
          backgroundColor: MyColors.greenDark1,
          child: Icon(
            Icons.done,
            color: Colors.white,
            size: 50,
          ),
        );

      default:
        return kEmptyWidget;
    }
  }
}
