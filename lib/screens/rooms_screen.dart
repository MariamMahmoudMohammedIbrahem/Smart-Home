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
    return Scaffold(
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
                                          _showOptions(context, index);
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
                                            _showOptions(
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

  void _showOptions(context, int index) {
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
                  Icons.edit,
                  color: MyColors.greenDark1,
                ),
                title: const Text(
                  'Edit',
                  style: TextStyle(
                    color: MyColors.greenDark1,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDialog(
                    context,
                    'editRoomName',
                    index,
                  );
                },
              ),
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
                  deleteRoomAndDevices(
                        roomIDs[index],
                      )
                      .then((value) => {
                            getRoomsByApartmentID(
                                  context,
                                  apartmentMap.first['ApartmentID'],
                                )
                                .then((value) => {
                                      exportData(),
                                      setState(() {
                                        Provider.of<AuthProvider>(context,
                                                listen: false)
                                            .toggling(
                                          'loading',
                                          false,
                                        );
                                      }),
                                      Navigator.pop(context),
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
  }

  void _showDialog(context, String type, int index) {
    showDialog(
        context: context,
        builder: (context) {
          IconData? selectedIconInDialog = getIconName(
            roomNames[index],
          );
          String? hintMessage;
          return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: const Text(
                  'Edit Room Name',
                  style: TextStyle(
                    color: MyColors.greenDark1,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButton<IconData>(
                        value: selectedIconInDialog,
                        menuMaxHeight: 200,
                        icon: const Icon(
                          Icons.arrow_downward,
                          color: MyColors.greenDark1,
                        ),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(
                          color: MyColors.greenDark1,
                        ),
                        underline: Container(
                          height: 2,
                          color: MyColors.greenDark1,
                        ),
                        onChanged: (IconData? newValue) {
                          setStateDialog(() {
                            selectedIconInDialog = newValue;
                            selectedIcon = newValue!;
                            String selectedRoomName = getRoomName(
                              newValue,
                            );
                            if (roomNames.contains(
                              selectedRoomName,
                            )) {
                              hintMessage = 'This room name is already in use!';
                            } else {
                              hintMessage = null;
                            }
                          });
                        },
                        items: iconsRooms
                            .map<DropdownMenuItem<IconData>>((IconData icon) {
                          return DropdownMenuItem<IconData>(
                            value: icon,
                            child: Row(
                              children: [
                                Icon(
                                  icon,
                                  color: MyColors.oliveDark,
                                ),
                                width10,
                                Text(
                                  getRoomName(icon),
                                ),
                              ],
                            ),
                            onTap: () {
                              setStateDialog(() {
                                roomName = getRoomName(icon);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (hintMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            hintMessage!,
                            style: TextStyle(
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(
                        color: MyColors.greenDark1,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: MyColors.greenDark1,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.greenDark1,
                    ),
                    onPressed: () {
                      if (hintMessage == null) {
                        updateRoomName(apartmentMap.first['ApartmentID'],
                                roomName, roomNames[index])
                            .then(
                              (value) => exportData().then(
                                    (value) => getRoomsByApartmentID(
                                      context,
                                      apartmentMap.first['ApartmentID'],
                                    ),
                                  ),
                            )
                            .then((value) {
                          setState(() {
                            Provider.of<AuthProvider>(context, listen: false)
                                .toggling('loading', false);
                          });
                          Navigator.pop(context);
                        });
                      } else {}
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Provider.of<AuthProvider>(context).isDarkMode
                            ? Colors.grey[900]
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }
}
