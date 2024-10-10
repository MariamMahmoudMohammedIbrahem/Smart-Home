import 'package:flutter/material.dart';
import 'package:mega/ui/upload_file.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../db/functions.dart';
import '../udp.dart';
import 'download_file.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Theme'),
            trailing: Switch(
                activeColor: const Color(0xFF609e51),
                activeTrackColor:
                const Color(0xFF047424),
                inactiveThumbColor:
                Colors.grey.shade300,
                inactiveTrackColor:
                Colors.grey.shade800,
                value: isDarkMode ?? false,
                onChanged: (value) {
                  // setState(() {
                    /*Provider.of<AuthProvider>(context, listen: false)
                        .toggling('darkMode', value);*/
                    Provider.of<AuthProvider>(context, listen: false)
                        .setTheme(value);
                  // });
                }),
          ),
          ListTile(
            title: const Text('Add New Device'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false)
                  .toggling('adding', false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UDPScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Create QR Code'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false)
                  .checkFirstTime()
                  .then((value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UploadDatabase(),
                      )));
            },
          ),
          ListTile(
            title: const Text('Scan QR Code'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanPage(),
                  ));
            },
          ),
          /*ListTile(
            title: const Text('Manage Devices'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Help and Support'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {},
          ),*/
        ],
      ),
    );
  }
}
