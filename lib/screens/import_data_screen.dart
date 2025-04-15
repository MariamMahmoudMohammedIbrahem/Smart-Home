import 'dart:ui';

import '../commons.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart' as qr_scan;
import 'package:http/http.dart' as http;

class ImportDataScreen extends StatefulWidget {
  const ImportDataScreen({super.key});

  @override
  ImportDataScreenState createState() => ImportDataScreenState();
}

class ImportDataScreenState extends State<ImportDataScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          color: MyColors.greenDark1, // Set the back arrow color
          onPressed: () {
            Navigator.pop(context); // Pop to go back to the previous screen
          },
        ),
        middle: Text(
          'Import Data',
          style: TextStyle(
          color: MyColors.greenDark1,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      ),
        child: Center(
      child: progressValue == 0.0
          ? Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: QrImageView(
                  data: '',
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.black,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.black,
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CornerZoomPainter(animation.value),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            width: width * .5,
            child: CupertinoButton(
              // style: ElevatedButton.styleFrom(
                color: MyColors.greenDark1,
                // disabledColor: isDarkMode ? Colors.grey[900] : CupertinoColors.white,
              // ),
              onPressed: (){
                  scanQR(context);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: CupertinoColors.white,),
                  Text(
                    'scan QR code',
                    style: TextStyle(color:CupertinoColors.white,),
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
            value: progressValue,
            strokeWidth: 8.0,
            color: MyColors.greenDark1,
          ),
          height20,
          Text(
            displayMessage,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: MyColors.greenDark1,
            ),
          ),
          height10,
          Text(
            '${(progressValue * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 18.0,
              color: MyColors.greenDark1,
            ),
          ),
        ],
      ),
    ))
        : Scaffold(
        appBar: AppBar(
          surfaceTintColor: MyColors.greenLight1,
          shadowColor: MyColors.greenLight2,
          backgroundColor: MyColors.greenDark1,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          title: const Text(
            'Import Data',
          ),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        body: Center(
          child: progressValue == 0.0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(50.0),
                          child: QrImageView(
                            data: '',
                            version: QrVersions.auto,
                            size: 200.0,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.black,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.black,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: CornerZoomPainter(animation.value),
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
                          backgroundColor: MyColors.greenDark1,
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
                      value: progressValue,
                      strokeWidth: 8.0,
                      color: MyColors.greenDark1,
                    ),
                    height20,
                    Text(
                      displayMessage,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: MyColors.greenDark1,
                      ),
                    ),
                    height10,
                    Text(
                      '${(progressValue * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: MyColors.greenDark1,
                      ),
                    ),
                  ],
                ),
        ));
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 0.0, end: 20.0).animate(controller);
  }


  /*Future<void> scanQR(BuildContext context) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => QRScannerScreen(
        onDetect: (String barcodeScanRes) async {
          if (barcodeScanRes.isNotEmpty) {
            // 👇 Reconstruct full download URL from file name
            String fileName = Uri.encodeComponent(barcodeScanRes);
            String url = 'https://firebasestorage.googleapis.com/v0/b/YOUR_PROJECT_ID.appspot.com/o/databases%2F$fileName?alt=media';

            _startProgress();
            setState(() {
              reformattingData = true;
            });

            final response = await http.get(Uri.parse(url));
            final dir = await getApplicationDocumentsDirectory();
            final file = File('${dir.path}/$localFileName.json');
            file.writeAsBytesSync(response.bodyBytes);

            await deleteOldFiles();
            _startProgress();
            readJsonFromFile('$localFileName.json', context);
          }
        },
      ),
    ),
  );
}*/


  Future<void> scanQR(BuildContext context) async {
    if(Platform.isIOS){
      await Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => QRScannerScreen(
            onDetect: (String barcodeScanRes) async {
              if (barcodeScanRes.isNotEmpty) {

                print("barcodeScanRes $barcodeScanRes");
                _startProgress();
                setState(() {
                  reformattingData = true;
                });
                _startProgress();
                final response = await http.get(Uri.parse(barcodeScanRes));
                print("response $response");
                _startProgress();
                final dir = await getApplicationDocumentsDirectory();
                print("dir $dir");
                _startProgress();
                final file = File('${dir.path}/$localFileName.json');
                _startProgress();
                file.writeAsBytesSync(response.bodyBytes);
                _startProgress();
                deleteOldFiles().then((value) => {
                  _startProgress(),
                  readJsonFromFile('$localFileName.json', context),
                });
                _startProgress();
              }
            },
          ),
        ),
      ); }else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              QRScannerScreen(
                onDetect: (String barcodeScanRes) async {
                  if (barcodeScanRes.isNotEmpty) {
                    print("barcodeScanRes $barcodeScanRes");
                    _startProgress();
                    setState(() {
                      reformattingData = true;
                    });
                    _startProgress();
                    final response = await http.get(Uri.parse(barcodeScanRes));
                    print("response $response");
                    _startProgress();
                    final dir = await getApplicationDocumentsDirectory();
                    print("dir $dir");
                    _startProgress();
                    final file = File('${dir.path}/$localFileName.json');
                    _startProgress();
                    file.writeAsBytesSync(response.bodyBytes);
                    _startProgress();
                    deleteOldFiles().then((value) =>
                    {
                      _startProgress(),
                      readJsonFromFile('$localFileName.json', context),
                    });
                    _startProgress();
                  }
                },
              ),
        ),
      );
    }
  }

  Future readJsonFromFile(String fileName, BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      if (!file.existsSync()) {
        throw Exception("JSON file does not exist.");
      }

      final jsonData = await file.readAsString();
      deleteAllRoomsAndDevices().then((value) => {
            _startProgress(),
            insertDataIntoDatabase(jsonDecode(jsonData), context),
          });
    } catch (e) {
      throw Exception("Error reading JSON file: $e");
    }
  }

  Future<void> insertDataIntoDatabase(
      Map<String, dynamic> jsonData, BuildContext context) async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'GlowGrid.db'),
    );

    final db = await database;
    ///TODO: percentage error while importing
    List<dynamic> apartments = jsonData['Apartments'];
    for (var user in apartments) {
      await db.insert(
        'Apartments',
        user as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    List<dynamic> rooms = jsonData['Rooms'];
    for (var room in rooms) {
      await db.insert(
        'Rooms',
        room as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

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
    });
    getRoomsByApartmentID(context, apartmentMap.first['ApartmentID'])
        .then((value) {
      // setState(() {
        Provider.of<AuthProvider>(context, listen: false)
            .toggling('loading', false);
      // });
      _startProgress();
      Navigator.pop(context);
    });
  }

  void _startProgress() {
    setState(() {
      timeElapsed++;
      progressValue += 1 / 10;

      for (var entry in messages) {
        if (timeElapsed >= entry["time"]) {
          displayMessage = entry["message"];
        }
      }

      if (progressValue >= 1.0) {
        progressValue = 1.0;
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CornerZoomPainter extends CustomPainter {
  final double animationPadding;

  CornerZoomPainter(this.animationPadding);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MyColors.greenDark1
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;

    final qrCodePadding = 30.0 + animationPadding;

    canvas.drawLine(Offset(qrCodePadding, qrCodePadding),
        Offset(qrCodePadding + cornerLength, qrCodePadding), paint);
    canvas.drawLine(Offset(qrCodePadding, qrCodePadding),
        Offset(qrCodePadding, qrCodePadding + cornerLength), paint);

    canvas.drawLine(
        Offset(size.width - qrCodePadding, qrCodePadding),
        Offset(size.width - qrCodePadding - cornerLength, qrCodePadding),
        paint);
    canvas.drawLine(
        Offset(size.width - qrCodePadding, qrCodePadding),
        Offset(size.width - qrCodePadding, qrCodePadding + cornerLength),
        paint);

    canvas.drawLine(
        Offset(qrCodePadding, size.height - qrCodePadding),
        Offset(qrCodePadding + cornerLength, size.height - qrCodePadding),
        paint);
    canvas.drawLine(
        Offset(qrCodePadding, size.height - qrCodePadding),
        Offset(qrCodePadding, size.height - qrCodePadding - cornerLength),
        paint);

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

/*
class QRScannerScreen extends StatefulWidget {
  final Function(String) onDetect;

  const QRScannerScreen({super.key, required this.onDetect});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
          controller: cameraController,
          onDetect: (BarcodeCapture capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final String? code = barcode.rawValue;
              if (code != null) {
                widget.onDetect(code);
                Navigator.of(context).pop(); // Close scanner after a valid scan
                break;
              }
            }
          },
        ),
          // Cancel button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Switch Camera
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.flip_camera_android, color: Colors.white, size: 30),
              onPressed: () => cameraController.switchCamera(),
            ),
          ),
          // Flashlight
          Positioned(
            bottom: 100,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.flash_on, color: Colors.white, size: 30),
              onPressed: () => cameraController.toggleTorch(),
            ),
          ),
          // Scanning frame and animation
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: 250 * _animation.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Instruction Text
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Align QR code within the frame',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/


class QRScannerScreen extends StatefulWidget {
  final Function(String) onDetect;

  const QRScannerScreen({super.key, required this.onDetect});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  MobileScannerController cameraController = MobileScannerController();

  final double scanBoxSize = 300;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS?CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          // Fullscreen camera
          MobileScanner(
            controller: cameraController,
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  widget.onDetect(code);
                  Navigator.of(context).pop();
                  break;
                }
              }
            },
          ),
          // Overlay with transparent hole in center
          Positioned.fill(
            child: CustomPaint(
              painter: _CameraHolePainter(scanBoxSize),
            ),
          ),
          // Cancel Button
          Positioned(
            top: 50,
            left: 20,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.clear, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Switch Camera
          Positioned(
            top: 50,
            right: 20,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.camera_rotate, color: Colors.white, size: 30),
              onPressed: () => cameraController.switchCamera(),
            )/*IconButton(
              icon: Icon(Icons.flip_camera_android, color: Colors.white, size: 30),
              onPressed: () => cameraController.switchCamera(),
            )*/,
          ),

          // Flashlight
          Positioned(
            bottom: 100,
            right: 20,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.light_max, color: Colors.white, size: 30),
              onPressed: () => cameraController.toggleTorch(),
            )
            /*IconButton(
              icon: Icon(Icons.flash_on, color: Colors.white, size: 30),
              onPressed: () => cameraController.toggleTorch(),
            )*/,
          ),

          // Scanning Animation
          Center(
            child: SizedBox(
              width: scanBoxSize,
              height: scanBoxSize,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: scanBoxSize * _animation.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Instruction Text
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Align QR code within the frame',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ):Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen camera
          MobileScanner(
            controller: cameraController,
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  widget.onDetect(code);
                  Navigator.of(context).pop();
                  break;
                }
              }
            },
          ),
          // Overlay with transparent hole in center
          Positioned.fill(
            child: CustomPaint(
              painter: _CameraHolePainter(scanBoxSize),
            ),
          ),
          // Cancel Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Switch Camera
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.flip_camera_android, color: Colors.white, size: 30),
              onPressed: () => cameraController.switchCamera(),
            ),
          ),

          // Flashlight
          Positioned(
            bottom: 100,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.flash_on, color: Colors.white, size: 30),
              onPressed: () => cameraController.toggleTorch(),
            ),
          ),

          // Scanning Animation
          Center(
            child: SizedBox(
              width: scanBoxSize,
              height: scanBoxSize,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: scanBoxSize * _animation.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Instruction Text
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Align QR code within the frame',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraHolePainter extends CustomPainter {
  final double holeSize;

  _CameraHolePainter(this.holeSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final holeRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: holeSize,
      height: holeSize,
    );

    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectXY(holeRect, 12, 12))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
