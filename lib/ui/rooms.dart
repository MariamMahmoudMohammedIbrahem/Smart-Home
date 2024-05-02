import 'package:flutter/material.dart';
import 'package:mega/udp.dart';
import 'package:mega/ui/room_info.dart';

import '../constants.dart';

class Rooms extends StatefulWidget {
  const Rooms({super.key});

  @override
  State<Rooms> createState() => _RoomsState();
}

class _RoomsState extends State<Rooms> {
  @override
  Widget build(BuildContext context) {
    Color getForegroundColor(Set<MaterialState>states){
      if(states.contains(MaterialState.focused)) return Colors.pink.shade600;
      if(states.contains(MaterialState.pressed)) return Colors.pink.shade400;
      return Colors.pink.shade800;
    }
    Color getBackgroundColor(Set<MaterialState>states){
      if(states.contains(MaterialState.focused)) return Colors.pink.shade700;
      if(states.contains(MaterialState.pressed)) return Colors.pink;
      return Colors.pink.shade900;
    }
    BorderSide getBorderSide(Set<MaterialState>states){
      final color = getForegroundColor(states);
      return BorderSide(width: 3, color: color);
    }
    final foregroundColor = MaterialStateProperty.resolveWith<Color>((states) => getForegroundColor(states));
    final backgroundColor = MaterialStateProperty.resolveWith<Color>((states) => getBackgroundColor(states));
    final side = MaterialStateProperty.resolveWith<BorderSide>((states) => getBorderSide(states));
    final style = ButtonStyle(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home',),
        titleTextStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold,color:Colors.black,),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.menu_open_outlined))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width*.05, vertical: 10),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.pink.shade900,
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              child: const Placeholder(color: Colors.white,),
            ),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Divider(
                height: 1,
                color: Colors.pink,
                thickness: 1,
                indent : 10,
                endIndent : 10,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rooms',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24,),
                ),
                IconButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const UDPScreen()));
                },iconSize: 30, icon: const Icon(Icons.add_circle_sharp))
              ],
            ),
            Flexible(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // number of items in each row
                  mainAxisSpacing: 15.0, // spacing between rows
                  crossAxisSpacing: 15.0, // spacing between columns
                ),
                padding: const EdgeInsets.all(8.0), // padding around the grid
                itemCount: items.length, // total number of items
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    style: style.copyWith(side: side),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> RoomDetail(room: items[index]),),);
                    },
                    onLongPress: () {
                      _showOptions(context, items[index]);
                    },
                    child: Center(
                      child: Text(
                        items[index],
                        style: const TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
  void _showOptions(BuildContext context, String room) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Text(room, style: const TextStyle(fontWeight: FontWeight.bold),),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                // edit name "based on db"
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                // delete container "based on  database"
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}