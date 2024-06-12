/*
import 'package:flutter/material.dart';

List<Task> items = [
  Task(name: 'item 1'),
  Task(name: 'item 2'),
  Task(name: 'item 3'),
];

class Todoey extends StatefulWidget {
  const Todoey({super.key});

  @override
  State<Todoey> createState() => _TodoeyState();
}

class _TodoeyState extends State<Todoey> {
  TextEditingController taskName = TextEditingController();
  String textDescription = '';
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: width * .9,
          height: height,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index].name),
                trailing: Checkbox(
                  value: items[index].isChecked,
                  onChanged: (value) {
                    items[index].toggle();
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Add New Task',
                          style: TextStyle(decoration: TextDecoration.none),
                        ),
                        TextFormField(
                          controller: taskName,
                          onChanged: (value){
                            setState(() {
                              textDescription = value;
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            //add to items list
                            setState(() {
                              items.add(Task(name: textDescription));
                            });
                          },
                          child: const Text(
                            'Add',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Task {
  final String name;
  bool isChecked;
  Task({required this.name, this.isChecked = false});
  void toggle() {
    isChecked = !isChecked;
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showOverlay = false;

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overlay Example'),
      ),
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: _toggleOverlay,
              child: Text('Show Overlay'),
            ),
          ),
          if (_showOverlay) ...[
            // Semi-transparent background
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleOverlay,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            // Overlay content
            Center(
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Overlay Screen'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _toggleOverlay,
                      child: Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}*/