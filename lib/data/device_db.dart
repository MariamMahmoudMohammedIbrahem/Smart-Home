import '../commons.dart';

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
    getAllMacAddresses();
    return true;
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

Future<void> getAllMacAddresses() async {
  Database? myDb = await sqlDb.db;

  final List<Map<String, dynamic>> result = await myDb!.query(
    'Devices',
    columns: [
      'MacAddress'
    ],
  );

  macAddresses = result.map((row) => row['MacAddress'] as String).toList();
  deviceStatus = macAddresses.map((mac) {
    return DeviceStatus(macAddress: mac);
  }).toList();
}

Future<void> deleteDeviceByMacAddress(String macAddress) async {
  Database? myDb = await sqlDb.db;

  await myDb!.delete(
    'Devices',
    where: 'MacAddress = ?',
    whereArgs: [macAddress],
  );
}