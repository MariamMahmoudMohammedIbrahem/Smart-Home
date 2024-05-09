
import 'package:flutter/material.dart';

import '../constants.dart';
import 'color_picker.dart';

class RoomDetail extends StatefulWidget {
  final String room;

  const RoomDetail({super.key, required this.room});

  @override
  State<RoomDetail> createState() => _RoomDetailState();
}

class _RoomDetailState extends State<RoomDetail> {
  void changeColor(Color color) => setState(() => currentColor = color);
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.room,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width*.05,vertical: 10),
        child: Column(
          children: [
            /*SizedBox(
              width: width*.8,
              height:200,
              child: Icon(Icons.lightbulb, color: rgb?Colors.pink:Colors.grey),
            ),*/
            Flexible(
              child: HUEColorPicker(
                pickerColor: currentColor,
                onColorChanged: changeColor,
              ),
            ),
            Flexible(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // number of items in each row
                  mainAxisSpacing: 15.0, // spacing between rows
                  crossAxisSpacing: 15.0, // spacing between columns
                ),
                itemCount: leds.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.pink.shade900,
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              icons[index],
                            ),
                            Switch(
                              activeColor: Colors.pink.shade300,
                              activeTrackColor: Colors.pink.shade100,
                              inactiveThumbColor: Colors.grey.shade600,
                              inactiveTrackColor: Colors.grey.shade400,
                              splashRadius: 50.0,
                              value: switches[index],
                              onChanged: (value) {
                                //send packet
                                setState(() {
                                  switches[index] = !switches[index];
                                  if(index == leds.length-1 ){
                                    rgb = !rgb;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        Text(
                          leds[index],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void initState(){
    //read status
    //read rgb
    //create list switches
    // Hexadecimal color value
    saved = false;
    super.initState();
  }
}