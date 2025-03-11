
import '../commons.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

  Future<Database> initialDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'GlowGrid.db');
    Database myDb = await openDatabase(path,
        onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return myDb;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  }

  Future _onCreate(Database db, int version) async {
    ///updated database table
    await db.execute('''
      CREATE TABLE "Apartments" (
        'ApartmentID' INTEGER PRIMARY KEY AUTOINCREMENT,
        'ApartmentName' VARCHAR(255) NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE "Rooms" (
        'RoomID' INTEGER PRIMARY KEY AUTOINCREMENT,
        'RoomName' VARCHAR(255) UNIQUE NOT NULL,
        'ApartmentID' INTEGER,
        FOREIGN KEY (ApartmentID) REFERENCES Apartments(ApartmentID)
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

}