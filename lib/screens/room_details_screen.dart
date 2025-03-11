
import '../commons.dart';

class RoomDetailsScreen extends StatefulWidget {
  final String roomName;
  final int roomID;

  const RoomDetailsScreen({
    super.key,
    required this.roomName,
    required this.roomID,
  });

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
        title: Row(
          children: [
            Text(
              widget.roomName,
            ),
            width5,
            Icon(
              getIconName(
                widget.roomName,
              ),
            ),
          ],
        ),
        centerTitle: true,
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
                              setState(() {
                                macAddress = macAddressDevice;
                              });
                            },
                            onLongPress: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Provider.of<AuthProvider>(context).isDarkMode
                                          ? Colors.grey[900]
                                          : Colors.white,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: const Icon(
                                            Icons.delete,
                                            color: MyColors.greenDark1,
                                          ),
                                          title: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: MyColors.greenDark1,
                                            ),
                                          ),
                                          onTap: () {
                                            deleteDeviceByMacAddress(
                                              macAddressDevice,
                                            )
                                                .then((value) => {
                                              Provider.of<AuthProvider>(
                                                  context,
                                                  listen: false)
                                                  .toggling(
                                                'delete',
                                                true,
                                              ),
                                              getDeviceDetailsByRoomID(
                                                  widget.roomID)
                                                  .then((value) => {
                                                    exportData(),
                                                Provider.of<AuthProvider>(
                                                    context,
                                                    listen:
                                                    false)
                                                    .toggling(
                                                  'delete',
                                                  false,
                                                ),
                                                Navigator.pop(
                                                    context),
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
                            },
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(
                                color: macAddress == macAddressDevice
                                    ? MyColors.greenDark1
                                    : Colors.grey,
                              ),
                              backgroundColor: macAddress == macAddressDevice
                                  ? MyColors.greyLight
                                  : Colors.white,
                            ),
                            child: Text(
                              device['DeviceType'] ?? "Switch",
                              style: const TextStyle(
                                color: MyColors.greenDark1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                height10,
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15.0,
                    crossAxisSpacing: 15.0,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    int adjustedIndex = index;

                    if (index == 1) {
                      adjustedIndex = 2;
                    } else if (index == 2) {
                      adjustedIndex = 1;
                    }
                    return GestureDetector(
                      child: Consumer<AuthProvider>(
                          builder: (context, switchesProvider, child) {
                            return Container(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.transparent
                                    : adjustedIndex == 3
                                    ? deviceStatus.firstWhere(
                                      (device) =>
                                  device['MacAddress'] ==
                                      macAddress,
                                )['led'] ==
                                    1
                                    ? const Color(0xffcbe3c5)
                                    : Colors.grey.shade200
                                    : deviceStatus.firstWhere(
                                      (device) =>
                                  device['MacAddress'] ==
                                      macAddress,
                                )['sw${adjustedIndex + 1}'] ==
                                    1
                                    ? const Color(0xffcbe3c5)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: deviceStatus.firstWhere(
                                        (device) =>
                                    device['MacAddress'] == macAddress,
                                  )['sw${adjustedIndex + 1}'] ==
                                      1 || (adjustedIndex == 3 && deviceStatus.firstWhere((device) => device['MacAddress'] == macAddress,)['led'] == 1)
                                      ? const Color(0xFF047424)
                                      : isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade800,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        adjustedIndex == 3
                                            ? Icons.light_mode_outlined
                                            : adjustedIndex == 1
                                            ? Icons.color_lens_outlined
                                            : Icons.lightbulb_circle_outlined,
                                        color: deviceStatus.firstWhere(
                                              (device) =>
                                          device['MacAddress'] ==
                                              macAddress,
                                        )['sw${adjustedIndex + 1}'] ==
                                            1 || (adjustedIndex == 3 && deviceStatus.firstWhere((device) => device['MacAddress'] == macAddress,)['led'] == 1)
                                            ? const Color(0xFF047424)
                                            : isDarkMode
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade800,
                                        size: 40,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Switch(
                                            value: adjustedIndex == 3
                                                ? deviceStatus.firstWhere(
                                                  (device) =>
                                              device[
                                              'MacAddress'] ==
                                                  macAddress,
                                            )['led'] ==
                                                1
                                                ? true
                                                : false
                                                : deviceStatus.firstWhere(
                                                  (device) =>
                                              device[
                                              'MacAddress'] ==
                                                  macAddress,
                                            )['sw${adjustedIndex + 1}'] ==
                                                1
                                                ? true
                                                : false,
                                            onChanged: (value) {
                                              if (index == 0) {
                                                sendFrame(
                                                  {
                                                    "commands": 'SWITCH_WRITE',
                                                    "mac_address": macAddress,
                                                    "sw0": deviceStatus.firstWhere(
                                                          (device) =>
                                                      device[
                                                      'MacAddress'] ==
                                                          macAddress,
                                                    )['sw1'] ==
                                                        0
                                                        ? 1
                                                        : 0,
                                                  },
                                                  ip,
                                                  port,
                                                );
                                              } else if (index == 2) {
                                                sendFrame(
                                                  {
                                                    "commands": 'SWITCH_WRITE',
                                                    "mac_address": macAddress,
                                                    "sw1": deviceStatus.firstWhere(
                                                          (device) =>
                                                      device[
                                                      'MacAddress'] ==
                                                          macAddress,
                                                    )['sw2'] ==
                                                        0
                                                        ? 1
                                                        : 0,
                                                  },
                                                  ip,
                                                  port,
                                                );
                                              } else if (index == 1) {
                                                sendFrame(
                                                  {
                                                    "commands": 'SWITCH_WRITE',
                                                    "mac_address": macAddress,
                                                    "sw2": deviceStatus.firstWhere(
                                                          (device) =>
                                                      device[
                                                      'MacAddress'] ==
                                                          macAddress,
                                                    )['sw3'] ==
                                                        0
                                                        ? 1
                                                        : 0,
                                                  },
                                                  ip,
                                                  port,
                                                );
                                              } else {
                                                sendFrame(
                                                  {
                                                    "commands": 'SWITCH_WRITE',
                                                    "mac_address": macAddress,
                                                    "led": deviceStatus.firstWhere(
                                                          (device) =>
                                                      device[
                                                      'MacAddress'] ==
                                                          macAddress,
                                                    )['led'] ==
                                                        0
                                                        ? 1
                                                        : 0,
                                                  },
                                                  ip,
                                                  port,
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    ledInfo[index],
                                    style: TextStyle(
                                      color: deviceStatus.firstWhere(
                                            (device) =>
                                        device['MacAddress'] ==
                                            macAddress,
                                      )['sw${adjustedIndex + 1}'] ==
                                          1 || (adjustedIndex == 3 && deviceStatus.firstWhere((device) => device['MacAddress'] == macAddress,)['led'] == 1)
                                          ? const Color(0xFF047424)
                                          : isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade800,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Consumer<AuthProvider>(
                      builder: (context, switchesProvider, child) {
                        return deviceStatus.firstWhere(
                              (device) => device['MacAddress'] == macAddress,
                        )['sw2'] ==
                            1
                            ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: ColorPicker(
                            pickerColor: tempColor,
                            onColorChanged: (color) {
                              if (debounce?.isActive ?? false) {
                                debounce!.cancel();
                              }

                              setState(() {
                                tempColor = color;
                              });

                              debounce = Timer(
                                  const Duration(milliseconds: 100), () {
                                setState(() {
                                  currentColor = tempColor;
                                });
                                sendFrame(
                                  {
                                    "commands": "RGB_WRITE",
                                    "mac_address": macAddress,
                                    "red": currentColor.red,
                                    "green": currentColor.green,
                                    "blue": currentColor.blue,
                                  },
                                  ip,
                                  port,
                                );
                              });
                            },
                            paletteType: PaletteType.hueWheel,
                            enableAlpha: false,
                            labelTypes: const [],
                            colorPickerWidth: 250,
                          ),
                        )
                            : kEmptyWidget;
                      }),
                ),
              ],
            ),
          )),
    );
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }
}
