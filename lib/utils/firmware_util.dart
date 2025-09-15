import '../commons.dart';

///*check firmware version in firebase storage**
Future<String?> checkFirmwareVersion(
    String folderPath, String fileName, BuildContext context) async {
  try {
    // Reference to the file in Firebase Storage (nested folder structure)
    Reference storageRef =
    FirebaseStorage.instance.ref().child('$folderPath/$fileName');
    // Download the file content as raw bytes (limit to 1 MB)

    final fileData = await storageRef.getData(1024 * 1024);
    if (fileData != null) {
      // Convert file data from bytes to string
      final fileContent = utf8.decode(fileData);

      if(context.mounted) {
        if (Provider
            .of<AuthProvider>(context, listen: false)
            .firmwareInfo != fileContent) {
          Provider
              .of<AuthProvider>(context, listen: false)
              .updateFirmwareVersion(
              utf8.decode(fileData));
          return utf8.decode(fileData);
        }
      }
    }
  } catch (e) {
    throw Exception("Failed to retrieve the firmware info file from the firebase storage $e");
  }
  return null;
}

///*compare last version in devices with the version in the storage**
void checkAllFirmwareUpdates(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final firmwareInfo = authProvider.firmwareInfo;

  if (firmwareInfo == null) {
    return;
  }

  bool shouldShowBadge = macVersion.any(
        (device) => device['firmware_version'] != firmwareInfo,
  );

  Future.microtask(() {
    authProvider.toggling('notification', shouldShowBadge);
  });
}
