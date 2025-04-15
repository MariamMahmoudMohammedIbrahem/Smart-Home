import '../commons.dart';

///*sqldb.dart**
String convertDataToJson(Map<String, dynamic> data) {
  return jsonEncode(data);
}

Future<void> saveJsonToFile(String jsonData) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$localFileName.json');
  await file.writeAsString(jsonData);
}

///*delete file from firebase storage when finish using it**
Future<void> deleteSpecificFile(String fileName) async {
  try {
    final Reference storageRef =
    FirebaseStorage.instance.ref().child('databases/');
    final ListResult result = await storageRef.listAll();

    for (var item in result.items) {
      if (item.name.contains(fileName)) {
        try {
          await item.delete();
        } catch (e) {throw Exception("Failed to delete the file $e");}
      }
    }
  } catch (e) {throw Exception("Failed to get the files from the firebase storage $e");}
}

///*get the data that wil be uploaded to the firebase storage from the app's local database**
Future<File?> getLocalDatabaseFile() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final dbFile = File('${directory.path}/$localFileName.json');
    if (await dbFile.exists()) {
      return dbFile;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

///*import_data_screen.dart**
Future<void> deleteOldFiles() async {
  try {
    final Reference storageRef =
    FirebaseStorage.instance.ref().child('databases/');
    final ListResult result = await storageRef.listAll();
    final now = DateTime.now().millisecondsSinceEpoch;
    const oneHourInMs = 60 * 60;

    for (var item in result.items) {
      final metadata = await item.getMetadata();
      final uploadTimeStr = metadata.customMetadata?['uploadTime'];

      if (uploadTimeStr != null) {
        try {
          final uploadTime =
              DateTime.parse(uploadTimeStr).millisecondsSinceEpoch;

          if (now - uploadTime > oneHourInMs) {
            print("now$now, upload time $uploadTime");
            await item.delete();
          }
        } catch (e) {throw Exception("Failed to delete the old files $e");}
      }
    }
  } catch (e) {throw Exception("Failed to get the files from the firebase storage $e");}
}