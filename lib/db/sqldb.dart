import 'dart:async';

import 'package:sqflite/sqflite.dart';

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
    Database mydb = await openDatabase(
        databasePath, onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return mydb;
  }

  //version changed
  Future<void> _onUpgrade(Database db, int oldversion, int newversion) async {
    print("onUpgrade");
  }

  //JUST CALLED ONCE
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE "Table1"(
      'column1' TEXT NOT NULL UNIQUE,
      'column2' INTEGER NOT NULL,
      'column3' INTEGER NOT NULL,
      PRIMARY KEY ('column1')
    )
    ''');
}

  //check if the meter has previous stored data or not
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
  }

  //INSERT
  Future<int> insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  //UPDATE
  Future<int> updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  // delete database
  Future mydeleteDatabase() async {
    String databasePath = await getDatabasesPath();
    await deleteDatabase(databasePath);
  }
}