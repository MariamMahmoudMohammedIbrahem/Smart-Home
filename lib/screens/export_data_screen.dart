import 'package:mega/styles/colors.dart';

import '../commons.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ExportDataScreenState createState() => ExportDataScreenState();
}

class ExportDataScreenState extends State<ExportDataScreen> {

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmationDialog(context);
      },
      child: Scaffold(
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
    uploadDatabaseToFirebase();
    super.initState();
  }

  Future<void> uploadDatabaseToFirebase() async {
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

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
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
    ).then((value) => value ?? false);
  }

  @override
  void dispose(){
    deleteSpecificFile(localFileName);
    super.dispose();
  }
}
