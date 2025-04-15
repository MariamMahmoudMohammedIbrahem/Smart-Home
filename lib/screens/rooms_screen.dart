import '../commons.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.only(start: 16.0, end: 16.0),
        leading: Text(
          apartmentMap.isNotEmpty ? apartmentMap.first['ApartmentName'] : 'My Home',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: MyColors.greenDark1,
          ),
        ),
        trailing: Consumer<AuthProvider>(
          builder: (context, toggleProvider, child) {
            return IconButton(
              onPressed: () {
                getAllMacAddresses().then(
                      (value) => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ),
                );
              },
              icon: toggleProvider.notificationMark
                  ? Badge(
                label: null,
                backgroundColor: Colors.red,
                child: Icon(
                  CupertinoIcons.settings,
                  color: MyColors.greenDark1,
                ),
              )
                  : Icon(
                CupertinoIcons.settings,
                color: MyColors.greenDark1,
              ),
            );
          },
        ),
      ),
      child:  SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .05, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rooms',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          color: MyColors.greenDark1,
                        ),
                      ),
                      Consumer<AuthProvider>(
                        builder: (context, toggleProvider, child) {
                          return IconButton(
                            onPressed: () {
                              toggleProvider.toggling(
                                'toggling',
                                !toggleProvider.toggle,
                              );
                            },
                            icon: Icon(
                              toggleProvider.toggle
                                  ? Icons.grid_view_rounded
                                  : Icons.list_outlined,
                              color: MyColors.greenDark1,
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
                          color: MyColors.greenDark1,
                        )
                            : roomNames.isEmpty
                            ? const SizedBox(
                          child: Text(
                            'There is no data to show',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: MyColors.greenDark1,
                            ),
                          ),
                        )
                            : Provider.of<AuthProvider>(context).toggle
                            ? GridView.builder(
                          gridDelegate:
                          SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: width * 0.45,
                            mainAxisSpacing: 15.0,
                            crossAxisSpacing: 15.0,
                            // mainAxisExtent: height * .27,
                          ),
                          itemCount: roomNames.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.transparent
                                      : Theme.of(context)
                                      .primaryColor,
                                  border: isDarkMode
                                      ? Border.all(
                                    color: Theme.of(context)
                                        .primaryColor,
                                    width: 2,
                                  )
                                      : null,
                                  borderRadius:
                                  BorderRadius.circular(25.0),
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
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? const Color(
                                              0xFF047424)
                                              : Colors.white,
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
                                      color: isDarkMode
                                          ? MyColors.greenDark1
                                          : Colors.white,
                                      size: width * .25,
                                    ),
                                  ],
                                ),
                              ),
                              onLongPress: () {
                                showCustomizedOptions(context, index);
                              },
                              onTap: () {
                                getDeviceDetailsByRoomID(
                                  roomIDs[index],
                                )
                                    .then(
                                      (value) => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RoomDetailsScreen(
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
                                    color: isDarkMode
                                        ? Colors.transparent
                                        : Theme.of(context)
                                        .primaryColor,
                                    border: isDarkMode
                                        ? Border.all(
                                      color: Theme.of(context)
                                          .primaryColor,
                                      width: 2,
                                    )
                                        : null,
                                    borderRadius:
                                    BorderRadius.circular(25.0),
                                  ),
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        getIconName(
                                          roomNames[index],
                                        ),
                                        color: isDarkMode
                                            ? MyColors.greenDark1
                                            : Colors.white,
                                        size: 30,
                                      ),
                                      width5,
                                      Align(
                                        alignment:
                                        Alignment.centerLeft,
                                        child: AutoSizeText(
                                          roomNames[index],
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: isDarkMode
                                                ? const Color(
                                                0xFF047424)
                                                : Colors.white,
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
                                  getDeviceDetailsByRoomID(
                                    roomIDs[index],
                                  )
                                      .then(
                                        (value) => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RoomDetailsScreen(
                                              roomName:
                                              roomNames[index],
                                              roomID: roomIDs[index],
                                            ),
                                      ),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  showCustomizedOptions(
                                    context,
                                    index,
                                  );
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
        )
        : Scaffold(
          appBar: AppBar(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            title: Text(
              apartmentMap.isNotEmpty ? apartmentMap.first['ApartmentName'] : '',
            ),
            titleTextStyle: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: MyColors.greenDark1,
            ),
            actions: [
              Consumer<AuthProvider>(
                builder: (context, toggleProvider, child) {
                  return IconButton(
                    onPressed: () {
                      getAllMacAddresses().then(
                            (value) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            ),
                          );
                    },
                    icon: toggleProvider.notificationMark
                        ? const Badge(
                            label: null,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.settings_rounded,
                                color: MyColors.greenDark1),
                          )
                        : const Icon(Icons.settings_rounded,
                            color: MyColors.greenDark1),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .05, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rooms',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          color: MyColors.greenDark1,
                        ),
                      ),
                      Consumer<AuthProvider>(
                        builder: (context, toggleProvider, child) {
                          return IconButton(
                            onPressed: () {
                              toggleProvider.toggling(
                                'toggling',
                                !toggleProvider.toggle,
                              );
                            },
                            icon: Icon(
                              toggleProvider.toggle
                                  ? Icons.grid_view_rounded
                                  : Icons.list_outlined,
                              color: MyColors.greenDark1,
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
                                color: MyColors.greenDark1,
                              )
                            : roomNames.isEmpty
                                ? const SizedBox(
                                    child: Text(
                                      'There is no data to show',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: MyColors.greenDark1,
                                      ),
                                    ),
                                  )
                                : Provider.of<AuthProvider>(context).toggle
                                    ? GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: width * 0.45,
                                          mainAxisSpacing: 15.0,
                                          crossAxisSpacing: 15.0,
                                          mainAxisExtent: height * .27,
                                        ),
                                        itemCount: roomNames.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isDarkMode
                                                    ? Colors.transparent
                                                    : Theme.of(context)
                                                        .primaryColor,
                                                border: isDarkMode
                                                    ? Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        width: 2,
                                                      )
                                                    : null,
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
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
                                                      style: TextStyle(
                                                        color: isDarkMode
                                                            ? const Color(
                                                                0xFF047424)
                                                            : Colors.white,
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
                                                    color: isDarkMode
                                                        ? MyColors.greenDark1
                                                        : Colors.white,
                                                    size: width * .25,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onLongPress: () {
                                              showCustomizedOptions(context, index);
                                            },
                                            onTap: () {
                                              getDeviceDetailsByRoomID(
                                                    roomIDs[index],
                                                  )
                                                  .then(
                                                    (value) => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RoomDetailsScreen(
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
                                                  color: isDarkMode
                                                      ? Colors.transparent
                                                      : Theme.of(context)
                                                          .primaryColor,
                                                  border: isDarkMode
                                                      ? Border.all(
                                                          color: Theme.of(context)
                                                              .primaryColor,
                                                          width: 2,
                                                        )
                                                      : null,
                                                  borderRadius:
                                                      BorderRadius.circular(25.0),
                                                ),
                                                padding: const EdgeInsets.only(
                                                  left: 15,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      getIconName(
                                                        roomNames[index],
                                                      ),
                                                      color: isDarkMode
                                                          ? MyColors.greenDark1
                                                          : Colors.white,
                                                      size: 30,
                                                    ),
                                                    width5,
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: AutoSizeText(
                                                        roomNames[index],
                                                        style: TextStyle(
                                                          fontSize: 18.0,
                                                          color: isDarkMode
                                                              ? const Color(
                                                                  0xFF047424)
                                                              : Colors.white,
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
                                                getDeviceDetailsByRoomID(
                                                      roomIDs[index],
                                                    )
                                                    .then(
                                                      (value) => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              RoomDetailsScreen(
                                                            roomName:
                                                                roomNames[index],
                                                            roomID: roomIDs[index],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                              },
                                              onLongPress: () {
                                                showCustomizedOptions(
                                                  context,
                                                  index,
                                                );
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

  @override
  void initState() {
    // startListeningForNetworkChanges();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SocketManager().startListen(context);
    });
    getRoomsByApartmentID(context, apartmentMap.first['ApartmentID'])
        .then((value) {
      setState(() {
        Provider.of<AuthProvider>(context, listen: false).toggling(
          'loading',
          false,
        );
      });
    });
    super.initState();
  }


}

Future<Map<String, dynamic>> backupRoomAndDevices(int roomId) async {
  final backupData = await getRoomAndDevices(roomId);
  return backupData;
}
Future<void> deleteRoom(int roomId, BuildContext context) async {
  await deleteRoomAndDevices(roomId);
  // Navigator.pop(context);
}
/*Future<void> restoreRoomAndDevices(
    Map<String, dynamic> room,
    List<Map<String, dynamic>> devices,
    BuildContext context,
    ) async {
  final restoredRoomId = await insertRoom(
    room['RoomName'],
    apartmentMap.first['ApartmentID'],
  );

  for (final device in devices) {
    await insertDevice(
      device['MacAddress'],
      device['WifiName'] ?? '',
      device['WifiPassword'] ?? '',
      device['DeviceName'],
      restoredRoomId,
    );
  }

  await refreshUI(context);
}
void showStyledSnackBar(
    BuildContext context,
    Map<String, dynamic> room,
    List<Map<String, dynamic>> devices,
    ) {
  undoAction() async {
    await restoreRoomAndDevices(room, devices, context);
  }

  final snackBar = SnackBar(
    duration: Duration(seconds: 5),
    backgroundColor: MyColors.greenDark1,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),

    content: Row(
      children: [
        Icon(Icons.delete_forever, color: Colors.white),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            "Room deleted",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
    action: SnackBarAction(
      label: "UNDO",
      textColor: Colors.white,
      onPressed: undoAction,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);

  // Optional: Auto-refresh if UNDO is not used
  Future.delayed(Duration(seconds: 5), () async {
    await refreshUI(context);
  });
}*/

Future<void> onTapDeleteRoom(BuildContext context, int roomId) async {
  // final backupData = await backupRoomAndDevices(roomId);
  // final room = backupData['room'];
  // final devices = backupData['devices'] as List<Map<String, dynamic>>;

  // if (room == null) {
  //   print("Room not found");
  //   return;
  // }

  await deleteRoom(roomId, context);
  refreshUI(context);
  Navigator.pop(context);
  // showStyledSnackBar(context, room, devices);

}

Future<void> refreshUI(BuildContext context) async {
  final apartmentId = apartmentMap.first['ApartmentID'];
  await getRoomsByApartmentID(context, apartmentId);
  exportData();
}


/*
void onTapDeleteRoom(BuildContext context, int roomId) async {
  // final db = sqlDb; // assuming sqlDb is accessible here

  // 1. Backup room & devices
  final backupData = await getRoomAndDevices(roomId);
  final room = backupData['room'];
  final devices = backupData['devices'] as List<Map<String, dynamic>>;

  if (room == null) {
    print("Room not found");
    return;
  }

  // 2. Delete room & its devices
  await deleteRoomAndDevices(roomId);
  Navigator.pop(context);
  refreshUI(context);

  // 3. Show Undo SnackBar
  Platform.isIOS
  ? CupertinoActionSheet(
    title: Text("Room deleted"),
    message: Text("The room has been deleted"),
    actions: [
      CupertinoActionSheetAction(
        onPressed: () async {
          // 4. Restore room first
          await insertRoom(
            room['RoomName'], // adapt if your insertRoom requires more fields
            apartmentMap.first['ApartmentID'], // assuming this is your schema
          ).then((value){
            // 5. Restore devices
            for (final device in devices) {
              insertDevice(
                device['MacAddress'],
                device['WifiName'] ?? '',
                device['WifiPassword'] ?? '',
                device['DeviceName'],
                value,
              );
            }
          });

          // 6. Refresh UI
          await refreshUI(context);
        },
        child: Text("UNDO"),
      ),
    ],
  )
  : ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Room deleted"),
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: "UNDO",
        onPressed: () async {
          // 4. Restore room first
          await insertRoom(
            room['RoomName'], // adapt if your insertRoom requires more fields
            apartmentMap.first['ApartmentID'], // assuming this is your schema
          ).then((value){
            // 5. Restore devices
            for (final device in devices) {
              insertDevice(
                device['MacAddress'],
                device['WifiName'] ?? '',
                device['WifiPassword'] ?? '',
                device['DeviceName'],
                value,
              );
            }
          });

          // 6. Refresh UI
          await refreshUI(context);
        },
      ),
    ),
  );
  // 7. Auto-refresh if undo not used
  Future.delayed(Duration(seconds: 5), () async {
    await refreshUI(context);
  });
}*/


/*void showUndoUI(
    BuildContext context,
    Map<String, dynamic> room,
    List<Map<String, dynamic>> devices,
    ) {
  final undoAction = () async {
    await restoreRoomAndDevices(room, devices, context);
  };

  if (Platform.isIOS) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text("Room deleted"),
        message: Text("The room has been deleted"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: undoAction,
            child: Text("UNDO"),
          ),
        ],
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Room deleted"),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: undoAction,
        ),
      ),
    );
  }

  // Auto-refresh if undo is not used
  Future.delayed(Duration(seconds: 5), () async {
    await refreshUI(context);
  });
}*/