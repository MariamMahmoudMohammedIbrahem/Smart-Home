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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.qr_code_scanner_rounded,color: isDarkMode?Colors.black:Colors.white),
        SizedBox(width: 8),
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
        : ElevatedButton(onPressed: onPressed, child: child);
  }

  /// Displays a progress indicator and message while data is being transferred or processed.
  ///
  /// This view shows after the QR scan has succeeded, and the app is currently downloading or
  /// handling the resulting data. It is used when everything is working correctly but not yet completed.
  Widget qrScanInProgressView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Custom widget to show download progress (e.g., progress bar, spinner)
        downloadStatus(),
        height20, // Spacer widget (assumed to be a SizedBox)
        // Dynamic message (e.g., "Downloading..." or "Preparing data")
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
        : DownloadProgressIndicator(circleDiameter: 100, progress: progressValue);
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
    print("Trying to exit $progressValue");

    // Directly allow exit if progress is 0 or 1
    if (progressValue == 0.0 || progressValue == 1.0) {
      setState(() => _canPop = true);
      Navigator.of(context).pop(true);
      return;
    }

    bool? exit =
        Platform.isIOS
            ? await _showExitConfirmationCupertino(context)
            : await _showExitConfirmationMaterial(context);

    if (exit == true) {
      setState(() => _canPop = true);
      Navigator.of(context).pop();
    }
  }

  /// Shows a Cupertino-style confirmation dialog (iOS).
  /// Returns `true` if user confirms to exit, `false` otherwise.
  Future<bool?> _showExitConfirmationCupertino(BuildContext context) {
    print("Showing Cupertino dialog");

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
        if (barcode.isEmpty || scanned || !barcode.startsWith(baseURL)) return;

        scanned = true; // Prevents re-entry
        await _importingFirebaseToApp(parentContext, barcode);
      },
    );
  }

  /// Imports JSON from the scanned barcode URL into the app
  Future<void> _importingFirebaseToApp(
    BuildContext parentContext,
    String url,
  ) async {
    print("Starting import from Firebase...");
    Navigator.pop(parentContext); // Close the scanner
    await Future.delayed(const Duration(milliseconds: 100));

    _startProgress(0.1); // 10%
    setState(() => reformattingData = true);
    _startProgress(0.2); // 20%

    try {
      final response = await http.get(Uri.parse(url));
      print(response.statusCode);
      if (response.statusCode == 404) {
        setState(() => fileMissing = true);
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

      await _insertDataIntoDatabase(jsonDecode(jsonData), context);
    } catch (e) {
      setState(() => errorOccurred = true);
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

    print("Inserting apartments");
    for (var item in data['Apartments']) {
      await db.insert(
        'Apartments',
        item as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print("Inserting rooms");
    for (var item in data['Rooms']) {
      await db.insert(
        'Rooms',
        item as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print("Inserting devices");
    for (var item in data['Devices']) {
      await db.insert(
        'Devices',
        item as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    setState(() => reformattingData = false);
    await getRoomsByApartmentID(context, apartmentMap.first['ApartmentID']);

    _startProgress(0.9); // 90%
    Provider.of<AuthProvider>(
      context,
      listen: false,
    ).toggling('loading', false);
    _startProgress(1.0); // 100%
  }

  /// Updates the progress and related status message
  void _startProgress(double newValue) {
    print("Progress: $newValue");
    setState(() {
      progressValue = newValue;
      int elapsedTime = (newValue * 10).toInt();
      for (var entry in messages) {
        if (elapsedTime >= entry["time"]) {
          displayMessage = entry["message"];
        }
      }
    });
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
/*Widget downloadStatus () {
    return progressValue ==1.0
        ? const CircleAvatar(
      radius: 50,
      backgroundColor: MyColors.greenDark1,
      child: Icon(
        Icons.done,
        color: Colors.white,
        size: 50,
      ),
    )
        : Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: progressValue,
            strokeWidth: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(
              MyColors.greenDark1,
            ),
          ),
        ),
        Text(
          '${(progressValue * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: MyColors.greenDark1,
          ),
        ),
      ],
    );
  }*/
/*
Widget cupertinoBody (bool isDarkMode, double width) {
    return Center(
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
              color: MyColors.greenDark1,
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
    );
  }
  Widget scaffoldBody (bool isDarkMode, double width) {
    return Center(
      child: Provider.of<AuthProvider>(context).wifiConnected?progressValue == 0.0
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
          : errorOccurred
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.running_with_errors_rounded, size: 50,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: Text(
              "Error happened while transferring the data. \n Please try to scan again",
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(onPressed: (){resetting();scanQR(context);}, child: Text("re-scan"))
        ],
      )
          :Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          downloadStatus(),
          height20,
          Text(
            displayMessage,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: MyColors.greenDark1,
            ),
          ),
        ],
      )
      // wifi not connected case
          :Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 50,),
          Text("No Internet Connection",textAlign: TextAlign.center,),
        ],
      ),
    );
  }
  Future<bool> _onWillPop(BuildContext context) async {
    print("trying to exit ");
    // Show a Cupertino-style alert dialog to confirm whether the user wants to leave the screen
    bool? exit = progressValue == 0.0 || progressValue == 1.0 ?true:Platform.isIOS
        ? await showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context)
      {
        print("showing cupertino");
        return CupertinoAlertDialog(

          title: Text("Alert"),
          content: Text(
              "if the data isn\'t successfully transferred yet, Please don\'t close the screen"),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(false); // Don't pop
              },
              child: Text("Cancel"),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(true); // Do pop
              },
              child: Text("Exit"),
            ),
          ],
        );
      },
    )
        :await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: const Text('if the data isn\'t successfully transferred yet, Please don\'t close the screen'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Exit'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    return exit ?? false; // Return whether the user confirms to exit
  }
 */

/*Future<void> scanQR(BuildContext parentContext) async {
    if(Platform.isIOS){
      await Navigator.of(parentContext).push(
        CupertinoPageRoute(
          builder: (innerContext) =>
              QRScannerScreen(
                onDetect: (String barcodeScanRes) async {
                  if (barcodeScanRes.isNotEmpty) {
                    if (scanned) return;
                    if (barcodeScanRes.isNotEmpty && barcodeScanRes.startsWith(baseURL)) {
                      scanned = true; // prevent re-entry
                      await importingFirebaseToApp(innerContext, barcodeScanRes, parentContext);
                    }
                  }
                },
          ),
        ),
      ); }
    else {
      await Navigator.of(parentContext).push(
        MaterialPageRoute(
          builder: (innerContext) =>
              QRScannerScreen(
                onDetect: (String barcodeScanRes) async {
                  if (barcodeScanRes.isNotEmpty) {
                    if (scanned) return; // already processed
                    if (barcodeScanRes.isNotEmpty && barcodeScanRes.startsWith(baseURL)) {
                      scanned = true; // prevent re-entry
                      await importingFirebaseToApp(innerContext, barcodeScanRes, parentContext);
                    }
                  }
                },
              ),
        ),
      );
    }
  }
  Future<void> importingFirebaseToApp (BuildContext innerContext, String barcodeScanRes, BuildContext parentContext) async {

    print("hello from importing");
    // exiting the qr code scanner only once
    // the widget can detect the qr code more than once which lead to dead context
    Navigator.pop(innerContext);
    await Future.delayed(Duration(milliseconds: 100));
    _startProgress(.1); // 10%
    setState(() {
      reformattingData = true;
    });
    _startProgress(.2); // 20%
    try{
      final response = await http.get(Uri.parse(barcodeScanRes));
      print("response $response");
      _startProgress(.3); // 30%
      final dir = await getApplicationDocumentsDirectory();
      print("dir $dir");
      _startProgress(.4); // 40%
      final file = File('${dir.path}/$localFileName.json');
      print("file $file");
      _startProgress(.5); // 50%
      file.writeAsBytesSync(response.bodyBytes);
      print("body bytes ${response.bodyBytes}");
    } catch (_) {
      errorOccurred = true;
    }
    _startProgress(.6); // 60%
    await deleteOldFiles();
    _startProgress(.7); // 70%
    await readJsonFromFile('$localFileName.json',parentContext);
  }

  Future readJsonFromFile(String fileName, BuildContext parentContext) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      if (!file.existsSync()) {
        throw Exception("JSON file does not exist.");
      }

      final jsonData = await file.readAsString();
      await deleteAllRoomsAndDevices();
      _startProgress(.8); // 80%
      await insertDataIntoDatabase(jsonDecode(jsonData),parentContext);
    } catch (e) {
      setState(() {
        errorOccurred = true;
      });
      throw Exception("Error reading JSON file: $e");
    }
  }

  Future<void> insertDataIntoDatabase(
      Map<String, dynamic> jsonData, BuildContext parentContext) async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'GlowGrid.db'),
    );
print("jsonData insert into database $jsonData");
    final db = await database;
    ///TODO: percentage error while importing
    List<dynamic> apartments = jsonData['Apartments'];
    print("apartments $apartments");
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
    await getRoomsByApartmentID(parentContext, apartmentMap.first['ApartmentID']);
    _startProgress(.9);// 90%
    Provider.of<AuthProvider>(parentContext, listen: false)
            .toggling('loading', false);
    _startProgress(1.0);// 100%

  }

  void _startProgress(double newValue) {
    print("newValue $newValue");
    setState(() {
      progressValue = newValue;
      double value = newValue * 10;
      int timeElapsed = value.toInt();
      for (var entry in messages) {
        if (timeElapsed >= entry["time"]) {
          displayMessage = entry["message"];
        }
      }
    });
  }

  void resetting () {
    progressValue = 0.0;
    errorOccurred = false;
    scanned = false;
    displayMessage = "Starting download...";
  }

  Future<bool> _onWillPop(BuildContext context) async {
    print("Trying to exit");

    // Allow immediate exit if no transfer is happening or it's already complete
    if (progressValue == 0.0 || progressValue == 1.0) return true;

    // Otherwise, show a confirmation dialog based on the platform
    final bool? shouldExit = Platform.isIOS
        ? await _showExitConfirmationCupertino(context)
        : await _showExitConfirmationMaterial(context);

    // If the dialog result is null (dismissed), default to not exiting
    return shouldExit ?? false;
  }
  */
