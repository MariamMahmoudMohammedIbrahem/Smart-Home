import '../commons.dart';

///insert into Apartments
Future<int> insertApartment(String apartmentName) async {
  Database? myDb = await sqlDb.db;
  return await myDb!.insert(
    'Apartments',
    {'ApartmentName': apartmentName},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

///insert into rooms
Future<int> insertRoom(String roomName, int apartmentID) async {
  Database? myDb = await sqlDb.db;

  final List<Map<String, dynamic>> result = await myDb!.query(
    'Rooms',
    where: 'RoomName = ? AND ApartmentID = ?',
    whereArgs: [roomName, apartmentID],
    limit: 1,
  );

  if (result.isNotEmpty) {
    return result.first['RoomID'] as int;
  } else {
    final int newRoomID = await myDb.insert(
      'Rooms',
      {
        'RoomName': roomName,
        'ApartmentID': apartmentID,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return newRoomID;
  }
}

///insert into devices
Future<bool> insertDevice(
    String macAddress,
    String wifiName,
    String wifiPassword,
    String deviceType,
    int roomID,
    ) async {
  Database? myDb = await sqlDb.db;

  final List<Map<String, dynamic>> result = await myDb!.query(
    'Devices',
    where: 'MacAddress = ?',
    whereArgs: [macAddress],
    limit: 1,
  );

  if (result.isNotEmpty) {
    return false;
  } else {
    await myDb.insert(
      'Devices',
      {
        'MacAddress': macAddress,
        'DeviceName': deviceType,
        'WifiName': wifiName,
        'WifiPassword': wifiPassword,
        'RoomID': roomID,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }
}

///get rooms based on ApartmentID
Future<void> getRoomsByApartmentID(BuildContext context, int apartmentID) async {
  Database? myDb = await sqlDb.db;

  // Use context before the async operation to avoid crossing async gaps
  if(context.mounted) {
    Provider.of<AuthProvider>(context, listen: false).toggling(
        'loading', true);
  }

  final List<Map<String, dynamic>> rooms = await myDb!.query(
    'Rooms',
    where: 'ApartmentID = ?',
    whereArgs: [apartmentID],
  );

  roomIDs = rooms.map((room) => room['RoomID'] as int).toList();
  roomNames = rooms.map((room) => room['RoomName'] as String).toList();

  // Check if the widget is still mounted before using context again
  if (context.mounted) {
    Provider.of<AuthProvider>(context, listen: false).toggling('loading', false);
  }
}


///retrieve device details for specific room
Future<List<Map<String, dynamic>>> getDeviceDetailsByRoomID(
    int roomID) async {
  Database? myDb = await sqlDb.db;

  deviceDetails = await myDb!.query(
    'Devices',
    columns: ['MacAddress'],
    where: 'RoomID = ?',
    whereArgs: [roomID],
  );
  macAddress = deviceDetails.first['MacAddress'];
  for (var device in deviceDetails) {
    bool exists =
    deviceStatus.any((d) => d['MacAddress'] == device['MacAddress']);

    if (!exists || deviceDetails.isEmpty) {
      deviceStatus.add({
        'MacAddress': device['MacAddress'],
        'sw1': 0,
        'sw2': 0,
        'sw3': 0,
        'led': 0,
        'CurrentColor': 0xffffff,
      });
    }
  }
  return deviceDetails;
}

Future<List<Map<String, dynamic>>> getDevices(
    List<int> roomIDs) async {
  Database? myDb = await sqlDb.db;

  String whereClause = 'RoomID IN (${List.filled(roomIDs.length, '?').join(', ')})';

  List<Map<String, dynamic>> devices = await myDb!.query(
    'Devices',
    columns: ['MacAddress', 'RoomID'],
    where: whereClause,
    whereArgs: roomIDs,
  );
  return devices;
}
///retrieve all Apartments
Future<void> getAllApartments() async {
  Database? myDb = await sqlDb.db;
  apartmentMap = await myDb!.query('Apartments');
}

Future<void> getAllMacAddresses() async {
  Database? myDb = await sqlDb.db;

  final List<Map<String, dynamic>> result = await myDb!.query(
    'Devices',
    columns: [
      'MacAddress'
    ],
  );

  macMap = result.map((row) => row['MacAddress'] as String).toList();
}

///editing room info
Future<void> updateRoomName(
    int apartmentID, String newRoomName, String currentRoomName) async {
  Database? myDb = await sqlDb.db;

  await myDb!.update(
    'Rooms',
    {'RoomName': newRoomName},
    where: 'ApartmentID = ? AND RoomName = ?',
    whereArgs: [apartmentID, currentRoomName],
  );

}

///deleting room

Future<void> deleteRoomAndDevices(int roomID) async {
  Database? myDb = await sqlDb.db;

  await myDb!.delete(
    'Devices',
    where: 'RoomID = ?',
    whereArgs: [roomID],
  ).then(
        (value) => myDb.delete(
      'Rooms',
      where: 'RoomID = ?',
      whereArgs: [roomID],
    ),
  );

}

Future<List<Map<String, dynamic>>> getDataFromTable(String tableName) async {
  final database = openDatabase(
    join(await getDatabasesPath(), 'GlowGrid.db'),
  );
  final db = await database;
  return await db.query(tableName);
}

Future<void> exportData() async {
  try {

    final apartmentsData = await getDataFromTable('Apartments');
    final roomsData = await getDataFromTable('Rooms');
    final devicesData = await getDataFromTable('Devices');

    final Map<String, dynamic> allData = {
      'Apartments': apartmentsData,
      'Rooms': roomsData,
      'Devices': devicesData,
    };

    final jsonData = convertDataToJson(allData);

    await saveJsonToFile(jsonData);

  } catch (e) {
    throw Exception("Error happened while exporting the data $e");
  }
}

Future<void> deleteDeviceByMacAddress(String macAddress) async {
  Database? myDb = await sqlDb.db;

  await myDb!.delete(
    'Devices',
    where: 'MacAddress = ?',
    whereArgs: [macAddress],
  );
}

Future<void> deleteAllRoomsAndDevices() async {
  Database? myDb = await sqlDb.db;

  await myDb!
      .delete(
    'Devices',
  )
      .then(
        (value) => myDb.delete(
      'Rooms',
    ),
  );

}
