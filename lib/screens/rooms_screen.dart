import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mega/screens/room_details_screen.dart';
import 'package:mega/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../utils/functions.dart';

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
          color: Color(0xFF047424),
        ),
        actions: [
          IconButton(
            onPressed: () {
              sqlDb.getAllMacAddresses().then(
                    (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    ),
                  );
            },
            icon: const Icon(
              Icons.settings_rounded,
              color: Color(0xFF047424),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .05, vertical: 10),
          child: Column(
            children: [
              /*ElevatedButton(onPressed: (){sqlDb
                  .insertRoom('Kitchen',
                  apartmentMap.first['ApartmentID'])
                  .then((value) {
                sqlDb.getRoomsByApartmentID(context,
                    apartmentMap.first['ApartmentID']);
                sqlDb
                    .insertDevice(
                  '84:F3:EB:20:8C:7A',
                  'Hardware_room',
                  '01019407823EOIP',
                  'switch',
                  value,
                )
                    .then((value) => {
                  Provider.of<AuthProvider>(context,
                      listen: false)
                      .roomConfig = true,
                  sqlDb.exportData().then((value) =>
                      Provider.of<AuthProvider>(
                          context,
                          listen: false)
                          .toggling('adding', false))
                });
              });}, child: Text('add device'),),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rooms',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: Color(0xFF047424),
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
                          color: const Color(0xFF047424),
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
                            color: Color(0xFF047424),
                          )
                        : roomNames.isEmpty
                            ? const SizedBox(
                                child: Text(
                                  'There is no data to show',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Color(0xFF047424),
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
                                                    ? const Color(0xFF047424)
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
                                          sqlDb
                                              .getDeviceDetailsByRoomID(
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
                                                      ? const Color(0xFF047424)
                                                      : Colors.white,
                                                  size: 30,
                                                ),
                                                const SizedBox(
                                                  width: 5.0,
                                                ),
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
                                            sqlDb
                                                .getDeviceDetailsByRoomID(
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SocketManager().startListen(context);
    });
    sqlDb
        .getRoomsByApartmentID(context, apartmentMap.first['ApartmentID'])
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
                  color: Color(0xFF047424),
                ),
                title: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Color(0xFF047424),
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
                  color: Color(0xFF047424),
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Color(0xFF047424),
                  ),
                ),
                onTap: () {
                  sqlDb
                      .deleteRoomAndDevices(
                        roomIDs[index],
                      )
                      .then((value) => {
                            sqlDb
                                .getRoomsByApartmentID(
                                  context,
                                  apartmentMap.first['ApartmentID'],
                                )
                                .then((value) => {
                                      sqlDb.exportData(),
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
                    color: Color(0xFF047424),
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
                          color: Color(0xFF047424),
                        ),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(
                          color: Color(0xFF047424),
                        ),
                        underline: Container(
                          height: 2,
                          color: const Color(0xFF047424),
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
                                  color: const Color(0xFF455D56),
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
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
                        color: Color(0xFF047424),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF047424),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047424),
                    ),
                    onPressed: () {
                      if (hintMessage == null) {
                        sqlDb
                            .updateRoomName(apartmentMap.first['ApartmentID'],
                                roomName, roomNames[index])
                            .then(
                              (value) => sqlDb.exportData().then(
                                    (value) => sqlDb.getRoomsByApartmentID(
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
