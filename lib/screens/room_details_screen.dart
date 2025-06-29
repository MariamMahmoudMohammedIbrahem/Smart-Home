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
  // Widget scaffoldBody (double width, bool isDarkMode) {
  //
  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: width * .07, vertical: 10),
  //     // child: SingleChildScrollView(
  //       child: ListView( /// changed from column to list view so we can comment single child scroll view
  //         children: [
  //           Visibility(
  //             visible: deviceDetails.length > 1,
  //             child: SingleChildScrollView(
  //               scrollDirection: Axis.horizontal,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: deviceDetails.asMap().entries.map((entry) {
  //                   Map<String, dynamic> device = entry.value;
  //                   String macAddressDevice = device['MacAddress'];
  //                   return Padding(
  //                     padding: const EdgeInsets.symmetric(horizontal: 7.5),
  //                     child: ElevatedButton(
  //                       onPressed: () {
  //                         setState(() {
  //                           macAddress = macAddressDevice;
  //                         });
  //                       },
  //                       onLongPress: () {
  //                         /// TODO: material only need to be optimized with cupertino also
  //                         showModalBottomSheet(
  //                           context: context,
  //                           builder: (context) {
  //                             return Container(
  //                               decoration: BoxDecoration(
  //                                 color: Provider.of<AuthProvider>(context).isDarkMode
  //                                     ? Colors.grey[900]
  //                                     : Colors.white,
  //                                 borderRadius: const BorderRadius.only(
  //                                   topLeft: Radius.circular(20.0),
  //                                   topRight: Radius.circular(20.0),
  //                                 ),
  //                               ),
  //                               child: Column(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: <Widget>[
  //                                   ListTile(
  //                                     leading: const Icon(
  //                                       Icons.delete,
  //                                       color: MyColors.greenDark1,
  //                                     ),
  //                                     title: const Text(
  //                                       'Delete',
  //                                       style: TextStyle(
  //                                         color: MyColors.greenDark1,
  //                                       ),
  //                                     ),
  //                                     onTap: () {
  //                                       deleteDeviceByMacAddress(
  //                                         macAddressDevice,
  //                                       )
  //                                           .then((value) => {
  //                                         Provider.of<AuthProvider>(
  //                                             context,
  //                                             listen: false)
  //                                             .toggling(
  //                                           'delete',
  //                                           true,
  //                                         ),
  //                                         getDeviceDetailsByRoomID(
  //                                             widget.roomDetail.id!)
  //                                             .then((value) => {
  //                                           exportData(),
  //                                           Provider.of<AuthProvider>(
  //                                               context,
  //                                               listen:
  //                                               false)
  //                                               .toggling(
  //                                             'delete',
  //                                             false,
  //                                           ),
  //                                           Navigator.pop(
  //                                               context),
  //                                         }),
  //                                       });
  //                                     },
  //                                   ),
  //                                 ],
  //                               ),
  //                             );
  //                           },
  //                           backgroundColor: Colors.transparent,
  //                           isScrollControlled: true,
  //                         );
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         side: BorderSide(
  //                           color: macAddress == macAddressDevice
  //                               ? MyColors.greenDark1
  //                               : Colors.grey,
  //                         ),
  //                         backgroundColor: macAddress == macAddressDevice
  //                             ? MyColors.greyLight
  //                             : Colors.white,
  //                       ),
  //                       child: Text(
  //                         '${device['DeviceType'] ?? "Switch"} ${entry.key + 1}',
  //                         style: const TextStyle(
  //                           color: MyColors.greenDark1,
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 }).toList(),
  //               ),
  //             ),
  //           ),
  //           height10,
  //           GridView.builder(
  //             physics: const NeverScrollableScrollPhysics(),
  //             shrinkWrap: true,
  //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //               crossAxisCount: 2,
  //               mainAxisSpacing: 15.0,
  //               crossAxisSpacing: 15.0,
  //             ),
  //             itemCount: 4,
  //             itemBuilder: (context, index) {
  //               int adjustedIndex = (index == 1) ? 2 : (index == 2) ? 1 : index;
  //               final device = findDeviceByMac(deviceStatus, macAddress);
  //
  //               final isActive = device?.getSwitchValue(adjustedIndex) == 1;
  //               final borderColor = resolveColor(isActive, isDarkMode, MyColors.greenDark1);
  //               final backgroundColor = isDarkMode
  //                   ? Colors.transparent
  //                   : isActive
  //                   ? MyColors.greyLight
  //                   : Colors.grey.shade200;
  //
  //               return GestureDetector(
  //                 child: Consumer<AuthProvider>(
  //                   builder: (context, switchesProvider, child) {
  //                     return Container(
  //                       decoration: BoxDecoration(
  //                         color: backgroundColor,
  //                         borderRadius: BorderRadius.circular(20),
  //                         border: Border.all(color: borderColor),
  //                       ),
  //                       padding: const EdgeInsets.symmetric(horizontal: 20),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Icon(
  //                                 adjustedIndex == 3
  //                                     ? Icons.light_mode_outlined
  //                                     : adjustedIndex == 1
  //                                     ? Icons.color_lens_outlined
  //                                     : Icons.lightbulb_circle_outlined,
  //                                 color: borderColor,
  //                                 size: 40,
  //                               ),
  //                               Platform.isIOS
  //                                 ? CupertinoSwitch(
  //                                 value: isActive,
  //                                 onChanged: (newValue){switchOnChanged(adjustedIndex, device, newValue?1:0);},
  //                                 )
  //                                 : Switch(
  //                                   value: isActive,
  //                                   onChanged: (newValue){switchOnChanged(adjustedIndex, device, newValue?1:0);},
  //                                 ),
  //                             ],
  //                           ),
  //                           Text(
  //                             ledInfo[index],
  //                             style: TextStyle(
  //                               color: borderColor,
  //                               fontSize: 20,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               );
  //             },
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 8.0),
  //             child: Consumer<AuthProvider>(
  //               builder: (context, switchesProvider, child) {
  //                 final device = findDeviceByMac(deviceStatus, macAddress);
  //                 final isSw2On = device?.sw2 == 1;
  //
  //                 return isSw2On
  //                     ? Padding(
  //                   padding: const EdgeInsets.symmetric(vertical: 15.0),
  //                   child: ColorPicker(
  //                     pickerColor: tempColor,
  //                     onColorChanged: (color) {
  //                       debounceConfirm?.cancel();
  //                       if (debounce?.isActive ?? false) {
  //                         debounce!.cancel();
  //                       }
  //
  //                       setState(() {
  //                         tempColor = color;
  //                       });
  //
  //                       debounce = Timer(
  //                         const Duration(milliseconds: 100),
  //                             () {
  //                           setState(() {
  //                             currentColor = tempColor;
  //                           });
  //
  //                           sendFrame(
  //                             {
  //                               "commands": "RGB_WRITE",
  //                               "mac_address": macAddress,
  //                               "red": currentColor.red,
  //                               "green": currentColor.green,
  //                               "blue": currentColor.blue,
  //                             },
  //                             ip,
  //                             port,
  //                           );
  //                         },
  //                       );
  //                       debounceConfirm = Timer(
  //                           const Duration(seconds: 10),(){
  //                         setState(() {
  //                           tempColor = device!.currentColor;
  //                         });
  //                       });
  //                     },
  //                     paletteType: PaletteType.hueWheel,
  //                     enableAlpha: false,
  //                     labelTypes: const [],
  //                     colorPickerWidth: 250,
  //                   ),
  //                 )
  //                     : kEmptyWidget;
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     // ),
  //   );
  // }
  Widget scaffoldBody(double width, bool isDarkMode) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .07, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (deviceDetails.length > 1) _buildDeviceButtons(authProvider),
            height10,
            _buildGridSwitches(isDarkMode),
            _buildColorPickerIfNeeded(),
          ],
        ),
      ),
    );
  }
  Widget _buildDeviceButtons(AuthProvider authProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(deviceDetails.length, (index) {
          final device = deviceDetails[index];
          final macAddressDevice = device['MacAddress'];

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
                      ? MyColors.greenDark1
                      : Colors.grey,
                ),
                backgroundColor: macAddress == macAddressDevice
                    ? MyColors.greyLight
                    : Colors.white,
              ),
              child: Text(
                '${device['DeviceType'] ?? "Switch"} ${index + 1}',
                style: const TextStyle(color: MyColors.greenDark1),
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
      Provider.of<AuthProvider>(context, listen: false).toggling('delete', true);
      getDeviceDetailsByRoomID(widget.roomDetail.id!).then((_) {
        exportData();
        Provider.of<AuthProvider>(context, listen: false).toggling('delete', false);
        Navigator.pop(context);
      });
    });
  }
  Widget _buildGridSwitches(bool isDarkMode) {
    return GridView.builder(
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
          "red": currentColor.red,
          "green": currentColor.green,
          "blue": currentColor.blue,
        },
        ip,
        port,
      );
    });

    // debounceConfirm = Timer(const Duration(seconds: 10), () {
    //   final device = findDeviceByMac(deviceStatus, macAddress);
    //   setState(() {
    //     tempColor = device!.currentColor;
    //   });
    // });
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
/*
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
          child: Padding(
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
                                            Material(
                                              child: ListTile(
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
                                                        widget.roomDetail.id!)
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
                                  '${device['DeviceType'] ?? "Switch"} ${entry.key + 1}',
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
                        int adjustedIndex = (index == 1) ? 2 : (index == 2) ? 1 : index;
                        final device = findDeviceByMac(deviceStatus, macAddress);

                        final isActive = device?.getSwitchValue(adjustedIndex) == 1;
                        final borderColor = resolveColor(isActive, isDarkMode, MyColors.greenDark1);
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
                                          adjustedIndex == 3
                                              ? Icons.light_mode_outlined
                                              : adjustedIndex == 1
                                              ? Icons.color_lens_outlined
                                              : Icons.lightbulb_circle_outlined,
                                          color: borderColor,
                                          size: 40,
                                        ),
                                        CupertinoSwitch(
                                          value: isActive,
                                          onChanged: (value) {
                                            final key = adjustedIndex == 3
                                                ? 'led'
                                                : 'sw$adjustedIndex';
                                            final newValue =
                                            device?.getSwitchValue(adjustedIndex) == 0 ? 1 : 0;

                                            sendFrame(
                                              {
                                                'commands': 'SWITCH_WRITE',
                                                'mac_address': macAddress,
                                                key: newValue,
                                              },
                                              ip,
                                              port,
                                            );
                                          },
                                        ),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Consumer<AuthProvider>(
                        builder: (context, switchesProvider, child) {
                          final device = findDeviceByMac(deviceStatus, macAddress);
                          final isSw2On = device?.sw2 == 1;

                          return isSw2On
                              ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: ColorPicker(
                              pickerColor: tempColor,
                              onColorChanged: (color) {
                                debounceConfirm?.cancel();
                                if (debounce?.isActive ?? false) {
                                  debounce!.cancel();
                                }

                                setState(() {
                                  tempColor = color;
                                  print("${tempColor.red}, ${tempColor.green}, ${tempColor.blue}");
                                });

                                debounce = Timer(
                                  const Duration(milliseconds: 100),
                                      () {
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
                                  },
                                );

                                debounceConfirm = Timer(
                                    const Duration(seconds: 10),(){
                                  setState(() {
                                    tempColor = device!.currentColor;
                                  });
                                });
                              },
                              paletteType: PaletteType.hueWheel,
                              enableAlpha: false,
                              labelTypes: const [],
                              colorPickerWidth: 250,
                            ),
                          )
                              : kEmptyWidget;
                        },
                      ),
                    ),
                  ],
                ),
              )),
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
                                                  widget.roomDetail.id!)
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
                              '${device['DeviceType'] ?? "Switch"} ${entry.key + 1}',
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
                    int adjustedIndex = (index == 1) ? 2 : (index == 2) ? 1 : index;
                    final device = findDeviceByMac(deviceStatus, macAddress);

                    final isActive = device?.getSwitchValue(adjustedIndex) == 1;
                    final borderColor = resolveColor(isActive, isDarkMode, MyColors.greenDark1);
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
                                      adjustedIndex == 3
                                          ? Icons.light_mode_outlined
                                          : adjustedIndex == 1
                                          ? Icons.color_lens_outlined
                                          : Icons.lightbulb_circle_outlined,
                                      color: borderColor,
                                      size: 40,
                                    ),
                                    Switch(
                                      value: isActive,
                                      onChanged: (value) {
                                        final key = adjustedIndex == 3
                                            ? 'led'
                                            : 'sw$adjustedIndex';
                                        final newValue =
                                        device?.getSwitchValue(adjustedIndex) == 0 ? 1 : 0;

                                        sendFrame(
                                          {
                                            'commands': 'SWITCH_WRITE',
                                            'mac_address': macAddress,
                                            key: newValue,
                                          },
                                          ip,
                                          port,
                                        );
                                      },
                                    ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Consumer<AuthProvider>(
                    builder: (context, switchesProvider, child) {
                      final device = findDeviceByMac(deviceStatus, macAddress);
                      final isSw2On = device?.sw2 == 1;

                      return isSw2On
                          ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ColorPicker(
                          pickerColor: tempColor,
                          onColorChanged: (color) {
                            debounceConfirm?.cancel();
                            if (debounce?.isActive ?? false) {
                              debounce!.cancel();
                            }

                            setState(() {
                              tempColor = color;
                            });

                            debounce = Timer(
                              const Duration(milliseconds: 100),
                                  () {
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
                              },
                            );
                            debounceConfirm = Timer(
                                const Duration(seconds: 10),(){
                                  setState(() {
                                    tempColor = device!.currentColor;
                                  });
                            });
                          },
                          paletteType: PaletteType.hueWheel,
                          enableAlpha: false,
                          labelTypes: const [],
                          colorPickerWidth: 250,
                        ),
                      )
                          : kEmptyWidget;
                    },
                  ),
                ),
              ],
            ),
          )),
    );*/