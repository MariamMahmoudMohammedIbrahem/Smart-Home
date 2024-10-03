import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:mega/db/functions.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
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
    /*if (oldVersion < 2) {
      await db.execute("ALTER TABLE Devices ADD COLUMN FirmwareVersion TEXT").then((value) => updateAllRowsWithNewValue);
    }*/
    print("onUpgrade");
  }

  //JUST CALLED ONCE
  Future _onCreate(Database db, int version) async {

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
        'FirmwareVersion' TEXT,
        'RoomID' INTEGER,
        FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
      )
    ''');
}
  Future<void> updateAllRowsWithNewValue() async {
    Database? _db = await db;

    await _db!.update(
      'Devices',
      {'FirmwareVersion': '0.13.9'},
    );
    print('updating.......');
  }

  Future<void> updateVersionByMacAddress(String macAddress, String newVersion) async {
    Database? myDb = await db;

    // Update the specified column for the device with the given MAC address
    await myDb!.update(
      'Devices',
      {'FirmwareVersion': newVersion},
      where: 'MacAddress = ?', // Condition to find the specific device
      whereArgs: [macAddress], // Argument for the condition
    );
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

  ///sharing database file from android to another
  Future<void> shareDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'GlowGrid.db');
    File dbFile = File(dbPath);

    if (await dbFile.exists()) {
      XFile xFile = XFile(dbFile.path);
      Share.shareXFiles([xFile], text: 'Here is the database file.');
    }
    else {
      print('Database file does not exist');
    }
  }

  ///replacing the already created database file with another one
  Future<void> replaceDatabase(File newDbFile) async {
    try {
      // Get the path to the database directory
      String databasesPath = await getDatabasesPath();

      // Specify the path to the current database file
      String dbPath = join(databasesPath, 'GlowGrid.db'); // Replace with your actual database name

      // Check if the new database file exists
      if (await newDbFile.exists()) {
        // Replace the old database file with the new one
        await newDbFile.copy(dbPath);
        print('Database replaced successfully.');
      } else {
        print('New database file does not exist.');
      }
    } catch (e) {
      print('Error replacing database: $e');
    }
  }

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
      String firmwareVersion,
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
          'FirmwareVersion': firmwareVersion,
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
  Future<void> getRoomsByDepartmentID(BuildContext context, int departmentID) async {
    Database? myDb = await db;
    Provider.of<AuthProvider>(context, listen: false).toggling('loading',true);
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
    Provider.of<AuthProvider>(context, listen: false).toggling('loading',false);
  }

  ///retrieve device details for specific room
  Future<List<Map<String, dynamic>>> getDeviceDetailsByRoomID(int roomID) async {
    Database? myDb = await db;

    // Query the Devices table for MacAddress where RoomID matches
    deviceDetails = await myDb!.query(
      'Devices',
      columns: ['MacAddress', 'FirmwareVersion'],
      where: 'RoomID = ?',
      whereArgs: [roomID],
    );
    macAddress = deviceDetails.first['MacAddress'];
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
          'led': 0,
        });
      }
    }
    print('Devices in Room $roomID: $deviceDetails');
    return deviceDetails;

  }

  ///retrieve all departments
  Future<void> getAllDepartments() async {
    Database? myDb = await db;
    departmentMap = await myDb!.query('Departments');
    print(departmentMap);
  }

  ///editing room info
  Future<void> updateRoomName(int departmentID, String newRoomName, String currentRoomName) async {
    Database? myDb = await db;

    // Perform the update operation on the Rooms table
    final int count = await myDb!.update(
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
      where: 'RoomID = ?',
      whereArgs: [roomID],
    ).then((value) => myDb.delete('Rooms',where: 'RoomID = ?',whereArgs: [roomID],),);

    print('Number of rows deleted: $count');
  }

  Future<bool> searchDepartmentByName(String departmentName) async {
    Database? myDb = await db;
    final List<Map<String, dynamic>> result = await myDb!.query(
      'Departments',
      where: 'DepartmentName = ?',
      whereArgs: [departmentName],
      limit: 1,
    );

    // If the result is not empty, return the first match
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
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
      /*setState(() {
        preparingData = true;
      });*/

      // Read data from multiple tables
      final departmentsData = await sqlDb.getDataFromTable('Departments');
      final roomsData = await sqlDb.getDataFromTable('Rooms');
      final devicesData = await sqlDb.getDataFromTable('Devices');

      // Combine data from multiple tables
      final Map<String, dynamic> allData = {
        'Departments': departmentsData,
        'Rooms': roomsData,
        'Devices': devicesData,
      };

      // Convert combined data to JSON
      final jsonData = convertDataToJson(allData);

      // Save JSON data to a file
      await saveJsonToFile(jsonData);

      // setState(() {
      //   _status = 'Data exported successfully!';
        /*preparingData = false;*/
      // });
    } catch (e) {
      // setState(() {
      //   _status = 'Error exporting data: $e';
      // });
    }
  }
}
