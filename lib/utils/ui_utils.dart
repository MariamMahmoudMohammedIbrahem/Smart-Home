import '../commons.dart';

ObstructingPreferredSizeWidget? buildCupertinoNavBar(String title, BuildContext context) {
  return CupertinoNavigationBar(
    leading: CupertinoNavigationBarBackButton(
      color: MyColors.greenDark1,
      onPressed: () => Navigator.pop(context),
    ),
    middle: Text(
      title,
      style: cupertinoNavTitleStyle,
    ),
  );
}

PreferredSizeWidget buildMaterialAppBar(String title) {
  return AppBar(
    surfaceTintColor: MyColors.greenLight1,
    shadowColor: MyColors.greenLight2,
    backgroundColor: MyColors.greenDark1,
    foregroundColor: Colors.white,
    shape: appBarShape,
    title: Text(title),
    titleTextStyle: materialNavTitleTextStyle,
    centerTitle: true,
  );
}


void showSnack(BuildContext context, String message, String msg) {
  final currentTime = DateTime.now();

  if (snackBarCount < maxSnackBarCount &&
      (lastSnackBarTime == null || currentTime.difference(lastSnackBarTime!).inSeconds > 2)) {

    if (Platform.isIOS) {
      showCupertinoSnackBar(context, message);
    } else {
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

void showMaterialCustomizedOptions(context, int index) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Provider.of<AuthProvider>(context).isDarkMode
                ? Colors.black
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
                    index,
                  );
                },
              ),
              ListTile(
                leading: Icon(
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
                  onTapDeleteRoom(context, rooms[index].id!);
                },
              ),
            ],
          ),
        ),
      );
    },
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

void showCupertinoCustomizedOptions(BuildContext context, int index) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text('Edit', textAlign: TextAlign.left,),
          onPressed: () {
            Navigator.pop(context);
            showCustomizedDialog(
              context,
              index,
            );
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Delete'),
          onPressed: () {
            onTapDeleteRoom(context, rooms[index].id!);
          },
        ),
      ],
    ),
  );
}

Future<void> deleteRoom(int roomId, BuildContext context) async {
  await deleteRoomAndDevices(roomId);
}

Future<void> onTapDeleteRoom(BuildContext context, int roomId) async {
  await deleteRoom(roomId, context);
  refreshUI(context);
  Navigator.pop(context);
}

Future<void> refreshUI(BuildContext context) async {
  final apartmentId = apartmentMap.first['ApartmentID'];
  await getRoomsByApartmentID(context, apartmentId);
  exportData();
}
void showCustomizedDialog(BuildContext context, int index) {
  Room updatedRoom = rooms[index];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Edit Room Name', style: TextStyle(color: MyColors.greenDark1)),
            content: SingleChildScrollView(
              child: RoomCustomizationContent(
                initialRoom: rooms[index],
                existingRooms: rooms,
                onChanged: (room) {
                  setStateDialog(() {
                    updatedRoom = room;
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel', style: TextStyle(color: MyColors.greenDark1)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: MyColors.greenDark1),
                onPressed: () {
                  updateRoom(
                    apartmentMap.first['ApartmentID'],
                    updatedRoom,
                    rooms[index].name,
                  ).then((_) => exportData()).then((_) {
                    getRoomsByApartmentID(context, apartmentMap.first['ApartmentID']);
                    Provider.of<AuthProvider>(context, listen: false).toggling('loading', false);
                    Navigator.pop(context);
                  });
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
    },
  );
}

Future<void> promptEnableLocation (BuildContext context, VoidCallback action) async{
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if(!serviceEnabled) {
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

class RoomCustomizationContent extends StatefulWidget {
  final Room initialRoom;
  final List<Room> existingRooms;
  final void Function(Room newRoom)? onChanged;

  const RoomCustomizationContent({
    super.key,
    required this.initialRoom,
    required this.existingRooms,
    this.onChanged,
  });

  @override
  State<RoomCustomizationContent> createState() => _RoomCustomizationContentState();
}

class _RoomCustomizationContentState extends State<RoomCustomizationContent> {
  late IconData? selectedIcon;
  late bool customizeRoomName;
  late String customName;
  IconData? customIcon;
  String? hintMessage;

  @override
  void initState() {
    super.initState();
    selectedIcon = widget.initialRoom.icon;
    customizeRoomName = !iconsRoomsClass.any((e) => e.icon == selectedIcon);
    customName = "";
    customIcon = IconData(0, fontFamily: "", fontPackage: "");
  }

  void notifyChange() {
    if (widget.onChanged != null) widget.onChanged!(newRoom);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<IconData>(
          value: customizeRoomName ? null : selectedIcon,
          menuMaxHeight: 200,
          icon: const Icon(Icons.arrow_downward, color: MyColors.greenDark1),
          style: const TextStyle(color: MyColors.greenDark1),
          underline: Container(height: 2, color: MyColors.greenDark1),
          onChanged: (IconData? newValue) {
            if (newValue != null) {
              setState(() {
                selectedIcon = newValue;
                Room room = iconsRoomsClass.firstWhere(
                      (room) => room.iconCodePoint == newValue.codePoint,
                  orElse: () => throw Exception('No room found'),
                );
                newRoom = Room(
                  name: room.name,
                  iconCodePoint: newValue.codePoint,
                  fontFamily: newValue.fontFamily,
                  fontPackage: newValue.fontPackage,
                );
                customizeRoomName = false;
                hintMessage = widget.existingRooms.any((r) => r.name == newRoom.name)
                    ? 'This room name is already in use!'
                    : null;
                notifyChange();
              });
            }
          },
          items: [
            ...iconsRoomsClass.map((roomIcon) {
              return DropdownMenuItem<IconData>(
                value: roomIcon.icon,
                child: Row(
                  children: [
                    Icon(roomIcon.icon, color: MyColors.oliveDark),
                    width10,
                    Text(roomIcon.name),
                  ],
                ),
              );
            }),
            DropdownMenuItem<IconData>(
              value: null,
              child: const Text("Other"),
              onTap: () {
                setState(() {
                  customizeRoomName = true;
                  selectedIcon = null;
                  hintMessage = null;
                  notifyChange();
                });
              },
            ),
          ],
        ),
        if (customizeRoomName) ...[
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: Text("Enter Room Name:")),
          TextFormField(
            initialValue: customName,
            decoration: const InputDecoration(
              hintText: "Custom Room Name",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MyColors.greenDark1),
              ),
            ),
            onChanged: (value) {
              setState(() {
                customName = value.trim();
                newRoom = Room(
                  name: customName,
                  iconCodePoint: selectedIcon?.codePoint ?? 0,
                  fontFamily: selectedIcon?.fontFamily,
                  fontPackage: selectedIcon?.fontPackage,
                );
                hintMessage = widget.existingRooms.any((r) => r.name == newRoom.name)
                    ? 'This room name is already in use!'
                    : null;
                notifyChange();
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("Pick Icon:"),
              const SizedBox(width: 10),
              if (customIcon != null) Icon(customIcon, color: MyColors.greenDark1),
              TextButton(
                onPressed: () async {
                  IconPickerIcon? pickedIcon = await showIconPicker(context);
                  if (pickedIcon != null) {
                    setState(() {
                      customIcon = pickedIcon.data;
                      selectedIcon = customIcon;
                      newRoom = Room(
                        name: customName,
                        iconCodePoint: selectedIcon!.codePoint,
                        fontFamily: selectedIcon!.fontFamily,
                        fontPackage: selectedIcon!.fontPackage,
                      );
                      hintMessage = widget.existingRooms.any((r) => r.icon == newRoom.icon)
                          ? 'This icon is already in use!'
                          : null;
                      notifyChange();
                    });
                  }
                },
                child: const Text("Choose Icon"),
              ),
            ],
          ),
        ],
        if (hintMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              hintMessage!,
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
      ],
    );
  }
}

/// A circular green check icon used to indicate download completion.
class DownloadCompleteIndicator extends StatelessWidget {
  const DownloadCompleteIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 50,
      backgroundColor: MyColors.greenDark1,
      child: Icon(
        Icons.done,
        color: Colors.white,
        size: 50,
      ),
    );
  }
}

/// A circular progress indicator with a percentage label in the center.
class DownloadProgressIndicator extends StatelessWidget {
  final double? circleDiameter;
  final double progress;
  final double progressFontSize;

  const DownloadProgressIndicator({super.key, required this.circleDiameter, required this.progress, required this.progressFontSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: circleDiameter,
          height: circleDiameter,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(
              MyColors.greenDark1,
            ),
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: progressFontSize,
            fontWeight: FontWeight.bold,
            color: MyColors.greenDark1,
          ),
        ),
      ],
    );
  }
}
