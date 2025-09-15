import '../commons.dart';

class RoomDetailsScreen extends StatefulWidget {
  final Room roomDetail;

  const RoomDetailsScreen({
    super.key,
    required this.roomDetail,
  });

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  List ledInfo = ['light lamp', 'light lamp', 'RGB led', 'connection led'];
  Timer? debounce;
  Timer? debounceConfirm;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          color: MyColors.greenDark1, // Set the back arrow color
          onPressed: () {
            Navigator.pop(context); // Pop to go back to the previous screen
          },
        ),
        middle: navBarChild(),
      ),
      child: SafeArea(
        child: scaffoldBody(width, isDarkMode),
      ),
    )
        : Scaffold(
      appBar: AppBar(
        surfaceTintColor: MyColors.greenLight1,
        shadowColor: MyColors.greenLight2,
        backgroundColor: MyColors.greenDark1,
        foregroundColor: Colors.white,
        shape: appBarShape,
        title: navBarChild(),
        centerTitle: true,
        titleTextStyle: materialNavTitleTextStyle,
      ),
      body: scaffoldBody(width, isDarkMode),
    );
  }

  Widget navBarChild () {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.roomDetail.name,
          style: Platform.isIOS?cupertinoNavTitleStyle:null,
        ),
        width5,
        Icon(
          widget.roomDetail.icon,
        ),
      ],
    );
  }

  switchOnChanged (int adjustedIndex, DeviceStatus? device, int newValue) {
    final key = adjustedIndex == 3
        ? 'led'
        : 'sw$adjustedIndex';

    sendFrame(
      {
        'commands': 'SWITCH_WRITE',
        'mac_address': macAddress,
        key: newValue,
      },
      ip,
      port,
    );
  }

  Widget scaffoldBody(double width, bool isDarkMode) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .07, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (deviceDetails.length > 1) _buildDeviceButtons(authProvider, isDarkMode),
            height10,
            _buildGridSwitches(isDarkMode),
            _buildColorPickerIfNeeded(),
          ],
        ),
      ),
    );
  }

  /// Helper: Check if device mac exists in known list
  bool _isDeviceConnected(BuildContext context, String macAddress) {
    final devices = context.read<AuthProvider>().devices;
    final device = devices.firstWhere(
          (d) => d['mac_address'] == macAddress,
      orElse: () => {},
    );
    return device.isNotEmpty ? (device['isConnected'] ?? false) : false;
  }


  Widget _buildDeviceButtons(AuthProvider authProvider, bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(deviceDetails.length, (index) {
          final device = deviceDetails[index];
          final macAddressDevice = device['MacAddress'];
          final connectionStatus = _isDeviceConnected(context, macAddressDevice);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7.5),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  macAddress = macAddressDevice;
                });
              },
              onLongPress: () => _showDeleteModal(macAddressDevice),
              style: ElevatedButton.styleFrom(
                side: BorderSide(
                  color: macAddress == macAddressDevice
                      ? connectionStatus
                        ? MyColors.greenDark1
                        : Colors.red
                      : Colors.grey,
                  width: isDarkMode?1.5:1.0
                ),
                backgroundColor: connectionStatus?macAddress == macAddressDevice
                    ? MyColors.greyLight
                    : Colors.white
                :Colors.grey[200],
              ),
              child: Row(
                mainAxisAlignment: connectionStatus?MainAxisAlignment.center:MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${device['DeviceType'] ?? "Switch"} ${index + 1}',
                    style: TextStyle(color: connectionStatus?MyColors.greenDark1:Colors.grey[800]),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showDeleteModal(String macAddressDevice) {
    Platform.isIOS
        ? showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text("Delete Switch?", style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.greenDark1, fontSize: 20,),),
        message: Text("This action cannot be undone. Are you sure you want to delete this item", style: TextStyle(fontStyle: FontStyle.italic,color: CupertinoColors.systemGrey),),
        actions: [
          CupertinoActionSheetAction(
            onPressed: (){deleteSwitch(macAddressDevice);},
            child: Text('Delete'),
          ),
        ],
        cancelButton: CupertinoButton(child: const Text("Cancel"), onPressed: (){Navigator.pop(context);}),
      ),
    )
        : showModalBottomSheet(
      context: context,
      builder: (context) {
        final isDark = Provider.of<AuthProvider>(context).isDarkMode;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListTile(
            leading: const Icon(Icons.delete, color: MyColors.greenDark1),
            title: const Text('Delete', style: TextStyle(color: MyColors.greenDark1)),
            onTap: (){deleteSwitch(macAddressDevice);},
          ),
        );
      },
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void deleteSwitch (macAddressDevice) {
    deleteDeviceByMacAddress(macAddressDevice).then((_) {
      if(!mounted) return;
      Provider.of<AuthProvider>(context, listen: false).toggling('delete', true);
      getDeviceDetailsByRoomID(widget.roomDetail.id!).then((_) {
        exportData();
        if(!mounted) return;
        Provider.of<AuthProvider>(context, listen: false).toggling('delete', false);
        Navigator.pop(context);
      });
    });
  }
  Widget _buildGridSwitches(bool isDarkMode) {
    final isSingleDevice = deviceDetails.length == 1;


    return Column(
      children: [
        if (isSingleDevice)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Builder(
              builder: (context) {
                final connectionStatus =
                _isDeviceConnected(context, macAddress);
                return Text(
                  connectionStatus ? "Connected" : "Disconnected",
                  style: TextStyle(
                    color: connectionStatus ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                );
              },
            ),
          ),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15.0,
            crossAxisSpacing: 15.0,
          ),
          itemBuilder: (context, index) {
            final adjustedIndex = (index == 1) ? 2 : (index == 2) ? 1 : index;
            final device = findDeviceByMac(deviceStatus, macAddress);
            final isActive = device?.getSwitchValue(adjustedIndex) == 1;
            final borderColor = _resolveColor(isActive, isDarkMode, MyColors.greenDark1);
            final backgroundColor = isDarkMode
                ? Colors.transparent
                : isActive
                ? MyColors.greyLight
                : Colors.grey.shade200;

            return GestureDetector(
              child: Consumer<AuthProvider>(
                builder: (context, switchesProvider, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              _getIconForIndex(adjustedIndex),
                              color: borderColor,
                              size: 40,
                            ),
                            _platformSwitch(isActive, (newValue) {
                              switchOnChanged(adjustedIndex, device, newValue ? 1 : 0);
                            }),
                          ],
                        ),
                        Text(
                          ledInfo[index],
                          style: TextStyle(
                            color: borderColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 1:
        return Icons.color_lens_outlined;
      case 3:
        return Icons.light_mode_outlined;
      default:
        return Icons.lightbulb_circle_outlined;
    }
  }

  Widget _platformSwitch(bool value, void Function(bool) onChanged) {
    return Platform.isIOS
        ? CupertinoSwitch(value: value, onChanged: onChanged)
        : Switch(value: value, onChanged: onChanged);
  }
  Widget _buildColorPickerIfNeeded() {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        final device = findDeviceByMac(deviceStatus, macAddress);
        final isSw2On = device?.sw2 == 1;

        if (!isSw2On) return kEmptyWidget;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: ColorPicker(
            pickerColor: device!.currentColor,
            onColorChanged: _onColorChanged,
            paletteType: PaletteType.hueWheel,
            enableAlpha: false,
            labelTypes: const [],
            colorPickerWidth: 250,
          ),
        );
      },
    );
  }

  void _onColorChanged(Color color) {
    debounceConfirm?.cancel();
    debounce?.cancel();
    final device = findDeviceByMac(deviceStatus, macAddress);
    setState(() => tempColor = color);
    setState(() => device!.currentColor = color);

    debounce = Timer(const Duration(milliseconds: 100), () {
      setState(() => currentColor = tempColor);

      sendFrame(
        {
          "commands": "RGB_WRITE",
          "mac_address": macAddress,
          "red": (currentColor.r * 255.0).round() & 0xff,
          "green": (currentColor.g * 255.0).round() & 0xff,
          "blue": (currentColor.b * 255.0).round() & 0xff,
        },
        ip,
        port,
      );
    });
  }

  Color _resolveColor(bool isActive, bool isDarkMode, Color activeColor) {
    return isActive
        ? activeColor
        : isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade800;
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }
}