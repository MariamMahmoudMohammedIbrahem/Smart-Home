import '../commons.dart';

///*multiple usage**
SqlDb sqlDb = SqlDb();
List<Map<String, dynamic>> apartmentMap = [];
List<String> macAddresses = [];
Color currentColor = MyColors.greenDark2;
Color tempColor = currentColor;
List<Room> rooms = [];
// List<String> roomNames = [];
// List<int>  roomIDs = [];
List<Map<String, dynamic>> deviceDetails = [];
List<DeviceStatus> deviceStatus = [];
String macAddress = '';
// String roomName = 'Living Room';
Room newRoom = Room(name: "", iconCodePoint: 0, fontFamily: '');
List<Room> iconsRoomsClass = [
  Room(name: "Living Room",
      iconCodePoint: Icons.living.codePoint,
      fontFamily: Icons.living.fontFamily,
      fontPackage: Icons.living.fontPackage),
  Room(name: "Baby Bedroom",
      iconCodePoint: Icons.bedroom_baby.codePoint,
      fontFamily: Icons.bedroom_baby.fontFamily,
      fontPackage: Icons.bedroom_baby.fontPackage),
  Room(name: "Parent Bedroom",
      iconCodePoint: Icons.bedroom_parent.codePoint,
      fontFamily: Icons.bedroom_parent.fontFamily,
      fontPackage: Icons.bedroom_parent.fontPackage),
  Room(name: "Kitchen",
      iconCodePoint: Icons.kitchen.codePoint,
      fontFamily: Icons.kitchen.fontFamily,
      fontPackage: Icons.kitchen.fontPackage),
  Room(name: "Bathroom",
      iconCodePoint: Icons.bathroom.codePoint,
      fontFamily: Icons.bathroom.fontFamily,
      fontPackage: Icons.bathroom.fontPackage),
  Room(name: "Dining Room",
      iconCodePoint: Icons.dining.codePoint,
      fontFamily: Icons.dining.fontFamily,
      fontPackage: Icons.dining.fontPackage),
  Room(name: "Desk",
      iconCodePoint: Icons.desk.codePoint,
      fontFamily: Icons.desk.fontFamily,
      fontPackage: Icons.desk.fontPackage),
  Room(name: "Laundry Room",
      iconCodePoint: Icons.local_laundry_service.codePoint,
      fontFamily: Icons.local_laundry_service.fontFamily,
      fontPackage: Icons.local_laundry_service.fontPackage),
  Room(name: "Garage",
      iconCodePoint: Icons.garage.codePoint,
      fontFamily: Icons.garage.fontFamily,
      fontPackage: Icons.garage.fontPackage),
  Room(name: "Outdoor",
      iconCodePoint: Icons.camera_outdoor.codePoint,
      fontFamily: Icons.camera_outdoor.fontFamily,
      fontPackage: Icons.camera_outdoor.fontPackage),
];
// List<IconData> iconsRooms = [
//   Icons.living,
//   Icons.bedroom_baby,
//   Icons.bedroom_parent,
//   Icons.kitchen,
//   Icons.bathroom,
//   Icons.dining,
//   Icons.desk,
//   Icons.local_laundry_service,
//   Icons.garage,
//   Icons.camera_outdoor,
// ];
IconData selectedIcon = Icons.living;
// String barcodeScanRes = '';

///*device_configuration_screen.dart**
int currentStep = 0;
String name = '';
String password = '';
bool eye = true;
final formKey = GlobalKey<FormState>();
final TextEditingController nameController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
int snackBarCount = 0;
const int maxSnackBarCount = 3;
DateTime? lastSnackBarTime;
int pressCount = 0;

///*socket_manager.dart**
var commandResponse = '';
final List<Map<String, dynamic>> messages = [
  {"time": 2, "message": "Preparing files..."},
  {"time": 5, "message": "Downloading..."},
  {"time": 8, "message": "Almost there..."},
  {"time": 10, "message": "Download complete! \nYou are Ready to go."}
];
bool errorOccurred = false;
bool fileMissing = false;

///*import_data_screen.dart**
bool reformattingData = false;
String localFileName = '';
Timer? timer;

final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
late AnimationController controller;
late Animation<double> animation;
double progressValue = 0.0;
String displayMessage = "Starting download...";
// int timeElapsed = 0;

bool scanned = false;
///*room_details_screen.dart**
List ledInfo = ['light lamp', 'light lamp', 'RGB led', 'connection led'];
Timer? debounce;
Timer? debounceConfirm;

///*export_data_screen.dart**
bool uploadFailed = false;
String? uploadStatus;
String downloadURL = '';
int uploadSteps = 0;
double uploadProgress = 0.0;

///*firmware_updating_screen.dart**
List<Map<String,dynamic>> macVersion = [];
bool failed = false;
Timer? timerPeriodic;
bool waiting = false;

///*settings_screen.dart**
List<WifiNetwork?> wifiNetworks = [];

String ip = "255.255.255.255";
int port = 8888;

String baseURL = "https://firebasestorage.googleapis.com/v0/b/smart-home-aae4e.appspot.com/o/databases%2F";
bool customizeRoomName = false;