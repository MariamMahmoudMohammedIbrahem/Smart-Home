import '../commons.dart';

class Room {
  final int? id;
  final String name;
  final int iconCodePoint;
  final String? fontFamily;
  final String? fontPackage;

  Room({
    this.id,
    required this.name,
    required this.iconCodePoint,
    required this.fontFamily,
    this.fontPackage,
  });

  Map<String, dynamic> toMap() => {
    'RoomID': id,
    'RoomName': name,
    'IconCodePoint': iconCodePoint,
    'FontFamily': fontFamily,
    'FontPackage': fontPackage ?? "",
  };

  factory Room.fromMap(Map<String, dynamic> map) => Room(
    id: map['RoomID'],
    name: map['RoomName'],
    iconCodePoint: map['IconCodePoint'],
    fontFamily: map['FontFamily'],
    fontPackage: (map['FontPackage'] as String).isEmpty ? null : map['FontPackage'],
  );

  IconData get icon => IconData(iconCodePoint, fontPackage: fontPackage, fontFamily: fontFamily);
}
