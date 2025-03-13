import '../commons.dart';

///retrieve all Apartments
Future<void> getAllApartments() async {
  Database? myDb = await sqlDb.db;
  apartmentMap = await myDb!.query('Apartments');
}

///insert into Apartments
Future<int> insertApartment(String apartmentName) async {
  Database? myDb = await sqlDb.db;
  return await myDb!.insert(
    'Apartments',
    {'ApartmentName': apartmentName},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}