import '../commons.dart';

///*multiple usage**
SqlDb sqlDb = SqlDb();
List<Map<String, dynamic>> apartmentMap = [];
var macMap = [];
bool eye = true;
Color currentColor = MyColors.greenDark2;
Color tempColor = currentColor;
List<String> roomNames = [];
List<int>  roomIDs = [];
List<Map<String, dynamic>> deviceDetails = [];
List<Map<String, dynamic>> deviceStatus = [];
String macAddress = '';
String roomName = 'Living Room';
List<IconData> iconsRooms = [
  Icons.living,
  Icons.bedroom_baby,
  Icons.bedroom_parent,
  Icons.kitchen,
  Icons.bathroom,
  Icons.dining,
  Icons.desk,
  Icons.local_laundry_service,
  Icons.garage,
  Icons.camera_outdoor,
];
IconData selectedIcon = Icons.living;
String barcodeScanRes = '';

///*device_configuration_screen.dart**
int currentStep = 0;
String name = '';
String password = '';
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
  {"time": 10, "message": "Download complete!"}
];

///*import_data_screen.dart**
bool reformattingData = false;
String localFileName = '';
Timer? timer;

final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
late AnimationController controller;
late Animation<double> animation;
double progressValue = 0.0;
String displayMessage = "Starting download...";
int timeElapsed = 0;

///*room_details_screen.dart**
List ledInfo = ['light lamp', 'light lamp', 'RGB led', 'connection led'];
Timer? debounce;

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