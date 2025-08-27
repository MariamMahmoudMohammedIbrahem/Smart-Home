import '../commons.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

///*multiple usage**
SqlDb sqlDb = SqlDb();
List<Map<String, dynamic>> apartmentMap = [];
List<String> macAddresses = [];
Color currentColor = MyColors.greenDark2;
Color tempColor = currentColor;
List<Room> rooms = [];
List<Map<String, dynamic>> deviceDetails = []; // for each room "updated when entering the room screen"
List<DeviceStatus> deviceStatus = [];
String macAddress = '';
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
IconData selectedIcon = Icons.living;
List<Map<String,dynamic>> macVersion = [];
List<WifiNetwork?> wifiNetworks = [];
String localFileName = '';
String ip = "255.255.255.255";
int port = 8888;
double progressValue = 0.0;
bool errorOccurred = false;

final key = encrypt.Key.fromUtf8('16charSecretKey!'); // must be exactly 16 chars for AES-128
final encrypter = encrypt.Encrypter(encrypt.AES(key));
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

String baseURL = "https://firebasestorage.googleapis.com/v0/b/smart-home-aae4e.appspot.com/o/databases%2F";