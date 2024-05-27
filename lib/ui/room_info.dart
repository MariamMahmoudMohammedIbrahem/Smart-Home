
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../constants.dart';

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
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.room,
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            iconSize: 30,
            color: Colors.pink.shade900,
            icon: const Icon(Icons.add_circle_sharp),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .07, vertical: 10),
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // number of items in each row
                    mainAxisSpacing: 30.0, // spacing between rows
                    crossAxisSpacing: 30.0, // spacing between columns
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            icons[index],
                            color: Colors.white,
                            size: 40,
                          ),
                          ///TODO: timer
                          Text(
                            leds[index],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'on/off',
                                style: TextStyle(color: Colors.white),
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
                                    if (index == leds.length - 1) {
                                      rgb = !rgb;
                                      _showColorPicker(context);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              /*if(rgb)...[
                Expanded(
                  child: HUEColorPicker(
                      pickerColor: currentColor, onColorChanged: changeColor),
                ),
              ],*/
            ],
          ),
        ),
      ),
    );
  }
  void _showColorPicker(BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 15.0),
          child: Wrap(
            children: <Widget>[
              // HUEColorPicker(pickerColor: currentColor, onColorChanged: changeColor),
              HueRingPicker(pickerColor: currentColor, onColorChanged: changeColor),
              Center(child: ElevatedButton(onPressed: (){Navigator.pop(context);}, child: const Text('Save',),)),
            ],
          ),
        );
      },
    );
    /*showModalBottomSheet(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 15.0),
          child: Wrap(
            children: <Widget>[
              // HUEColorPicker(pickerColor: currentColor, onColorChanged: changeColor),
              HueRingPicker(pickerColor: currentColor, onColorChanged: changeColor),
              Center(child: ElevatedButton(onPressed: (){Navigator.pop(context);}, child: const Text('Save',),)),
            ],
          ),
        );
      },
    );*/
  }
  @override
  void initState() {
    //read status
    //read rgb
    //create list switches
    // Hexadecimal color value
    saved = false;
    super.initState();
  }
}
