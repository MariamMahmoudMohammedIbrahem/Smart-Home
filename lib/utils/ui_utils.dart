import '../commons.dart';

String getRoomName(IconData icon) {
  if (icon == Icons.living) {
    return 'Living Room';
  } else if (icon == Icons.bedroom_baby) {
    return 'Baby Bedroom';
  } else if (icon == Icons.bedroom_parent) {
    return 'Parent Bedroom';
  } else if (icon == Icons.kitchen) {
    return 'Kitchen';
  } else if (icon == Icons.bathroom) {
    return 'Bathroom';
  } else if (icon == Icons.dining) {
    return 'Dining Room';
  } else if (icon == Icons.desk) {
    return 'Desk';
  } else if (icon == Icons.local_laundry_service) {
    return 'Laundry Room';
  } else if (icon == Icons.garage) {
    return 'Garage';
  } else {
    return 'Outdoor';
  }
}

IconData getIconName(String name) {
  if (name == 'Living Room') {
    return Icons.living;
  } else if (name == 'Baby Bedroom') {
    return Icons.bedroom_baby;
  } else if (name == 'Parent Bedroom') {
    return Icons.bedroom_parent;
  } else if (name == 'Kitchen') {
    return Icons.kitchen;
  } else if (name == 'Bathroom') {
    return Icons.bathroom;
  } else if (name == 'Dining Room') {
    return Icons.dining;
  } else if (name == 'Desk') {
    return Icons.desk;
  } else if (name == 'Laundry Room') {
    return Icons.local_laundry_service;
  } else if (name == 'Garage') {
    return Icons.garage;
  } else {
    return Icons.camera_outdoor;
  }
}

// void showSnack(BuildContext context, String message, String msg) {
//   final currentTime = DateTime.now();
//
//   if (snackBarCount < maxSnackBarCount && (lastSnackBarTime == null || currentTime.difference(lastSnackBarTime!).inSeconds > 2)) {
//     final snackBar = SnackBar(
//       content: Text(message),
//     );
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     lastSnackBarTime = currentTime;
//     snackBarCount++;
//   }
//   if(snackBarCount == maxSnackBarCount){
//     showHint(context, msg);
//   }
// }

void showSnack(BuildContext context, String message, String msg) {
  final currentTime = DateTime.now();

  if (snackBarCount < maxSnackBarCount &&
      (lastSnackBarTime == null || currentTime.difference(lastSnackBarTime!).inSeconds > 2)) {

    if (Platform.isIOS) {
      // Cupertino-style toast message (Custom Overlay)
      showCupertinoSnackBar(context, message);
    } else {
      // Material-style SnackBar
      final snackBar = SnackBar(
        content: Text(message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    lastSnackBarTime = currentTime;
    snackBarCount++;
  }

  if (snackBarCount == maxSnackBarCount) {
    showHint(context, msg);
  }
}

// Custom Cupertino Snackbar using Overlay
void showCupertinoSnackBar(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 50,
      // left: MediaQuery.of(context).size.width * 0.1,
      width: MediaQuery.of(context).size.width,
      child: CupertinoPopupSurface(
        isSurfacePainted: true,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              message,
              style: TextStyle(color: CupertinoColors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

void showHint(BuildContext context, String msg){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Hint'),
        content: Text(msg),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              if(currentStep == 0){
                Provider.of<AuthProvider>(context, listen: false).toggling('adding', false);
              }
              else if(currentStep == 2){
                snackBarCount = 0;
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void showCustomizedOptions(context, int index) {
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
                showCustomizedDialog(
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
                onTapDeleteRoom(context, roomIDs[index]);
                /*deleteRoomAndDevices(
                  roomIDs[index],
                )
                    .then((value) => {
                  getRoomsByApartmentID(
                    context,
                    apartmentMap.first['ApartmentID'],
                  )
                      .then((value) => {
                    exportData(),
                      Provider.of<AuthProvider>(context,
                          listen: false)
                          .toggling(
                        'loading',
                        false,
                      ),
                    Navigator.pop(context),
                  }),
                });*/
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

void showCustomizedDialog(context, String type, int index) {
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
                        // setState(() {
                          Provider.of<AuthProvider>(context, listen: false)
                              .toggling('loading', false);
                        // });
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

Future<void> promptEnableLocation (BuildContext context, VoidCallback action) async{
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  print("3");
  
  if(!serviceEnabled) {
    print("4");
    showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (context) => Platform.isIOS
            ? CupertinoAlertDialog(
          title: const Text("Enable Location"),
          content: const Text("Adding new Devices require location services to be enabled."),
          actions: [
            CupertinoDialogAction(child: Text("Proceed"), onPressed: (){Navigator.pop(context);action();}),
            CupertinoDialogAction(child: Text("Open Settings"), onPressed: () async{Navigator.pop(context);await Geolocator.openLocationSettings();}),
          ],
        )
            : AlertDialog(
              title: const Text("Enable Location"),
              content: const Text("Adding new Devices require location services to be enabled."),
              actions: [
                TextButton(child: Text("Proceed"), onPressed: (){Navigator.pop(context);action();}),
                TextButton(child: Text("Open Settings"), onPressed: () async{Navigator.pop(context);await Geolocator.openLocationSettings();}),
              ],
            )
    );
  } else {
    print("5");
    action();
  }
}

// 🔄 SnackBar Function (Material or Cupertino)
void showUndoSnackBar(BuildContext context, VoidCallback onUndo, int countdown, bool useMaterial) {
  if (useMaterial) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Prevent stacking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: countdown),
        backgroundColor: Colors.black87,
        content: Row(
          children: [
            CountdownCircle(countdown: countdown),
            SizedBox(width: 16),
            Expanded(child: Text('Item deleted')),
            TextButton(
              onPressed: () {
                onUndo();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: Text('UNDO', style: TextStyle(color: Colors.orange)),
            )
          ],
        ),
      ),
    );
  } else {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Undo Delete?'),
        content: Column(
          children: [
            SizedBox(height: 8),
            CountdownCircle(countdown: countdown),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text("Undo"),
            onPressed: () {
              Navigator.of(context).pop();
              onUndo();
            },
          ),
          CupertinoDialogAction(
            child: Text("Dismiss"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// ⭕ Countdown Circle Widget
class CountdownCircle extends StatelessWidget {
  final int countdown;

  const CountdownCircle({required this.countdown});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: countdown / 3,
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            backgroundColor: Colors.grey[300],
          ),
          Text('$countdown', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}