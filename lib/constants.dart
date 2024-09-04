
import 'dart:math';

import 'package:flutter/material.dart';

import 'db/sqldb.dart';
SqlDb sqlDb = SqlDb();
var random = Random();
int min = 49152;
int max = 65535;
List<Map<String, dynamic>> departmentMap = [];
var macMap = [];
bool eye = false;
Color currentColor = Colors.amber;
///items list of all macAddress
List<String> roomNames = [];
List<int>  roomIDs = [];
List<Map<String, dynamic>> deviceDetails = [];
List<Map<String, dynamic>> deviceStatus = [];
String macAddress = '';
/// *add_devices**
bool saved = false;
String roomName = 'Living Room';
///*udp.dart**
String name = '';
String password = '';
final formKey = GlobalKey<FormState>();
final TextEditingController nameController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
var commandResponse = '';
List<IconData> iconsRooms = [
  Icons.living,
  Icons.bedroom_baby,
  Icons.bedroom_parent,
  Icons.kitchen,
  Icons.bathroom,
  Icons.dining,
  Icons.desk,
  Icons.local_laundry_service,
  Icons.garage,
  Icons.camera_outdoor,
];
IconData selectedIcon = Icons.living;