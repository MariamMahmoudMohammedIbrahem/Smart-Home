import '../commons.dart';

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