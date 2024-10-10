import 'dart:async';
import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
    as qr_scan;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sqflite/sqflite.dart';

import '../constants.dart';
import '../db/functions.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late AnimationController _controller;
  late Animation<double> _animation;
  double _progressValue = 0.0;
  String _displayMessage = "Starting download...";
  Timer? _timer;
  int _timeElapsed = 0; // track how much time has passed

  // List of messages to display at different time intervals
  final List<Map<String, dynamic>> _messages = [
    {"time": 2, "message": "Preparing files..."},
    {"time": 5, "message": "Downloading..."},
    {"time": 8, "message": "Almost there..."},
    {"time": 10, "message": "Download complete!"}
  ];
  Future<void> scanQR(context) async {
    try {
      barcodeScanRes = await qr_scan.FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, qr_scan.ScanMode.QR);
      if (barcodeScanRes.isNotEmpty && barcodeScanRes != '-1') {
        _startProgress();
        setState(() {
          reformattingData = true;
        });
        // Parse the file name from the URL
        _startProgress();
        final fileName =
            barcodeScanRes.split('/').last.split('%2F').last.split('?').first;
        _startProgress();
        print('fileName$fileName');
        // Download the file
        final response = await http.get(Uri.parse(barcodeScanRes));
        _startProgress();
        final dir = await getApplicationDocumentsDirectory();
        _startProgress();
        final file = File('${dir.path}/$localFileName.json');
        _startProgress();
        // setState(() {
        //   filePath = file.path;
        // });
        file.writeAsBytesSync(response.bodyBytes);
        _startProgress();
        deleteSpecificFile(fileName).then((value) => {
              _startProgress(),
              deleteOldFiles().then((value) => {
                    _startProgress(),
                    readJsonFromFile('$localFileName.json', context),
                  })
            });
        _startProgress();
        print("File downloaded to: ${file.path}");
      }
    } on PlatformException {
      barcodeScanRes = 'TKeys.failed.translate(context)';
    }
    if (!mounted) return;
  }

  Future readJsonFromFile(String fileName, context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      if (!file.existsSync()) {
        throw Exception("JSON file does not exist.");
      }

      final jsonData = await file.readAsString();
      //delete table first
      sqlDb.deleteAllRoomsAndDevices().then(
          (value) => insertDataIntoDatabase(jsonDecode(jsonData), context));
      // return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error reading JSON file: $e");
    }
  }

  Future<void> insertDataIntoDatabase(
      Map<String, dynamic> jsonData, context) async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'GlowGrid.db'),
    );

    final db = await database;
    // Insert into the Users table
    List<dynamic> apartments = jsonData['Apartments'];
    for (var user in apartments) {
      await db.insert(
        'Apartments',
        user as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Insert into the Rooms table
    List<dynamic> rooms = jsonData['Rooms'];
    for (var room in rooms) {
      await db.insert(
        'Rooms',
        room as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Insert into the Devices table
    List<dynamic> devices = jsonData['Devices'];
    for (var device in devices) {
      await db.insert(
        'Devices',
        device as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    setState(() {
      reformattingData = false;
      // allDone = true;
    });
    sqlDb
        .getRoomsByApartmentID(context, apartmentMap.first['ApartmentID'])
        .then((value) {
      setState(() {
        Provider.of<AuthProvider>(context, listen: false)
            .toggling('loading', false);
      });
      Navigator.pop(context);
    });
    print("Data inserted successfully into the database.");
  }

  Future<void> deleteSpecificFile(String fileName) async {
    try {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('databases/');
      final ListResult result = await storageRef.listAll();

      for (var item in result.items) {
        if (item.name.contains(fileName)) {
          try {
            await item.delete();
            print("Deleted file: ${item.name}");
          } catch (e) {
            print("Error deleting file: ${item.name}. Error: $e");
          }
        } else {
          print(
              "File ${item.name} does not match the specified file name: $fileName");
        }
      }
    } catch (e) {
      print("Error deleting files: $e");
    }
  }

  void _startProgress() {
    // _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    setState(() {
      _timeElapsed++;
      _progressValue += 1 / 9; // Increase progress

      // Update message based on the time passed
      for (var entry in _messages) {
        if (_timeElapsed >= entry["time"]) {
          _displayMessage = entry["message"];
        }
      }

      // Stop timer when progress reaches 1 (100%)
      if (_progressValue >= 1.0) {
        _progressValue = 1.0;
        _timer?.cancel();
      }
      // else{
      //   _displayMessage = 'an error has occurred';
      // }
    });
    // });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 20.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: const Color(0xFF70AD61),
          shadowColor: const Color(0xFF609e51),
          backgroundColor: const Color(0xFF047424),
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          title: const Text(
            'QR Scanner',
          ),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        body: Center(
          child: _progressValue == 0.0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // QR Code with padding
                        Padding(
                          padding: const EdgeInsets.all(
                              50.0), // Extra padding around QR code
                          child: QrImageView(
                            data: '',
                            version: QrVersions.auto,
                            size: 200.0, // Kee
                            foregroundColor: isDarkMode?Colors.grey.shade400:Colors.black,
                          ),
                        ),

                        // Animated corners zooming in/out outside the QR code
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: CornerZoomPainter(_animation.value),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: width * .5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF047424),
                          foregroundColor:
                              isDarkMode ? Colors.grey[900] : Colors.white,
                        ),
                        onPressed: () {
                          scanQR(context);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.qr_code_scanner_rounded),
                            Text(
                              'scan QR code',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _progressValue,
                      strokeWidth: 8.0,
                      color: const Color(0xFF047424),
                    ),
                    const SizedBox(height: 20),
                    // Display the current message
                    Text(
                      _displayMessage,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047424),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Show percentage progress
                    Text(
                      '${(_progressValue * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF047424),
                      ),
                    ),
                  ],
                ),
        ));
  }
}

// Custom painter to create the zooming corner effect around the image
class CornerZoomPainter extends CustomPainter {
  final double animationPadding;

  CornerZoomPainter(this.animationPadding);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF047424)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0; // Fixed size of the corner lines

    // Adjust padding for the animation to push the corners outward
    final qrCodePadding = 30.0 + animationPadding;

    // Draw top-left corner
    canvas.drawLine(Offset(qrCodePadding, qrCodePadding),
        Offset(qrCodePadding + cornerLength, qrCodePadding), paint);
    canvas.drawLine(Offset(qrCodePadding, qrCodePadding),
        Offset(qrCodePadding, qrCodePadding + cornerLength), paint);

    // Draw top-right corner
    canvas.drawLine(
        Offset(size.width - qrCodePadding, qrCodePadding),
        Offset(size.width - qrCodePadding - cornerLength, qrCodePadding),
        paint);
    canvas.drawLine(
        Offset(size.width - qrCodePadding, qrCodePadding),
        Offset(size.width - qrCodePadding, qrCodePadding + cornerLength),
        paint);

    // Draw bottom-left corner
    canvas.drawLine(
        Offset(qrCodePadding, size.height - qrCodePadding),
        Offset(qrCodePadding + cornerLength, size.height - qrCodePadding),
        paint);
    canvas.drawLine(
        Offset(qrCodePadding, size.height - qrCodePadding),
        Offset(qrCodePadding, size.height - qrCodePadding - cornerLength),
        paint);

    // Draw bottom-right corner
    canvas.drawLine(
        Offset(size.width - qrCodePadding, size.height - qrCodePadding),
        Offset(size.width - qrCodePadding - cornerLength,
            size.height - qrCodePadding),
        paint);
    canvas.drawLine(
        Offset(size.width - qrCodePadding, size.height - qrCodePadding),
        Offset(size.width - qrCodePadding,
            size.height - qrCodePadding - cornerLength),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
