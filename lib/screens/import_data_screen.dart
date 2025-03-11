import '../commons.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart' as qr_scan;
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
    return Scaffold(
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

  Future<void> scanQR(BuildContext context) async {
    try {
      barcodeScanRes = await qr_scan.FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, qr_scan.ScanMode.QR);
      if (barcodeScanRes.isNotEmpty && barcodeScanRes != '-1') {
        _startProgress();
        setState(() {
          reformattingData = true;
        });
        _startProgress();
        final response = await http.get(Uri.parse(barcodeScanRes));
        _startProgress();
        final dir = await getApplicationDocumentsDirectory();
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
    } on PlatformException {
      barcodeScanRes = 'failed';
    }
    if (!mounted) return;
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
      setState(() {
        Provider.of<AuthProvider>(context, listen: false)
            .toggling('loading', false);
      });
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
