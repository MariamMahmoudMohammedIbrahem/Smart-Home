import '../commons.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ExportDataScreenState createState() => ExportDataScreenState();
}

class ExportDataScreenState extends State<ExportDataScreen>{
  // String qrPayload = "";

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () =>_onWillPop(context),
      child: Platform.isIOS
          ? CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: CupertinoNavigationBarBackButton(
            color: MyColors.greenDark1,
            onPressed: () async {
              bool shouldPop = await _onWillPop(context);
              if (shouldPop) {
                Navigator.of(context).pop();
              }
            },
          ),
          middle: const Text(
            'Export Data',
            style: TextStyle(
              color: MyColors.greenDark1,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          // border: const Border(
          //   bottom: BorderSide(color: MyColors.greenLight2, width: 1),
          // ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  uploadProgress == 0.0 || downloadURL.isEmpty
                      ? uploadFailed
                      ? kEmptyWidget
                      : const CupertinoActivityIndicator()
                      : QrImageView(
                    data: downloadURL,
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
                  height20,
                  Text(
                    uploadStatus == null ? '' : '$uploadStatus',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MyColors.greenDark1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      )
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
            'Export Data',
          ),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * .1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                uploadProgress == 0.0 || downloadURL.isEmpty
                    ? uploadFailed
                    ? kEmptyWidget
                    : const CircularProgressIndicator(
                  color: MyColors.greenDark1,
                )
                    : QrImageView(
                  data: downloadURL,
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: QrEyeStyle(
                    eyeShape:
                    QrEyeShape.square,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.black,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape
                        .square,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.black,
                  ),
                ),
                height20,
                Text(
                  uploadStatus == null ? '' : '$uploadStatus',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MyColors.greenDark1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _uploadDatabaseToFirebase();
    super.initState();
  }

/*Future<void> _uploadDatabaseToFirebase() async {
    bool isConnected = await isConnectedToInternet();

    if (!isConnected) {
      setState(() {
        uploadFailed = true;
        uploadStatus = "No internet connection.";
      });
      return;
    }

    File? dbFile = await getLocalDatabaseFile();
    if (dbFile == null) {
      setState(() {
        uploadFailed = true;
        uploadStatus = "Failed to find the database file.";
      });
      return;
    }

    Timer? timeoutTimer;

    void startTimeoutTimer() {
      timeoutTimer?.cancel();
      timeoutTimer = Timer(const Duration(seconds: 5), () {
        setState(() {
          uploadStatus = 'Check your internet connection.';
        });
      });
    }

    try {
      setState(() {
        uploadStatus = 'Preparing to upload...';
        uploadProgress = 0.0;
        uploadSteps = 0;
        uploadFailed = false;
      });
      startTimeoutTimer();

      String fileName = '$localFileName.json';
      String firebasePath = 'databases/$fileName';

      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(firebasePath);

      setState(() {
        uploadStatus = 'Setting up file data...';
      });
      startTimeoutTimer();

      SettableMetadata metadata = SettableMetadata(
        contentType: 'application/json',
        customMetadata: {
          'uploadTime': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        uploadStatus = 'Collecting data...';
      });
      startTimeoutTimer();

      UploadTask uploadTask = firebaseStorageRef.putFile(dbFile, metadata);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        startTimeoutTimer();

        if (snapshot.bytesTransferred > (uploadSteps * (snapshot.totalBytes / 10))) {
          uploadSteps++;
          uploadProgress = (uploadSteps * 0.1).clamp(0.0, 1.0);
        }

        setState(() {
          uploadStatus = 'Uploading';
        });
      });

      await uploadTask;

      // Here's your simplified QR payload:
      qrPayload = fileName; // For example: "my_data_2024_04_14.json"

      setState(() {
        uploadStatus = 'Upload complete! \n Scan to get the data on your mobile';
        uploadProgress = 1.0;
      });
    } catch (e) {
      setState(() {
        uploadFailed = true;
        uploadStatus = 'Upload failed: Unexpected error';
        uploadProgress = 0.0;
      });
    } finally {
      timeoutTimer?.cancel();
    }
  }*/

  Future<void> _uploadDatabaseToFirebase() async {
    bool isConnected = await isConnectedToInternet();

    if (!isConnected) {
      setState(() {
        uploadFailed = true;
        uploadStatus = "No internet connection.";
      });
      return;
    }

    File? dbFile = await getLocalDatabaseFile();
    if (dbFile == null) {
      setState(() {
        uploadFailed = true;
        uploadStatus = "Failed to find the database file.";
      });
      return;
    }

    Timer? timeoutTimer;

    void startTimeoutTimer() {
      timeoutTimer?.cancel();
      timeoutTimer = Timer(const Duration(seconds: 5), () {
        setState(() {
          uploadStatus = 'Check your internet connection.';
        });
      });
    }

    try {
      setState(() {
        uploadStatus = 'Preparing to upload...';
        uploadProgress = 0.0;
        uploadSteps = 0;
        uploadFailed = false;
      });
      startTimeoutTimer();

      String fileName = 'databases/$localFileName.json';
      Reference firebaseStorageRef =
      FirebaseStorage.instance.ref().child(fileName);

      setState(() {
        uploadStatus = 'Setting up file data...';
      });
      startTimeoutTimer();

      SettableMetadata metadata = SettableMetadata(
        customMetadata: {
          'uploadTime': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        uploadStatus = 'Collecting data...';
      });
      startTimeoutTimer();

      UploadTask uploadTask = firebaseStorageRef.putFile(dbFile, metadata);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        startTimeoutTimer();

        if (snapshot.bytesTransferred >
            (uploadSteps * (snapshot.totalBytes / 10))) {
          uploadSteps++;
          uploadProgress = (uploadSteps * 0.1).clamp(0.0, 1.0);
        }

        setState(() {
          uploadStatus = 'Uploading';
        });
      });

      await uploadTask;

      setState(() {
        uploadStatus = 'Finalizing preparation...';
      });
      startTimeoutTimer();

      downloadURL = await firebaseStorageRef.getDownloadURL();

      setState(() {
        uploadStatus =
        'Upload complete! \n scan to get the data on your mobile';
        uploadProgress = 1.0;
      });
    } on FirebaseException catch (e) {
      setState(() {
        uploadFailed = true;
        uploadStatus = 'Upload failed: An Error Occurred';
        uploadProgress = 0.0;
      });

      if (e.code == 'permission-denied') {
        setState(() {
          uploadStatus = 'Upload failed: Insufficient permissions.';
        });
      } else if (e.code == 'quota-exceeded') {
        setState(() {
          uploadStatus = 'Upload failed: Storage quota exceeded.';
        });
      } else if (e.code == 'canceled') {
        setState(() {
          uploadStatus = 'Upload failed: Upload canceled by user.';
        });
      }
    } on SocketException {
      setState(() {
        uploadStatus =
        'Upload failed: Network error. Please check your internet connection.';
        uploadProgress = 0.0;
      });
    } on TimeoutException {
      setState(() {
        uploadStatus = 'Upload failed: Connection timed out. Please try again.';
        uploadProgress = 0.0;
      });
    } catch (e) {
      setState(() {
        uploadStatus = 'Upload failed: Unexpected error';
        uploadProgress = 0.0;
      });
    } finally {
      timeoutTimer?.cancel();
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    print("trying to exit ");
    // Show a Cupertino-style alert dialog to confirm whether the user wants to leave the screen
    bool? exit = Platform.isIOS
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

  @override
  void dispose(){
    deleteSpecificFile(localFileName);
    super.dispose();
  }
}
