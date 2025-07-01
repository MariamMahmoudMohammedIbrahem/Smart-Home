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
    return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: buildCupertinoNavBar("Firmware Updating", context),
      child: scaffoldBody(height, width),
    )
        : Scaffold(
      appBar: buildMaterialAppBar("Firmware Updating"),
      body: scaffoldBody(height, width),
    );
  }

  Widget scaffoldBody(double height, double width) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firmwareInfo = authProvider.firmwareInfo;
    final isConnected = authProvider.isConnected;

    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          height: height * .88,
          child: Center(
            child:
            firmwareInfo == null
                ? isConnected
                ? _buildCheckingUpdates() // Show loading if connected but waiting
                : _buildNoConnection() // Show no internet message
                : _buildFirmwareContent(
              height,
              width,
            ), // Show content if firmware info is available
          ),
        ),
      ),
    );
  }

  /// Widget shown while checking for firmware updates
  Widget _buildCheckingUpdates() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Platform.isIOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(),
        height16,
        const Text('Checking for Updates'),
      ],
    );
  }

  /// Widget shown when there is no internet connection
  Widget _buildNoConnection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Platform.isIOS
              ? CupertinoIcons.wifi_slash
              : Icons.signal_wifi_connected_no_internet_4_rounded,
          size: 50,
          color: Colors.grey.shade600,
        ),
        height16,
        Text(
          'No Internet Connection.',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Main UI displayed once firmware info is available
  Widget _buildFirmwareContent(double height, double width) {
    return Column(
      children: [
        _buildFirmwareCard(width),
        Expanded(
          child: ListView.builder(
            itemCount: rooms.length,
            itemBuilder:
                (context, index) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.07,
                vertical: 10,
              ),
              child:
              Platform.isIOS
                  ? Material(child: _buildRoomTile(index, width))
                  : _buildRoomTile(index, width),
            ),
          ),
        ),
      ],
    );
  }

  /// Card showing current firmware info
  Widget _buildFirmwareCard(double width) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * .07, vertical: 20),
      padding: EdgeInsets.all(width * .03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: MyColors.greenDark1,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: const AssetImage('assets/images/appIcon.png'),
          ),
          width20,
          Text(
            'Version ${authProvider.firmwareInfo}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Expansion tile for each room with its devices
  Widget _buildRoomTile(int index, double width) {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(rooms[index].icon, color: MyColors.greenDark1),
          width10,
          Text(rooms[index].name),
        ],
      ),
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: getDevices([rooms[index].id!]),
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
                itemBuilder:
                    (context, innerIndex) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      child: Platform.isIOS?Material(child: _buildDeviceTile(snapshot.data![innerIndex])):_buildDeviceTile(snapshot.data![innerIndex]),
                    ),
              );
            }
          },
        ),
      ],
    );
  }

  /// Widget showing device info and firmware actions
  Widget _buildDeviceTile(Map<String, dynamic> deviceData) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final macAddress = deviceData['MacAddress'];
    final matchedDevice = macVersion.firstWhere(
          (device) => device['mac_address'] == macAddress,
      orElse: () => {},
    );
    final firmwareVersion = matchedDevice['firmware_version'] ?? 'disconnected';
    final deviceStatus = matchedDevice['status'] ?? '';
    final deviceName = deviceData['deviceName'] ?? 'Switch';

    // Determine which widget to show based on firmware status
    Widget trailingWidget;

    checkForNewFirmware() {
      sendFrame(
        {'commands': 'CHECK_FOR_NEW_FIRMWARE', 'mac_address': macAddress},
        ip,
        port,
      );
    }

    downloadNewFirmware() {
      Fluttertoast.showToast(
        msg: 'wait a second',
        backgroundColor: MyColors.greenDark1,
        textColor: Colors.white,
      );
      sendFrame(
        {'commands': 'DOWNLOAD_NEW_FIRMWARE', 'mac_address': macAddress},
        ip,
        port,
      );

      // Optimistic UI update
      setState(() {
        addOrUpdateDevice({
          'mac_address': macAddress,
          'firmware_version': firmwareVersion,
          'status': 'OK',
        }, context);

        // Delay status reset if needed
        Future.delayed(const Duration(seconds: 5), () {
          if (deviceStatus.toString() == 'OK') {
            addOrUpdateDevice({
              'mac_address': macAddress,
              'firmware_version': firmwareVersion,
              'status': '',
            }, context);
          }
        });
      });
    }

    final isUpToDate =
        matchedDevice.isNotEmpty &&
            firmwareVersion == authProvider.firmwareInfo;

    if (matchedDevice.isNotEmpty) {
      if (isUpToDate) {
        trailingWidget = const Text(
          'up to date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: MyColors.greenDark1,
          ),
        );
      } else if (_isStatusOngoing(deviceStatus)) {
        trailingWidget = _buildWidgetBasedOnState(matchedDevice);
      } else if (!_isMacKnown(macAddress)) {
        trailingWidget =
        Platform.isIOS
            ? CupertinoButton(
          onPressed: checkForNewFirmware,
          child: const Text('check'),
        )
            : ElevatedButton(
          onPressed: checkForNewFirmware,
          child: const Text('check'),
        );
      } else {
        trailingWidget =
        Platform.isIOS
            ? CupertinoButton(
          onPressed: downloadNewFirmware,
          child: const Text('Update'),
        )
            : ElevatedButton(
          onPressed: downloadNewFirmware,
          child: const Text('Update'),
        );
      }
    } else {
      trailingWidget = kEmptyWidget;
    }

    return ListTile(
      leading: const Icon(
        Icons.lightbulb_circle_outlined,
        color: MyColors.greenDark1,
      ),
      title: Text(deviceName),
      subtitle: Text(
        firmwareVersion,
        style: TextStyle(
          fontSize: 14,
          color: matchedDevice.isNotEmpty ? Colors.grey : Colors.red,
        ),
      ),
      trailing: trailingWidget,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.green.shade100),
      ),
    );
  }

  /// Helper: Checks if firmware status is in progress
  bool _isStatusOngoing(dynamic status) {
    return status == 'OK' ||
        status == 'DOWNLOAD_NEW_FIRMWARE_START' ||
        status == 'DOWNLOAD_NEW_FIRMWARE_FAIL' ||
        status == 'DOWNLOAD_NEW_FIRMWARE_OK' ||
        double.tryParse(status.toString()) != null;
  }

  /// Helper: Check if device mac exists in known list
  bool _isMacKnown(String macAddress) {
    return macVersion.any((e) => e['mac_address'] == macAddress);
  }

  Widget _buildWidgetBasedOnState(Map<String, dynamic> deviceStatus) {
    downloadNewFirmware() {
      sendFrame(
        {
          "commands": 'DOWNLOAD_NEW_FIRMWARE',
          "mac_address": deviceStatus['mac_address'],
        },
        ip,
        port,
      );
      setState(() {
        addOrUpdateDevice({
          'mac_address': deviceStatus['mac_address'],
          'firmware_version': deviceStatus['firmware_version'],
          'status': 'OK',
        }, context);
        Future.delayed(const Duration(seconds: 5), () {
          if (deviceStatus.toString() == 'OK') {
            addOrUpdateDevice({
              'mac_address': deviceStatus['mac_address'],
              'firmware_version': deviceStatus['firmware_version'],
              'status': '',
            }, context);
          }
        });
      });
    }
    Widget downloadNewFirmwareChild = const Row(
        children: [
          Icon(
            Icons.running_with_errors_rounded,
            color: Colors.white,
            size: 10,
          ),
          Text('retry'),
        ]
    );

    ///change firmware updating to the map
    int state = 0;
    if (deviceStatus['status'] == 'CHECK_FOR_NEW_FIRMWARE_SAME') {
      ///TODO: add case similarity
    } else if (deviceStatus['status'] == 'CHECK_FOR_NEW_FIRMWARE_OK') {
      ///TODO: add case complete check
    } else if (deviceStatus['status'] == 'CHECK_FOR_NEW_FIRMWARE_FAIL') {
      ///TODO: add case failed check
    } else if (deviceStatus['status'] == 'OK') {
      state = 2;
    } else if (deviceStatus['status'] == 'DOWNLOAD_NEW_FIRMWARE_START') {
      state = 3;
    } else if (deviceStatus['status'] == 'DOWNLOAD_NEW_FIRMWARE_FAIL') {
      state = 4;
    } else if (double.tryParse(deviceStatus['status']) != null) {
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
        return const Text(
          'Waiting...',
          style: TextStyle(color: MyColors.greenDark1),
        );

      case 3:
        return Platform.isIOS
            ? CupertinoActivityIndicator()
            : CircularProgressIndicator();

      case 4:
        return CircleAvatar(
          radius: 50,
          backgroundColor: MyColors.greenDark1,
          child:
          Platform.isIOS
              ? CupertinoButton(
            onPressed: downloadNewFirmware,
            child: downloadNewFirmwareChild,
          )
              : ElevatedButton(
            onPressed: downloadNewFirmware,
            child: downloadNewFirmwareChild,
          ),
        );

      case 5:
        double downloadProgress = double.parse(deviceStatus['status']) / 100;
        return DownloadProgressIndicator(
          circleDiameter: 50.0,
          progress: downloadProgress,
        );

      case 6:
        return DownloadCompleteIndicator();

      default:
        return kEmptyWidget;
    }
  }
}

/* return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          color: MyColors.greenDark1, // Set the back arrow color
          onPressed: () {
            Navigator.pop(context); // Pop to go back to the previous screen
          },
        ),
            middle: const Text(
              'Firmware Updating',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
      ),
      ),
        child: SafeArea(
          child: SingleChildScrollView(
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
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 10),
                            child: Material(
                              child: ExpansionTile(
                                title: Row(
                                  children: [
                                    Icon(
                                      rooms[index].icon,
                                      color: MyColors.greenDark1,
                                    ),
                                    width10,
                                    Text(rooms[index].name),
                                  ],
                                ),
                                children: [
                                  FutureBuilder<List<Map<String, dynamic>>>(
                                    future: getDevices([rooms[index].id!]),
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
                                                      Material(
                                                        child: ListTile(
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
                                                                addOrUpdateDevice({'mac_address': deviceMacAddress, 'firmware_version': firmwareVersion, 'status': 'OK'}, context);
                                                                Future.delayed(const Duration(seconds: 5), () {
                                                                  if(deviceStatus.toString() == 'OK') {
                                                                    addOrUpdateDevice({
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
    )
        : Scaffold(
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
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 10),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Icon(
                          rooms[index].icon,
                          color: MyColors.greenDark1,
                        ),
                        width10,
                        Text(rooms[index].name),
                      ],
                    ),
                    children: [
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: getDevices([rooms[index].id!]),
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
                                                  addOrUpdateDevice({'mac_address': deviceMacAddress, 'firmware_version': firmwareVersion, 'status': 'OK'}, context);
                                                  Future.delayed(const Duration(seconds: 5), () {
                                                    if(deviceStatus.toString() == 'OK') {
                                                      addOrUpdateDevice({
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
    );*/
