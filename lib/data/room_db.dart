import '../commons.dart';

///insert into rooms
Future<int> insertRoom(Room room, int apartmentID) async {
  Database? myDb = await sqlDb.db;

  final List<Map<String, dynamic>> result = await myDb!.query(
    'Rooms',
    where: 'RoomName = ? AND ApartmentID = ?',
    whereArgs: [room.name, apartmentID],
    limit: 1,
  );
  print("result: $result");

  if (result.isNotEmpty) {
    return result.first['RoomID'] as int;
  } else {
    final int newRoomID = await myDb.insert(
      'Rooms',
      {
        'RoomName': room.name,
        'IconCodePoint': room.iconCodePoint,
        'FontFamily': room.fontFamily,
        'FontPackage': room.fontPackage ?? '', // Store empty string if null
        'ApartmentID': apartmentID,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return newRoomID;
  }
}

// Future<int> insertRoom(Room room, int apartmentID) async {
//   Database? myDb = await sqlDb.db;
//
//   final List<Map<String, dynamic>> result = await myDb!.query(
//     'Rooms',
//     where: 'RoomName = ? AND ApartmentID = ?',
//     whereArgs: [room.name, apartmentID],
//     limit: 1,
//   );
//   print("result: $result");
//
//   if (result.isNotEmpty) {
//     return result.first['RoomID'] as int;
//   } else {
//     final int newRoomID = await myDb.insert(
//       'Rooms',
//       {
//         'RoomName': room.name,
//         'IconCodePoint': room.iconCodePoint,
//         'FontFamily': room.fontFamily,
//         'FontPackage': room.fontPackage ?? '',
//         'ApartmentID': apartmentID,
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//     return newRoomID;
//   }
// }

/*
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
*/

///get rooms based on ApartmentID
Future<List<Room>> getRoomsByApartmentID(BuildContext context, int apartmentID) async {
  Database? myDb = await sqlDb.db;

  if (context.mounted) {
    Provider.of<AuthProvider>(context, listen: false).toggling('loading', true);
  }

  final List<Map<String, dynamic>> roomMaps = await myDb!.query(
    'Rooms',
    where: 'ApartmentID = ?',
    whereArgs: [apartmentID],
  );

  print("roomMaps $roomMaps");
  rooms = roomMaps.map((map) => Room.fromMap(map)).toList();
  // iconsRoomsClass.addAll(rooms.map((room) => room));
  iconsRoomsClass.addAll(
      rooms.where((room) => !iconsRoomsClass.any((existingRoom) => existingRoom.name == room.name))
  );
  print("rooms $rooms");
  print("rooms icons ${iconsRoomsClass.length}");

  if (context.mounted) {
    Provider.of<AuthProvider>(context, listen: false).toggling('loading', false);
  }

  return rooms;
}

/*
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
*/

///editing room info
Future<void> updateRoom(int apartmentID, Room updatedRoom, String currentRoomName) async {
  Database? myDb = await sqlDb.db;

  await myDb!.update(
    'Rooms',
    {
      'RoomName': updatedRoom.name,
      'IconCodePoint': updatedRoom.iconCodePoint,
      'FontFamily': updatedRoom.fontFamily,
      'FontPackage': updatedRoom.fontPackage??"",
    },
    where: 'ApartmentID = ? AND RoomName = ?',
    whereArgs: [apartmentID, currentRoomName],
  );
}


/*Future<void> updateRoomName(
    int apartmentID, String newRoomName, String currentRoomName) async {
  Database? myDb = await sqlDb.db;

  await myDb!.update(
    'Rooms',
    {'RoomName': newRoomName},
    where: 'ApartmentID = ? AND RoomName = ?',
    whereArgs: [apartmentID, currentRoomName],
  );

}*/

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
