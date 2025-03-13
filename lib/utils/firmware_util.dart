import '../commons.dart';

///*check firmware version in firebase storage**
Future<String?> checkFirmwareVersion(
    String folderPath, String fileName, BuildContext context) async {
  bool isConnected = await isConnectedToInternet();
  if(Provider.of<AuthProvider>(context, listen: false).isConnected != isConnected){
    Provider.of<AuthProvider>(context, listen: false).toggling('connecting', isConnected);
    if (!isConnected) {
      return '';
    }
  }
  try {
    // Reference to the file in Firebase Storage (nested folder structure)
    Reference storageRef =
    FirebaseStorage.instance.ref().child('$folderPath/$fileName');
    // Download the file content as raw bytes (limit to 1 MB)

    final fileData = await storageRef.getData(1024 * 1024);
    if (fileData != null) {
      // Convert file data from bytes to string
      final fileContent = utf8.decode(fileData);
      if(Provider.of<AuthProvider>(context, listen: false).firmwareInfo != fileContent) {
        Provider.of<AuthProvider>(context, listen: false).updateFirmwareVersion(
            utf8.decode(fileData));
        return utf8.decode(fileData);
      }
    }
  } catch (e) {throw Exception("Failed to retrieve the firmware info file from the firebase storage $e");}
  return null;
}

///*compare last version in devices with the version in the storage**
void checkFirmwareUpdates(List<Map<String, dynamic>> devices, String firmwareInfo, BuildContext context) {
  bool shouldToggleNotification = false;
  for (var device in devices) {
    if (device['firmware_version'] != firmwareInfo) {
      shouldToggleNotification = true;
      break;
    }
  }
  Provider.of<AuthProvider>(context, listen: false).toggling('notification', shouldToggleNotification);
}
