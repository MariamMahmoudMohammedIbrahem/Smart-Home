import 'package:encrypt/encrypt.dart' as encrypt;

import '../commons.dart';
import 'package:http/http.dart' as http;

class ImportDataScreen extends StatefulWidget {
  const ImportDataScreen({super.key});

  @override
  ImportDataScreenState createState() => ImportDataScreenState();
}

class ImportDataScreenState extends State<ImportDataScreen>
    with SingleTickerProviderStateMixin {
  bool _canPop = false;
  bool scanned = false;
  bool reformattingData = false;

  late AnimationController controller;
  late Animation<double> animation;
  String displayMessage = "Starting download...";
  bool fileMissing = false;
  final List<Map<String, dynamic>> messages = [
    {"time": 2, "message": "Preparing files..."},
    {"time": 5, "message": "Downloading..."},
    {"time": 8, "message": "Almost there..."},
    {"time": 10, "message": "Download complete! \nYou are Ready to go."}
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handlePop(context);
        }
      },
      child:
      Platform.isIOS
          ? CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: GestureDetector(
            onTap: () => _handlePop(context),
            child: Icon(
              CupertinoIcons.back,
              color: MyColors.greenDark1,
            ),
          ),
          middle: Text('Import Data', style: cupertinoNavTitleStyle),
        ),
        child: scaffoldBody(isDarkMode, width),
      )
          : Scaffold(
        appBar: AppBar(
          surfaceTintColor: MyColors.greenLight1,
          shadowColor: MyColors.greenLight2,
          backgroundColor: MyColors.greenDark1,
          foregroundColor: Colors.white,
          shape: appBarShape,
          title: const Text('Import Data'),
          titleTextStyle: materialNavTitleTextStyle,
          centerTitle: true,
        ),
        body: scaffoldBody(isDarkMode, width),
      ),
    );
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

  Widget scaffoldBody(bool isDarkMode, double width) {
    return Center(
      child:
      Provider.of<AuthProvider>(context).wifiConnected
          ? progressValue == 0.0
          ? qrScanIdleView(isDarkMode, width)
          : fileMissing
          ? fileMissingView()
          : errorOccurred
          ? qrScanErrorView()
          : qrScanInProgressView()
          : noInternetView(),
    );
  }

  /// Displays the QR code scanning UI when the user is ready to scan a code.
  ///
  /// This state appears when there is an internet connection, and the QR process has not yet started.
  /// It contains a QR placeholder (non-functional QR image) and a scan button with a custom animation.
  Widget qrScanIdleView(bool isDarkMode, double width) {
    void onPressed() => scanQR(context);

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.qr_code_scanner_rounded,color: isDarkMode?Colors.black:Colors.white),
        SizedBox(width: 4),
        Text('Scan QR Code', style: TextStyle(color: isDarkMode?Colors.black:Colors.white),),
      ],
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // The placeholder QR code display
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: QrImageView(
                data: '',
                version: QrVersions.auto,
                size: 200.0,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.black,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.black,
                ),
              ),
            ),
            // Custom animated painter overlay (e.g., zooming effect on corners)
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
        // Scan button to initiate QR scanning
        SizedBox(
          width: width * .5,
          child:
          Platform.isIOS
              ? CupertinoButton(
            color: MyColors.greenDark1,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            onPressed: onPressed,
            child: child,
          )
              : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.greenDark1,
              foregroundColor:
              isDarkMode ? Colors.grey[900] : Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onPressed: onPressed,
            child: child,
          ),
        ),
      ],
    );
  }

  /// Displays an error message if file is no longer accessible.
  ///
  /// This view appears only when there is an internet connection, but an error occurred
  /// during processing the scanned QR code (e.g., the file is missing from the firebase).
  Widget fileMissingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Error Icon
        Icon(Icons.running_with_errors_rounded, size: 50),
        // Explanation Message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          child: Text(
            "Error happened while transferring the data. \n Please recreate the QR code and re-scan",
            textAlign: TextAlign.center,
          ),
        ),
        // Button to retry scanning and reset state
        rescanButton(),
      ],
    );
  }

  /// Displays an error message if something went wrong during data transfer after scanning.
  ///
  /// This view appears only when there is an internet connection, but an error occurred
  /// during processing the scanned QR code (e.g., server or format error).
  Widget qrScanErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Error Icon
        Icon(Icons.error, size: 50),
        // Explanation Message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          child: Text(
            "Error happened while transferring the data. \n Please try to scan again",
            textAlign: TextAlign.center,
          ),
        ),
        // Button to retry scanning and reset state
        rescanButton(),
      ],
    );
  }

  Widget rescanButton() {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    void onPressed() {
      resetting();
      scanQR(context);
    }

    final child = Text("Re-Scan", style: TextStyle(color: isDarkMode?Colors.black:Colors.white));

    return Platform.isIOS
        ? CupertinoButton(
      color: MyColors.greenDark1,
      onPressed: onPressed,
      child: child,
    )
        : ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(
      backgroundColor: MyColors.greenDark1,
      foregroundColor:
      isDarkMode ? Colors.grey[900] : Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ), child: child,);
  }

  /// Displays a progress indicator and message while data is being transferred or processed.
  ///
  /// This view shows after the QR scan has succeeded, and the app is currently downloading or
  /// handling the resulting data. It is used when everything is working correctly but not yet completed.
  Widget qrScanInProgressView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        downloadStatus(),
        height20,
        Text(displayMessage, style: titleTextStyle),
      ],
    );
  }

  /// Main widget to show download status.
  /// Decides whether to show a completed icon or a progress indicator with percentage.
  Widget downloadStatus() {
    final bool isComplete = progressValue == 1.0;
    return isComplete
        ? const DownloadCompleteIndicator()
        : DownloadProgressIndicator(circleDiameter: 100, progress: progressValue, progressFontSize: 20,);
  }

  /// Displays a simple message and icon when the device is offline.
  ///
  /// This view appears when the user opens the screen without an internet connection.
  /// It prevents scanning or fetching any data until the connection is restored.
  Widget noInternetView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // No connection icon
        Icon(Icons.error_outline_rounded, size: 50),
        // Informative text
        Text("No Internet Connection", textAlign: TextAlign.center),
      ],
    );
  }

  /// Handles the back navigation event.
  /// If data is being transferred, shows a platform-specific confirmation dialog.
  /// Returns `true` if the user is allowed to exit, `false` otherwise.
  Future<void> _handlePop(BuildContext context) async {
    // Directly allow exit if progress is 0 or 1
    if (progressValue == 0.0 || progressValue == 1.0) {
      safeSetState(() => _canPop = true);
      Navigator.of(context).pop(true);
      return;
    }

    bool? exit =
      context.mounted
        ?Platform.isIOS
          ? await _showExitConfirmationCupertino(context)
          : await _showExitConfirmationMaterial(context)
        :false;

    if (exit == true) {
      safeSetState(() => _canPop = true);
      if(!context.mounted) return;
      Navigator.of(context).pop();
    }
  }

  /// Shows a Cupertino-style confirmation dialog (iOS).
  /// Returns `true` if user confirms to exit, `false` otherwise.
  Future<bool?> _showExitConfirmationCupertino(BuildContext context) {
    return showCupertinoDialog<bool>(
      context: context,
      barrierDismissible:
      false, // Prevent closing the dialog by tapping outside
      builder:
          (context) => CupertinoAlertDialog(
        title: const Text("Alert"),
        content: const Text(
          "If the data isn't successfully transferred yet, please don't close the screen.",
        ),
        actions: [
          CupertinoDialogAction(
            onPressed:
                () => Navigator.of(context).pop(false), // Stay on screen
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true), // Allow exit
            child: const Text("Exit"),
          ),
        ],
      ),
    );
  }

  /// Shows a Material-style confirmation dialog (Android/Web).
  /// Returns `true` if user confirms to exit, `false` otherwise.
  Future<bool?> _showExitConfirmationMaterial(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Alert'),
        content: const Text(
          "If the data isn't successfully transferred yet, please don't close the screen.",
        ),
        actions: [
          TextButton(
            onPressed:
                () => Navigator.of(context).pop(false), // Stay on screen
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Allow exit
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  /// Scans a QR code and processes the result if valid.
  Future<void> scanQR(BuildContext context) async {
    final route =
    Platform.isIOS
        ? CupertinoPageRoute(builder: (_) => _buildQRScanner(context))
        : MaterialPageRoute(builder: (_) => _buildQRScanner(context));

    await Navigator.of(context).push(route);
  }

  /// Builds the QR scanner screen with handling logic
  Widget _buildQRScanner(BuildContext parentContext) {
    return QRScannerScreen(
      onDetect: (String barcode) async {
        if (barcode.isEmpty || scanned ) return;

        scanned = true; // Prevents re-entry
        await _importingFirebaseToApp(parentContext, barcode);
      },
    );
  }

  String decryptUrl(String data) {
    try {
      final parts = data.split(":");
      if (parts.length != 2) throw Exception("Invalid encrypted format");

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedBase64 = parts[1];

      final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);
      return baseURL + decrypted;
    } catch (e) {
      return '';
    }
  }

  /// Imports JSON from the scanned barcode URL into the app
  Future<void> _importingFirebaseToApp(
      BuildContext parentContext,
      String url,
      ) async {
    Navigator.pop(parentContext); // Close the scanner
    await Future.delayed(const Duration(milliseconds: 100));

    _startProgress(0.1); // 10%
    safeSetState(() => reformattingData = true);
    _startProgress(0.2); // 20%

    try {
      String decryptedUrl = decryptUrl(url);
      final response = await http.get(Uri.parse(decryptedUrl));
      if (response.statusCode == 404) {
        safeSetState(() => fileMissing = true);
        return;
      }
      _startProgress(0.3); // 30%

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$localFileName.json');
      _startProgress(0.4); // 40%

      file.writeAsBytesSync(response.bodyBytes);
      _startProgress(0.5); // 50%
    } catch (e) {
      errorOccurred = true;
      return;
    }

    _startProgress(0.6); // 60%
    await deleteOldFiles();
    _startProgress(0.7); // 70%
    if(!context.mounted) return;
    await _readJsonFromFile('$localFileName.json', parentContext);
  }

  /// Reads the downloaded JSON file and inserts data into the database
  Future<void> _readJsonFromFile(String fileName, BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');

      if (!file.existsSync()) {
        throw Exception("JSON file does not exist.");
      }

      final jsonData = await file.readAsString();
      await deleteAllRoomsAndDevices();
      _startProgress(0.8); // 80%

      if(!context.mounted) return;
      await _insertDataIntoDatabase(jsonDecode(jsonData), context);
    } catch (e) {
      safeSetState(() => errorOccurred = true);
      throw Exception("Error reading JSON file: $e");
    }
  }

  /// Inserts apartments, rooms, and devices data into the local SQLite database
  Future<void> _insertDataIntoDatabase(
      Map<String, dynamic> data,
      BuildContext context,
      ) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'GlowGrid.db'),
    );

    for (var item in data['Apartments']) {
      await db.insert(
        'Apartments',
        item as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var item in data['Rooms']) {
      await db.insert(
        'Rooms',
        item as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var item in data['Devices']) {
      await db.insert(
        'Devices',
        item as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    safeSetState(() => reformattingData = false);
    if(!context.mounted) return;
    await getRoomsByApartmentID(context, apartmentMap.first['ApartmentID']);

    getAllMacAddresses();
    _startProgress(0.9); // 90%
    if(!context.mounted) return;
    Provider.of<AuthProvider>(
      context,
      listen: false,
    ).toggling('loading', false);
    _startProgress(1.0); // 100%
  }

  /// Updates the progress and related status message
  void _startProgress(double newValue) {
    safeSetState(() {
      progressValue = newValue;
      int elapsedTime = (newValue * 10).toInt();
      for (var entry in messages) {
        if (elapsedTime >= entry["time"]) {
          displayMessage = entry["message"];
        }
      }
    });
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Resets all progress and flags for a new import
  void resetting() {
    progressValue = 0.0;
    errorOccurred = false;
    scanned = false;
    displayMessage = "Starting download...";
  }

  @override
  void dispose() {
    resetting();
    controller.dispose();
    super.dispose();
  }
}