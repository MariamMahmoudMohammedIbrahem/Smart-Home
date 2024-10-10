import 'dart:async';
import 'dart:convert';
// import 'dart:html';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../constants.dart';
import '../db/functions.dart';
import 'package:http/http.dart' as http;

class UploadDatabase extends StatefulWidget {
  const UploadDatabase({super.key});

  @override
  _UploadDatabaseState createState() => _UploadDatabaseState();
}

class _UploadDatabaseState extends State<UploadDatabase> {
  String? _uploadStatus;
  String downloadURL = '';
  int _uploadSteps = 0;
  double _uploadProgress = 0.0;
  double _progressValue = 0.0;
  int _timerTick = 0;
  String _message = "Preparing data...";
  // Timer? _timer;
  String _status = 'Ready to export data';
  // Get the path of the database file
  @override
  void initState() {
    uploadDatabaseToFirebase();
    super.initState();
  }

  /*Future<String> getDatabasePath(String dbName) async {
    // Get the directory where databases are stored
    String databasePath = await getDatabasesPath();
    print(databasePath);
    // Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // print(documentsDirectory.path);
    String path = '$databasePath/$dbName';
    return path;
  }*/
  Future<File?> _getLocalDatabaseFile() async {
    try {
      // Replace 'your_database.db' with your actual local database file name
      final directory = await getApplicationDocumentsDirectory();
      print('object ${directory.path}');
      final dbFile = File('${directory.path}/$localFileName.json');
      // String dbPath = await getDatabasePath('GlowGrid.db');
      // File dbFile = File(dbPath);

      // Check if the database file exists
      if (await dbFile.exists()) {
        return dbFile;
      } else {
        print("Database file not found.");
        return null;
      }
    } catch (e) {
      print("Error getting database file: $e");
      return null;
    }
  }

  ///without handling the possible errors
  /*Future<void> uploadDatabaseToFirebase() async {
    File? dbFile = await _getLocalDatabaseFile();
    if (dbFile == null) {
      setState(() {
        _uploadStatus = "Failed to find the database file.";
      });
      return;
    }

    Timer? timeoutTimer;

    // Function to handle message change after timeout
    void startTimeoutTimer() {
      timeoutTimer?.cancel();  // Reset any existing timer
      timeoutTimer = Timer(const Duration(seconds: 5), () {
        setState(() {
          _uploadStatus = 'Check your internet connection.';
        });
      });
    }

    try {
      setState(() {
        _uploadStatus = 'Preparing to upload...';
        _uploadProgress = 0.0; // Reset progress
        _uploadSteps = 0; // Reset steps
      });
      startTimeoutTimer();

      String fileName = 'databases/$localFileName.json';
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);

      setState(() {
        _uploadStatus = 'Setting up...';
      });
      startTimeoutTimer();

      SettableMetadata metadata = SettableMetadata(
        customMetadata: {
          'uploadTime': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _uploadStatus = 'Collecting data...';
      });
      startTimeoutTimer();

      UploadTask uploadTask = firebaseStorageRef.putFile(dbFile, metadata);

      // Track the upload status
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        startTimeoutTimer();  // Reset the timer on every snapshot

        // Calculate the progress based on steps
        if (snapshot.bytesTransferred > (_uploadSteps * (snapshot.totalBytes / 10))) {
          _uploadSteps++; // Increment the step count
          _uploadProgress = (_uploadSteps * 0.1).clamp(0.0, 1.0); // Update progress by 0.1
        }

        setState(() {
          _uploadStatus = 'Preparing the data';
        });
      });

      // Wait for the upload to complete
      await uploadTask;

      setState(() {
        _uploadStatus = 'Finalizing preparation...';
      });
      startTimeoutTimer();

      // Get the download URL
      downloadURL = await firebaseStorageRef.getDownloadURL();

      setState(() {
        _uploadStatus = 'Upload complete!';
        _uploadProgress = 1.0; // Set progress to 100% on completion
      });
      print("Database uploaded at: $downloadURL");

    } catch (e) {
      print("Failed to upload database: $e");
      setState(() {
        _uploadStatus = 'Upload failed: $e';
        _uploadProgress = 0.0; // Reset progress on failure
      });
    } finally {
      timeoutTimer?.cancel();  // Cancel the timer after everything is done
    }
  }*/
  ///with handling the possible errors

  Future<void> uploadDatabaseToFirebase() async {
    // Check if the device has an active internet connection
    bool isConnected = await isConnectedToInternet();

    if (!isConnected) {
      setState(() {
        uploadFailed = true;
        _uploadStatus = "No internet connection.";
      });
      return;
    }

    File? dbFile = await _getLocalDatabaseFile();
    if (dbFile == null) {
      setState(() {
        uploadFailed = true;
        _uploadStatus = "Failed to find the database file.";
      });
      return;
    }

    Timer? timeoutTimer;

    // Function to handle message change after timeout
    void startTimeoutTimer() {
      timeoutTimer?.cancel(); // Reset any existing timer
      timeoutTimer = Timer(const Duration(seconds: 5), () {
        setState(() {
          _uploadStatus = 'Check your internet connection.';
        });
      });
    }

    try {
      setState(() {
        _uploadStatus = 'Preparing to upload...';
        _uploadProgress = 0.0; // Reset progress
        _uploadSteps = 0; // Reset steps
        uploadFailed = false;
      });
      startTimeoutTimer();

      String fileName = 'databases/$localFileName.json';
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);

      setState(() {
        _uploadStatus = 'Setting up file data...';
      });
      startTimeoutTimer();

      SettableMetadata metadata = SettableMetadata(
        customMetadata: {
          'uploadTime': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _uploadStatus = 'Collecting data...';
      });
      startTimeoutTimer();

      UploadTask uploadTask = firebaseStorageRef.putFile(dbFile, metadata);

      // Track the upload status
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        startTimeoutTimer(); // Reset the timer on every snapshot

        // Calculate the progress based on steps
        if (snapshot.bytesTransferred >
            (_uploadSteps * (snapshot.totalBytes / 10))) {
          _uploadSteps++; // Increment the step count
          _uploadProgress =
              (_uploadSteps * 0.1).clamp(0.0, 1.0); // Update progress by 0.1
        }

        setState(() {
          _uploadStatus = 'Uploading';
        });
      });

      // Wait for the upload to complete
      await uploadTask;

      setState(() {
        _uploadStatus = 'Finalizing preparation...';
      });
      startTimeoutTimer();

      // Get the download URL
      downloadURL = await firebaseStorageRef.getDownloadURL();

      setState(() {
        _uploadStatus =
            'Upload complete! \n scan to get the data on your mobile';
        _uploadProgress = 1.0; // Set progress to 100% on completion
      });
      print("Database uploaded at: $downloadURL");
    } on FirebaseException catch (e) {
      print("Firebase error: ${e.message}");
      setState(() {
        uploadFailed = true;
        _uploadStatus = 'Upload failed: Firebase error';
        _uploadProgress = 0.0; // Reset progress on failure
      });

      // Specific cases to handle
      if (e.code == 'permission-denied') {
        setState(() {
          _uploadStatus = 'Upload failed: Insufficient permissions.';
        });
      } else if (e.code == 'quota-exceeded') {
        setState(() {
          _uploadStatus = 'Upload failed: Storage quota exceeded.';
        });
      } else if (e.code == 'canceled') {
        setState(() {
          _uploadStatus = 'Upload failed: Upload canceled by user.';
        });
      }
    } on SocketException catch (e) {
      print("Network error: $e");
      setState(() {
        _uploadStatus =
            'Upload failed: Network error. Please check your internet connection.';
        _uploadProgress = 0.0; // Reset progress on failure
      });
    } on TimeoutException catch (e) {
      print("Timeout error: $e");
      setState(() {
        _uploadStatus =
            'Upload failed: Connection timed out. Please try again.';
        _uploadProgress = 0.0; // Reset progress on failure
      });
    } catch (e) {
      print("Unexpected error: $e");
      setState(() {
        _uploadStatus = 'Upload failed: Unexpected error';
        _uploadProgress = 0.0; // Reset progress on failure
      });
    } finally {
      timeoutTimer?.cancel(); // Cancel the timer after everything is done
    }
  }

  // Upload the local database file to Firebase Storage
  /*Future<void> uploadDatabaseToFirebase() async {
    File? dbFile = await _getLocalDatabaseFile();
    if (dbFile == null) {
      setState(() {
        _uploadStatus = "Failed to find the database file.";
      });
      return;
    }
    try {
      // String fileName = 'databases/${DateTime.now().millisecondsSinceEpoch}_database.db';
      String fileName = 'databases/$localFileName.json';
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);
      // Define metadata including upload time
      SettableMetadata metadata = SettableMetadata(
        customMetadata: {
          'uploadTime': DateTime.now().toIso8601String(),
        },
      );
      // Upload the file with metadata
      UploadTask uploadTask = firebaseStorageRef.putFile(dbFile, metadata);
      // Optionally, you can track the upload status
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadStatus =
              'Uploading: ${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes';
        });
      });
      // Wait for the upload to complete
      await uploadTask;
      // Get the download URL
      downloadURL = await firebaseStorageRef.getDownloadURL();
      setState(() {
        _uploadStatus = 'Upload complete! File URL: $downloadURL';
      });
      print("Database uploaded at: $downloadURL");
    } catch (e) {
      print("Failed to upload database: $e");
      setState(() {
        _uploadStatus = 'Upload failed: $e';
      });
    }
  }*/
  //delete file more than 1 hour
  /*Future<void> deleteOldFiles() async {
    try {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('databases/');
      final ListResult result = await storageRef.listAll();
      final now = DateTime.now().millisecondsSinceEpoch;
      const oneHourInMs = 60 * 60;

      for (var item in result.items) {
        final metadata = await item.getMetadata();
        final uploadTimeStr = metadata.customMetadata?['uploadTime'];

        if (uploadTimeStr != null) {
          try {
            final uploadTime =
                DateTime.parse(uploadTimeStr).millisecondsSinceEpoch;

            if (now - uploadTime > oneHourInMs) {
              await item.delete();
              print("Deleted old file: ${item.name}");
            }
          } catch (e) {
            print(
                "Error parsing upload time for file: ${item.name}. Error: $e");
          }
        } else {
          print("Upload time metadata not found for file: ${item.name}");
        }
      }
    } catch (e) {
      print("Error deleting files: $e");
    }
  }*/

  //make data into file
  /*Future<void> _exportData() async {
    try {
      */
  /*setState(() {
        preparingData = true;
      });*/
  /*

      // Read data from multiple tables
      final apartmentsData = await sqlDb.getDataFromTable('Apartments');
      final roomsData = await sqlDb.getDataFromTable('Rooms');
      final devicesData = await sqlDb.getDataFromTable('Devices');

      // Combine data from multiple tables
      final Map<String, dynamic> allData = {
        'Apartments': apartmentsData,
        'Rooms': roomsData,
        'Devices': devicesData,
      };

      // Convert combined data to JSON
      final jsonData = convertDataToJson(allData);

      // Save JSON data to a file
      await saveJsonToFile(jsonData);

      setState(() {
        _status = 'Data exported successfully!';
        */
  /*preparingData = false;*/ /*
      });
    } catch (e) {
      setState(() {
        _status = 'Error exporting data: $e';
      });
    }
  }*/

  /*String convertDataToJson(Map<String, dynamic> data) {
    return jsonEncode(data);
  }*/

  /*Future<void> saveJsonToFile(String jsonData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$localFileName.json');

    // Upload the JSON file to Firebase (optional)
    uploadDatabaseToFirebase();

    // Save the file locally
    await file.writeAsString(jsonData);
    print("JSON file saved to ${file.path}");
  }*/

  //file in app directory
  /*Future<void> listFilesInAppDirectory() async {
    try {
      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();

      // Get the list of files in the directory
      List<FileSystemEntity> files = directory.listSync();

      // Print the file names
      files.forEach((file) {
        // Check if it's a file, not a directory
        if (file is File) {
          print("File: ${file.path.split('/').last}");  // Print file name
        }
      });
    } catch (e) {
      print("Error retrieving files: $e");
    }
  }*/

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
          'Create QR Code',
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
              _uploadProgress == 0.0 || downloadURL.isEmpty
                  ? uploadFailed
                      ? const SizedBox()
                      : const CircularProgressIndicator(
                          color: Color(0xFF047424))
                  : QrImageView(
                      data: downloadURL,
                      version: QrVersions.auto,
                      size: 200.0,
                foregroundColor: isDarkMode?Colors.grey.shade400:Colors.grey.shade800,
                    ),
              const SizedBox(height: 20),
              Text(
                _uploadStatus == null ? '' : '$_uploadStatus',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF047424)),
                textAlign: TextAlign.center,
              ),
              /*if (downloadURL.isEmpty)
                const Column(children: [
                  LinearProgressIndicator(),
                  Text('preparing the data'),
                ]),
              Visibility(
                visible: downloadURL.isNotEmpty,
                child: QrImageView(
                  data: downloadURL,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
