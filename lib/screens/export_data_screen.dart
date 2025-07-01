import '../commons.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ExportDataScreenState createState() => ExportDataScreenState();
}

class ExportDataScreenState extends State<ExportDataScreen>{
  bool _canPop = false;
  Timer? timeoutTimer;

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
      child: Platform.isIOS
          ? CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: GestureDetector(
            onTap: () => _handlePop(context),
            child: Icon(
              CupertinoIcons.back,
              color: MyColors.greenDark1,
            ),
          ),
          middle: const Text(
            'Export Data',
            style: cupertinoNavTitleStyle,
          ),
        ),
        child: SafeArea(
          child: scaffoldBody(isDarkMode, width),
        ),
      )
          : Scaffold(
        appBar: buildMaterialAppBar("Export Data"),
        body: scaffoldBody(isDarkMode, width),
      ),
    );
  }

  @override
  void initState() {
    _uploadDatabaseToFirebase();
    super.initState();
  }

  Widget scaffoldBody (bool isDarkMode, double width) {
    Widget child = Platform.isIOS
        ? const CupertinoActivityIndicator()
        : const CircularProgressIndicator(color: MyColors.greenDark1,);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            uploadProgress == 0.0 || downloadURL.isEmpty
                ? uploadFailed
                ? kEmptyWidget
                : child
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
    );
  }

  Future<void> _handlePop(BuildContext context) async {
    print("Trying to exit $progressValue");

    // Directly allow exit if progress is 0
    if (uploadProgress == 0.0 || uploadSteps == 0) {
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

  Future<bool?> _showExitConfirmationCupertino (BuildContext context) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context)
      {
        print("showing cupertino");
        return CupertinoAlertDialog(

          title: Text("Alert"),
          content: Text(
              "if the data isn't successfully transferred yet, Please don't close the screen"),
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
    );
  }

  Future<bool?> _showExitConfirmationMaterial (BuildContext context) {
    return showDialog<bool>(
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
  }

  void startTimeoutTimer() {
    timeoutTimer?.cancel();
    timeoutTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        uploadStatus = 'Check your internet connection.';
      });
    });
  }

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

  void resetting () {
    uploadFailed = false;
    uploadStatus = '';
    downloadURL = '';
    timeoutTimer?.cancel();
  }

  @override
  void dispose(){
    super.dispose();
    deleteSpecificFile(localFileName);
    resetting();
  }
}
/*Future<bool> _onWillPop(BuildContext context) async {
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
            "if the data isn't successfully transferred yet, Please don't close the screen"),
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
  }*/