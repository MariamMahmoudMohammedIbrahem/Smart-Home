import 'package:auto_size_text/auto_size_text.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mega/udp.dart';
import 'package:mega/ui/room_info.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../db/functions.dart';

class Rooms extends StatefulWidget {
  const Rooms({super.key});

  @override
  State<Rooms> createState() => _RoomsState();
}

class _RoomsState extends State<Rooms> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Animation<double>? _animation;
  AnimationController? _animationController;
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SocketManager().startListen(context);
    });
    // setState(() {
    sqlDb.getRoomsByDepartmentID(1).then((value) {
      setState(() {
        roomNames.toList();
        loading = false;
      });
    });
    // });
    print('inside init $roomNames');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController!);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _isMenuOpen = false;
    super.dispose();
  }

  @override
  Widget build(context) {
    /*Color getForegroundColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.focused)) return Colors.pink.shade600;
      if (states.contains(MaterialState.pressed)) return Colors.pink.shade400;
      return Colors.pink.shade800;
    }

    Color getBackgroundColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.focused)) return Colors.pink.shade700;
      if (states.contains(MaterialState.pressed)) return Colors.pink;
      return Colors.pink.shade900;
    }

    BorderSide getBorderSide(Set<MaterialState> states) {
      final color = getForegroundColor(states);
      return BorderSide(width: 3, color: color);
    }

    final foregroundColor = MaterialStateProperty.resolveWith<Color>(
        (states) => getForegroundColor(states));
    final backgroundColor = MaterialStateProperty.resolveWith<Color>(
        (states) => getBackgroundColor(states));
    final side = MaterialStateProperty.resolveWith<BorderSide>(
        (states) => getBorderSide(states));
    final style = ButtonStyle(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );*/

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          departmentMap.firstWhere((dept) => dept['DepartmentID'] == 1,
              orElse: () => {'DepartmentName': ''})['DepartmentName'],
        ),
        titleTextStyle: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      floatingActionButton: FloatingActionBubble(
        items: <Bubble>[
          Bubble(
            title: "Add Device",
            iconColor: Colors.white,
            bubbleColor: Colors.pink.shade900,
            icon: Icons.device_unknown,
            titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              _animationController!.reverse();
              setState(() {
                _isMenuOpen = false;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UDPScreen(),
                ),
              );
            },
          ),
          Bubble(
            title: "Add Department",
            iconColor: Colors.white,
            bubbleColor: Colors.pink.shade900,
            icon: Icons.home,
            titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              _showDialog(context, 'addDepartment', 0);
            },
          ),
        ],
        animation: _animation!,
        onPress: () {
          _animationController!.isCompleted
              ? _animationController!.reverse()
              : _animationController!.forward();
          _toggleMenu();
        },
        backGroundColor: Colors.pink.shade900,
        iconColor: Colors.white,
        iconData: _isMenuOpen ? Icons.close : Icons.add,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .05, vertical: 10),
          child: Column(
            children: [
              /*ElevatedButton(
                onPressed: () async {
                  await sqlDb.insertRoom('Baby Bedroom', 1);
                  await sqlDb.insertRoom('Kitchen', 1);
                  await sqlDb.insertRoom('Parent Bedroom', 1);
                },
                child: const Text(
                  'adding rooms to database',
                ),
              ),
              Text('roomIDs => $roomIDs'),
              ElevatedButton(
                onPressed: () async {
                  await sqlDb.insertDevice(
                      '84:F3:EB:20:8C:7A', 'Mariam', '15687412', 'switch', 1);
                  await sqlDb.insertDevice(
                      '2A:2D:3C:4D', 'wifiName', 'wifiPassword', 'Switch', 1);
                },
                child: const Text(
                  'adding devices into Rooms',
                ),
              ),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rooms',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: Colors.pink.shade900,
                    ),
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, toggleProvider, child) {
                      return IconButton(
                        onPressed: () {
                          toggleProvider.toggling(!toggleProvider.toggle);
                        },
                        icon: Icon(
                          toggleProvider.toggle
                              ? Icons.grid_view_rounded
                              : Icons.list_outlined,
                          color: Colors.pink.shade900,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Flexible(
                child: loading
                    ? CircularProgressIndicator(
                        color: Colors.pink.shade900,
                      )
                    : roomNames.isEmpty
                        ? SizedBox(
                            child: Text(
                              'There is no data to show',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.pink.shade900,
                              ),
                            ),
                          )
                        : Provider.of<AuthProvider>(context).toggle
                            ? GridView.builder(
                                // gridDelegate:
                                //     const SliverGridDelegateWithFixedCrossAxisCount(
                                //   crossAxisCount: 2,
                                //   mainAxisSpacing: 15.0,
                                //   crossAxisSpacing: 15.0,
                                //       mainAxisExtent: 2000,
                                // ),
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent:
                                      width * 0.45, //   crossAxisCount: 2,
                                    mainAxisSpacing: 15.0,
                                    crossAxisSpacing: 15.0,
                                        mainAxisExtent: height * .27,
                                ),
                                itemCount: roomNames.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        color: Colors.pink.shade900,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                            child: AutoSizeText(
                                              roomNames[index],
                                              style: const TextStyle(
                                                color: Colors.white,
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
                                            color: Colors.white,
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
                                              roomIDs[index])
                                          .then(
                                            (value) => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RoomDetail(
                                                  roomName: roomNames[index],
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
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          color: Colors.pink.shade900,
                                        ),
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Row(
                                          children: [
                                            Icon(
                                              getIconName(roomNames[index]),
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            const SizedBox(
                                              width: 5.0,
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: AutoSizeText(
                                                roomNames[index],
                                                style: const TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
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
                                                roomIDs[index])
                                            .then(
                                              (value) => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RoomDetail(
                                                    roomName: roomNames[index],
                                                    roomID: roomIDs[index],
                                                  ),
                                                ),
                                              ),
                                            );
                                      },
                                      onLongPress: () {
                                        _showOptions(context, index);
                                      },
                                    ),
                                  );
                                },
                              ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.edit,
                  color: Colors.pink.shade900,
                ),
                title: Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.pink.shade900,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDialog(context, 'editRoomName', index);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Colors.pink.shade900,
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.pink.shade900,
                  ),
                ),
                onTap: () {
                  sqlDb.deleteRoomsAndDevices(roomIDs[index]).then((value) => {
                        sqlDb.getRoomsByDepartmentID(1).then((value) => {
                              setState(() {
                                loading = false;
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
          IconData? selectedIconInDialog = getIconName(roomNames[index]);
          String? hintMessage;
          return type == 'addDepartment'
              ? AlertDialog(
                  title: Text(
                    'Add New Department',
                    style: TextStyle(color: Colors.pink.shade900),
                  ),
                  content: TextFormField(),
                  actions: [
                    TextButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.pink.shade900,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel',
                          style: TextStyle(color: Colors.pink.shade900)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade900),
                      onPressed: () {
                        // if (_formKey.currentState!.validate()) {
                        //   _formKey.currentState!.save();
                        Navigator.of(context).pop();
                        // }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              : StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: Text(
                        'Edit Room Name',
                        style: TextStyle(color: Colors.pink.shade900),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            DropdownButton<IconData>(
                              value: selectedIconInDialog,
                              menuMaxHeight: 200,
                              icon: Icon(
                                Icons.arrow_downward,
                                color: Colors.pink.shade900,
                              ),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.pink.shade900),
                              underline: Container(
                                height: 2,
                                color: Colors.pink.shade900,
                              ),
                              onChanged: (IconData? newValue) {
                                setStateDialog(() {
                                  selectedIconInDialog = newValue;
                                  selectedIcon = newValue!;
                                  String selectedRoomName =
                                      getRoomName(newValue);
                                  // Check if the selected room name is in use
                                  if (roomNames.contains(selectedRoomName)) {
                                    hintMessage =
                                        'This room name is already in use!';
                                  } else {
                                    hintMessage = null;
                                  }
                                  print('Selected Icon is => $selectedIcon');
                                });
                              },
                              items: iconsRooms.map<DropdownMenuItem<IconData>>(
                                  (IconData icon) {
                                return DropdownMenuItem<IconData>(
                                  value: icon,
                                  child: Row(
                                    children: [
                                      Icon(icon),
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
                            if (hintMessage !=
                                null) // Display the hint if it exists
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  hintMessage!,
                                  style: TextStyle(color: Colors.red.shade800),
                                ),
                              ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.pink.shade900,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel',
                              style: TextStyle(color: Colors.pink.shade900)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade900),
                          onPressed: () {
                            if (hintMessage == null) {
                              sqlDb
                                  .updateRoomName(1, roomName, roomNames[index])
                                  .then(
                                    (value) => sqlDb.getRoomsByDepartmentID(1),
                                  )
                                  .then((value) {
                                setState(() {
                                  loading = false;
                                });
                                Navigator.pop(context);
                              });
                            }
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                );
        });
    _animationController!.reverse();
    setState(() {
      _isMenuOpen = false;
    });
  }
}
