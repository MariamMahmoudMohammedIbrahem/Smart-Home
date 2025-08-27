import '../commons.dart';

enum FirmwareUpdateState {
  none,
  noUpdate,
  waiting,
  downloading,
  downloadFailed,
  downloadInProgress,
  downloadComplete,
  readyToUpdate,
}

class FirmwareScreen extends StatefulWidget {
  const FirmwareScreen({super.key});

  @override
  State<FirmwareScreen> createState() => _FirmwareScreenState();
}

class _FirmwareScreenState extends State<FirmwareScreen> {
  /// TODO: it is general, needs to be handled for each device
  Map<String, DateTime> deviceTimers = {};
  Map<String, double> latestProgressMap = {};
  final Map<String, FirmwareUpdateState> _deviceStates = {};
  double? downloadProgress;
  // double? lastDownloadProgress;

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
    final isConnected = authProvider.wifiConnected;

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
                      child: Platform.isIOS
                          ? Material(child: _buildDeviceTile(snapshot.data![innerIndex]))
                          : _buildDeviceTile(snapshot.data![innerIndex]),
                    ),
              );
            }
          },
        ),
      ],
    );
  }

  /// Helper: check if the device is currently connected or not
  bool _isDeviceConnected(BuildContext context, String macAddress) {
    final devices = context.read<AuthProvider>().devices;
    final device = devices.firstWhere(
          (d) => d['mac_address'] == macAddress,
      orElse: () => {},
    );
    return device.isNotEmpty ? (device['isConnected'] ?? false) : false;
  }

  /// Widget showing device info and firmware actions
  Widget _buildDeviceTile(Map<String, dynamic> deviceData) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final macAddress = deviceData['MacAddress'];
    var matchedDevice = macVersion.firstWhere(
          (device) => device['mac_address'] == macAddress,
      orElse: () => {},
    );
    var firmwareVersion = _isDeviceConnected(context, macAddress)?matchedDevice['firmware_version']:"disconnected";
    if(firmwareVersion == 'disconnected') matchedDevice['command'] = "CONNECTION_LOST";
    var deviceCommand = matchedDevice['command'] ?? '';
    var deviceName = deviceData['deviceName'] ?? 'Switch';

    // Determine which widget to show based on firmware status
    Widget trailingWidget;

    checkForNewFirmware() {
      sendFrame(
        {'commands': 'CHECK_FOR_NEW_FIRMWARE', 'mac_address': macAddress},
        ip,
        port,
      );
    }

    final isUpToDate = firmwareVersion == authProvider.firmwareInfo;

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
      } else if (_isStatusOngoing(deviceCommand) ) {
        trailingWidget = _buildWidgetBasedOnState(matchedDevice);
      } else if (deviceCommand == '') {
        trailingWidget =
          Platform.isIOS
              ? CupertinoButton(
            onPressed: (){_downloadNewFirmware(macAddress,firmwareVersion);},
            child: const Text('Update'),
          )
              : ElevatedButton(
            onPressed: (){_downloadNewFirmware(macAddress,firmwareVersion);},
            child: const Text('Update'),
          );
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
          onPressed: (){_downloadNewFirmware(macAddress,firmwareVersion);},
          child: const Text('Update'),
        )
            : ElevatedButton(
          onPressed: (){_downloadNewFirmware(macAddress,firmwareVersion);},
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
          color: matchedDevice.isNotEmpty && firmwareVersion!="disconnected" ? Colors.grey : Colors.red,
        ),
      ),
      trailing: firmwareVersion == 'disconnected'?kEmptyWidget:trailingWidget,
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

  /// Helper: download new firmware version
  _downloadNewFirmware(String deviceMacAddress, String deviceFirmwareVersion) {
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
      addOrUpdateDevice({
        'mac_address': deviceMacAddress,
        'firmware_version': deviceFirmwareVersion,
        'command': 'OK',
        'time': DateTime.now(),
        'isConnected': true,
      }, context);
  }

  /// Builds a UI widget based on the device's firmware update state.
  ///
  /// Steps:
  /// 1. Maps the `deviceStatus['command']` to a [FirmwareUpdateState].
  /// 2. Calls [_handleTimeoutWhileUpdating] to detect stalled updates.
  /// 3. Returns the appropriate widget for the state:
  ///    - No updates available
  ///    - Waiting
  ///    - Downloading (progress/spinner)
  ///    - Download failed (retry button)
  ///    - Download complete
  ///    - Ready to update (update button)
  ///    - Empty fallback if no valid state
  Widget _buildWidgetBasedOnState(Map<String, dynamic> deviceStatus) {
    final previousState = _deviceStates[deviceStatus['mac_address']] ?? FirmwareUpdateState.none;
    FirmwareUpdateState state = _mapCommandToState(deviceStatus, previousState);
    _deviceStates[macAddress] = state;

    _handleTimeoutWhileUpdating(state, deviceStatus);

    return _buildWidgetForState(state, deviceStatus);
  }

  /// Maps device command to state
  FirmwareUpdateState _mapCommandToState(Map<String, dynamic> deviceStatus, FirmwareUpdateState previousState) {
    final String command = deviceStatus['command'] ?? '';

    switch (command) {
      case 'CHECK_FOR_NEW_FIRMWARE_SAME':
      // TODO: add case similarity
        return FirmwareUpdateState.noUpdate;

      case 'CHECK_FOR_NEW_FIRMWARE_OK':
      // TODO: add case complete check
        return FirmwareUpdateState.waiting;

      case 'CHECK_FOR_NEW_FIRMWARE_FAIL':
      // TODO: add case failed check
        return FirmwareUpdateState.downloadFailed;

      case 'OK':
        return FirmwareUpdateState.waiting;

      case 'DOWNLOAD_NEW_FIRMWARE_START':
        return FirmwareUpdateState.downloading;

      case 'DOWNLOAD_NEW_FIRMWARE_FAIL':
        return FirmwareUpdateState.downloadFailed;

      case 'DOWNLOAD_NEW_FIRMWARE_OK':
        return FirmwareUpdateState.downloadComplete;

      case '':
        return FirmwareUpdateState.readyToUpdate;

      case 'CONNECTION_LOST':
        return FirmwareUpdateState.none;

      default:
        if (previousState == FirmwareUpdateState.downloadComplete) {
          return previousState;
        }
        return FirmwareUpdateState.downloadInProgress;
    }
  }

  /// Builds widget based on state
  Widget _buildWidgetForState(
      FirmwareUpdateState state,
      Map<String, dynamic> deviceStatus,
      ) {
    switch (state) {
      case FirmwareUpdateState.noUpdate:
        return _buildNoUpdateWidget();

      case FirmwareUpdateState.waiting:
        return _buildWaitingWidget();

      case FirmwareUpdateState.downloading:
        return _buildLoadingWidget();

      case FirmwareUpdateState.downloadFailed:
        return _buildDownloadFailedWidget(deviceStatus);

      case FirmwareUpdateState.downloadInProgress:
        final double newProgress = double.parse(deviceStatus['command']) / 100;
        final double? previousProgress = latestProgressMap[deviceStatus['mac_address']];

        if (previousProgress == null || newProgress > previousProgress) {
          latestProgressMap[deviceStatus['mac_address']] = newProgress;
          return _buildDownloadProgressWidget(newProgress);
        } else {
          return _buildDownloadProgressWidget(previousProgress ?? 0.0);
        }
      case FirmwareUpdateState.downloadComplete:
        return const DownloadCompleteIndicator();

      case FirmwareUpdateState.readyToUpdate:
        return _buildUpdateButton(deviceStatus);

      case FirmwareUpdateState.none:
        return kEmptyWidget;
    }
  }

  /// Helpers for UI widgets
  Widget _buildNoUpdateWidget() => const Column(
    children: [
      Icon(Icons.file_download_off_rounded),
      Text('There are no updates'),
    ],
  );

  Widget _buildWaitingWidget() => const Text(
    'Waiting...',
    style: TextStyle(color: MyColors.greenDark1),
  );

  Widget _buildLoadingWidget() =>
      Platform.isIOS ? const CupertinoActivityIndicator() : const CircularProgressIndicator();

  Widget _buildDownloadFailedWidget(Map<String, dynamic> deviceStatus) {
    final retryButton = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.running_with_errors_rounded, color: Colors.white, size: 10),
        Text('retry', style: TextStyle(color: Colors.white)),
      ],
    );

    return CircleAvatar(
      radius: 50,
      backgroundColor: MyColors.greenDark1,
      child: Platform.isIOS
          ? CupertinoButton(
        onPressed: () => _downloadNewFirmware(
          deviceStatus['mac_address'],
          deviceStatus['firmware_version'],
        ),
        child: retryButton,
      )
          : ElevatedButton(
        onPressed: () => _downloadNewFirmware(
          deviceStatus['mac_address'],
          deviceStatus['firmware_version'],
        ),
        child: retryButton,
      ),
    );
  }

  Widget _buildDownloadProgressWidget(double parsedValue) => DownloadProgressIndicator(
    circleDiameter: 50.0,
    progress: parsedValue,
    progressFontSize: 14.0,
  );

  Widget _buildUpdateButton(Map<String, dynamic> deviceStatus) =>
      Platform.isIOS
          ? CupertinoButton(
        onPressed: () => _downloadNewFirmware(
          deviceStatus['mac_address'],
          deviceStatus['firmware_version'],
        ),
        child: const Text('Update'),
      )
          : ElevatedButton(
        onPressed: () => _downloadNewFirmware(
          deviceStatus['mac_address'],
          deviceStatus['firmware_version'],
        ),
        child: const Text('Update'),
      );

  /// Monitors firmware update states that may hang (waiting, downloading, in-progress).
  ///
  /// If the device does not update its status for 30 seconds while connected,
  /// it marks the device as `CONNECTION_LOST`, resets the timer,
  /// and shows a toast to notify the user.
  ///
  /// Relevant states checked:
  /// - [FirmwareUpdateState.waiting]
  /// - [FirmwareUpdateState.downloading]
  /// - [FirmwareUpdateState.downloadInProgress]
  ///
  /// The timeout is reset if:
  /// - The state changes, OR
  /// - The download progress increases.
  void _handleTimeoutWhileUpdating(
      FirmwareUpdateState state,
      Map<String, dynamic> deviceStatus,
      ) {
    final mac = deviceStatus['mac_address'];
    if (mac == null) return;

    if ([FirmwareUpdateState.waiting, FirmwareUpdateState.downloading, FirmwareUpdateState.downloadInProgress]
        .contains(state) &&
        deviceStatus['isConnected']) {

      bool shouldResetTimer = false;

      if (state == FirmwareUpdateState.downloadInProgress) {
        final double currentProgress = double.tryParse(deviceStatus['command'] ?? '')!/100;
        final double? previousProgress = latestProgressMap[mac];

        if ((previousProgress == null || currentProgress > previousProgress)) {
          shouldResetTimer = true;
          latestProgressMap[mac] = currentProgress;
        }
      }

      if (!deviceTimers.containsKey(mac) || shouldResetTimer) {
        deviceTimers[mac] = DateTime.now();
      } else {
        final elapsed = DateTime.now().difference(deviceTimers[mac]!);
        if (elapsed.inSeconds >= 30) {
          addOrUpdateDevice({
            'mac_address': mac,
            'firmware_version': deviceStatus['firmware_version'],
            'command': 'CONNECTION_LOST',
            'time': deviceStatus['time'],
            'isConnected': deviceStatus['isConnected'],
          }, context);

          Fluttertoast.showToast(
            msg: 'No response from device. Please try again.',
            backgroundColor: MyColors.greenDark1,
            textColor: Colors.white,
          );

          deviceTimers.remove(mac);
        }
      }
    } else {
      deviceTimers.remove(mac);
    }
  }
}