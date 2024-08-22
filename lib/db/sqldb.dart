import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants.dart';

class SqlDb {

  static Database? _db;

  Future <Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    }
    else {
      return _db;
    }
  }

  Future<Database> initialDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'GlowGrid.db');
    Database myDb = await openDatabase(
        path, onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return myDb;
  }

  //version changed
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("onUpgrade");
  }

  //JUST CALLED ONCE
  Future _onCreate(Database db, int version) async {
    /*await db.execute('''
      CREATE TABLE "led"(
        'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        'mac_address' TEXT NOT NULL UNIQUE,
        'device_type' TEXT NOT NULL,
        'device_location' TEXT NOT NULL,
        'wifi_ssid' TEXT NOT NULL,
        'wifi_password' TEXT NOT NULL
      )
    ''');*/

    ///updated database table
    await db.execute('''
      CREATE TABLE "Departments" (
        'DepartmentID' INTEGER PRIMARY KEY AUTOINCREMENT,
        'DepartmentName' VARCHAR(255) NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE "Rooms" (
        'RoomID' INTEGER PRIMARY KEY AUTOINCREMENT,
        'RoomName' VARCHAR(255) NOT NULL,
        'DepartmentID' INTEGER,
        FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
      )
    ''');

    await db.execute('''
      CREATE TABLE "Devices" (
        'DeviceID' INTEGER PRIMARY KEY AUTOINCREMENT,
        'DeviceName' VARCHAR(255) NOT NULL,
        'MacAddress' VARCHAR(17) NOT NULL UNIQUE,
        'WifiName' VARCHAR(255),
        'WifiPassword' VARCHAR(255),
        'RoomID' INTEGER,
        FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
      )
    ''');
}

  //INSERT
  Future insertData(String sql) async {
    Database? myDb = await db;
    var response = await myDb!.rawInsert(sql);
    return response;
  }

  //UPDATE
  Future<int> updateData(String sql) async {
    Database? myDb = await db;
    int response = await myDb!.rawUpdate(sql);
    return response;
  }

  // delete database
  Future deleteMyDatabase() async {
    String databasePath = await getDatabasesPath();
    await deleteDatabase(databasePath);
  }

  // Future<List<Map<String, dynamic>>> readData() async {
  //   loading = true;
  //   Database? myDb = await db;
  //   List<Map<String, dynamic>> databaseMap = await myDb!.rawQuery('''
  //     SELECT * FROM led
  //   ''');
  //   Map<String, dynamic> resultMap = {
  //     for (var item in databaseMap) item['mac_address'] as String: item['device_location']
  //   };
  //   print('resultMap$databaseMap');
  //   print('resultMap$resultMap');
  //   loading = false;
  //   items = resultMap;
  //   // values = items.values.toList();
  //   return databaseMap;
  // }

  ///*updated database functions**

  ///insert into departments

  Future<int> insertDepartment(String departmentName) async {
    Database? myDb = await db;
    return await myDb!.insert(
      'Departments',
      {'DepartmentName': departmentName},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ///insert into rooms
  Future<int> insertRoom(String roomName, int departmentID) async {
    Database? myDb = await db;

    // Check if the room already exists in the specified department
    final List<Map<String, dynamic>> result = await myDb!.query(
      'Rooms',
      where: 'RoomName = ? AND DepartmentID = ?',
      whereArgs: [roomName, departmentID],
      limit: 1,
    );

    if (result.isNotEmpty) {
      // Room exists, return the existing RoomID
      return result.first['RoomID'] as int;
    } else {
      // Room does not exist, insert it
      final int newRoomID = await myDb.insert(
        'Rooms',
        {
          'RoomName': roomName,
          'DepartmentID': departmentID,
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
    Database? myDb = await db;

    // Check if the device with the given MAC address already exists
    final List<Map<String, dynamic>> result = await myDb!.query(
      'Devices',
      where: 'MacAddress = ?',
      whereArgs: [macAddress],
      limit: 1,
    );

    if (result.isNotEmpty) {
      print('error result is not empty');
      // Device with this MAC address already exists
      return false;
    } else {
      // Insert the new device
      print('not error result inserting');
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


  ///retrieve devices in specific rooms
  Future<List<Map<String, dynamic>>> getDevicesInRoom(int roomID) async {
    Database? myDb = await db;
    return await myDb!.query('Devices', where: 'RoomID = ?', whereArgs: [roomID]);
  }

  ///retrieve departments and their rooms
  Future<List<Map<String, dynamic>>> getDepartmentsAndRooms() async {
    Database? myDb = await db;
    return await myDb!.rawQuery('''
    SELECT Departments.DepartmentID, Departments.DepartmentName, Rooms.RoomID, Rooms.RoomName
    FROM Departments
    JOIN Rooms ON Departments.DepartmentID = Rooms.DepartmentID;
  ''');
  }

  ///get rooms based on departmentID
  Future<void> getRoomsByDepartmentID(int departmentID) async {
    Database? myDb = await db;
    loading= true;
    print('loading  = $loading');
    // Query the Rooms table for entries with the given DepartmentID
    final List<Map<String, dynamic>> rooms = await myDb!.query(
      'Rooms',
      where: 'DepartmentID = ?',
      whereArgs: [departmentID],
    );
    roomIDs = rooms.map((room) => room['RoomID'] as int).toList();
    // Extract RoomName values from the result and return as a list of strings
    roomNames = rooms.map((room) => room['RoomName'] as String).toList();
    print('Room names: $roomNames');
    // loading = false;
  }

  ///retrieve device details for specific room
  Future<void> getDeviceDetailsByRoomID(int roomID) async {
    Database? myDb = await db;

    // Query the Devices table for DeviceType and MacAddress where RoomID matches
    deviceDetails = await myDb!.query(
      'Devices',
      columns: ['MacAddress'], // Select only DeviceType and MacAddress
      where: 'RoomID = ?', // Filter by RoomID
      whereArgs: [roomID], // RoomID value
    );
    macAddress = deviceDetails.first['MacAddress'];
    // selectedMacAddress = deviceDetails.first['MacAddress'];
    for (var device in deviceDetails) {
      // Check if the device with the same macAddress is already in deviceStatus
      bool exists = deviceStatus.any((d) => d['MacAddress'] == device['MacAddress']);

      if (!exists || deviceDetails.isEmpty) {
        // If not exists, add it with default data values
        deviceStatus.add({
          'MacAddress': device['MacAddress'],
          'sw1': 0,
          'sw2': 0,
          'sw3': 0,
        });
      }
    }

    print('Devices in Room $roomID: $deviceDetails');
  }

  ///retrieve all departments
  Future<void> getAllDepartments() async {
    Database? myDb = await db;
    departmentMap = await myDb!.query('Departments');
    print(departmentMap);
  }

  ///editing room info
  Future<void> updateRoomName(int departmentID, String newRoomName, String currentRoomName) async {
    Database? _db = await db;

    // Perform the update operation on the Rooms table
    final int count = await _db!.update(
      'Rooms',
      {'RoomName': newRoomName},
      where: 'DepartmentID = ? AND RoomName = ?',
      whereArgs: [departmentID, currentRoomName],
    );

    print('Number of rows updated: $count');
  }

  ///deleting room

  Future<void> deleteRoomsAndDevices(int roomID) async{
    Database? myDb = await db;

    // Delete rows from the Devices table where RoomID matches
    final int count = await myDb!.delete(
      'Devices',
      where: 'RoomID = ?', // Filter by RoomID
      whereArgs: [roomID], // Provide the RoomID value
    ).then((value) => myDb.delete('Rooms',where: 'RoomID = ?',whereArgs: [roomID],),);

    print('Number of rows deleted: $count');
    // return count;
  }


  Future<List<Map<String, dynamic>>> getAllRooms() async {
    Database? myDb = await db;
    return await myDb!.query('Rooms');
  }
  Future<void> getAllDevices() async {
    Database? myDb = await db;
    var listlst = await myDb!.query('Devices');
    print('lstlist $listlst');
  }
  Future<bool> searchDepartmentByName(String departmentName) async {
    Database? myDb = await db;
    final List<Map<String, dynamic>> result = await myDb!.query(
      'Departments',
      where: 'DepartmentName = ?',
      whereArgs: [departmentName],
      limit: 1, // Only need one result
    );

    // If the result is not empty, return the first match
    if (result.isNotEmpty) {
      return true;
    } else {
      return false; // No match found
    }
  }
/* Future<int> getDepartmentCount() async {
    Database? myDb = await db;
    final List<Map<String, dynamic>> result = await myDb!.rawQuery('SELECT COUNT(*) as count FROM Departments');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  */
///get room ID
// Future<void> getSpecificRoomID(String roomName, int departmentID)async{
//   Database? myDb = await db;
//   final List<Map<String, dynamic>> results = await myDb!.query(
//     'Rooms',
//     columns: ['RoomID'], // Select only RoomID
//     where: 'RoomName = ? AND DepartmentID = ?', // Filter by RoomName and DepartmentID
//     whereArgs: [roomName, departmentID], // Provide values for the placeholders
//   );
//   int roomID = results.first['RoomID'] as int;
//   print('results is $roomID');
//   await deleteRoomsAndDevices(roomID);
// }
}
