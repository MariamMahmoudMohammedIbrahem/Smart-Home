import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
/// *sign_in**
GoogleSignIn googleSignIn = GoogleSignIn();
Color currentColor = Colors.amber;
List<String> items = [];//retrieve from db
List<String> leds = ['switch1','switch2','switch3','switch4'];//couldn't know where should it be retrieved from
List switches = [false,false,false,false];//couldn't know where should it be retrieved from
List icons = [Icons.ac_unit,Icons.lightbulb_circle_outlined,Icons.charging_station, Icons.colorize];
bool rgb = false;
/// *add_devices**
bool saved = false;
final StreamController<bool> controller = StreamController<bool>();
String roomName = '';