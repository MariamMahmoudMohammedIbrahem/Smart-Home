import 'package:flutter/material.dart';

Color currentColor = Colors.amber;
List<String> items = ['living room', 'BedRoom', 'Kitchen', 'reception'];//retrieve from db
List<String> leds = ['switch1','switch2','switch3','switch4'];//couldn't know where should it be retrieved from
List switches = [false,false,false,false];//couldn't know where should it be retrieved from
List icons = [Icons.ac_unit,Icons.lightbulb_circle_outlined,Icons.charging_station, Icons.colorize];
bool rgb = false;