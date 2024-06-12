import 'dart:async';
import 'package:path/path.dart';
import 'package:mega/todoey.dart';
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
    Database mydb = await openDatabase(
        path, onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return mydb;
  }

  //version changed
  Future<void> _onUpgrade(Database db, int oldversion, int newversion) async {
    print("onUpgrade");
  }

  //JUST CALLED ONCE
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE "led"(
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'mac_address' TEXT NOT NULL UNIQUE,
      'device_type' TEXT NOT NULL,
      'device_location' TEXT NOT NULL,
      'wifi_ssid' TEXT NOT NULL,
      'wifi_password' TEXT NOT NULL
    )
    ''');
}

  /*//check if the meter has previous stored data or not
  Future<bool> isTableEmpty(String type, String name) async {
    Database? mydb = await db;
      String query = 'SELECT COUNT(*) FROM Electricity WHERE `title` =?';
      String query2 = '''
      SELECT `time` FROM Electricity
      WHERE `title` = ?
      ORDER BY `id` DESC
      LIMIT 1
    ''';

    final count = Sqflite.firstIntValue(
      await mydb!.rawQuery(query,[name]),
    );
    if(count != 0){
      final response = await mydb!.rawQuery(query2,
        [name],);
      for(var map in response){
        var time = map['time'].toString();
      }
    }
    print("count $count");
    return count == 0;
  }

  // retrieve the last time stored in the database
  Future<List<Map>> readTime(String name, String type) async{
    Database? mydb = await db;
      String query = '''
      SELECT `time` FROM Electricity 
      WHERE `title` = ?
      ORDER BY `id` DESC 
      LIMIT 1 
    ''';
    final response = await mydb!.rawQuery(query,
      [name],);
    for(var map in response){
      var time = map['time'].toString();
    }
    return response;
  }*/

  //INSERT
  Future insertData(String sql) async {
    Database? mydb = await db;
    var response = await mydb!.rawInsert(sql);
    return response;
  }

  //UPDATE
  Future<int> updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  // delete database
  Future deleteMyDatabase() async {
    String databasePath = await getDatabasesPath();
    await deleteDatabase(databasePath);
  }

  Future<List<Map<String, dynamic>>> readData() async {
    print('hello world');
    Database? mydb = await db;
    List<Map<String, dynamic>> databaseMap = await mydb!.rawQuery('''
      SELECT * FROM led
    ''');
    Map<String, dynamic> resultMap = {
      for (var item in databaseMap) item['mac_address'] as String: item['device_location']
    };
    print('resultMap$databaseMap');
    print('resultMap$resultMap');
    items = resultMap;
    values = items.values.toList();
    return databaseMap;
  }
}