import 'package:flutter/material.dart';
import 'package:mega/screens/export_data_screen.dart';
import 'package:mega/screens/firmware_updating_screen.dart';
import 'package:mega/screens/support_screen.dart';
import 'package:provider/provider.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../constants/constants.dart';
import '../utils/functions.dart';
import 'device_configuration_screen.dart';
import 'import_data_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
          'Settings',
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
                value: isDarkMode,
                onChanged: (value) {
                  Provider.of<AuthProvider>(context, listen: false)
                      .setTheme(value);
                }),
          ),
          ListTile(
            title: const Text(
              'Add New Device',
            ),
            // trailing: const Icon(Icons.arrow_right,),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).toggling(
                'adding',
                false,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeviceConfigurationScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Export Data',
            ),
            // trailing: const Icon(Icons.arrow_right,),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false)
                  .checkFirstTime()
                  .then(
                    (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExportDataScreen(),
                      ),
                    ),
                  );
            },
          ),
          ListTile(
            title: const Text(
              'Import Data',
            ),
            // trailing: const Icon(Icons.arrow_right,),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImportDataScreen(),
                ),
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, firmwareUpdating, child) {
              return ListTile(
                title: const Text('Firmware Updating'),
                trailing: firmwareUpdating.notificationMark
                    ? const CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.red,
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FirmwareScreen(),
                      ));
                },
              );
            },
          ),
          ListTile(
            title: const Text('Help and Support'),
            // trailing: const Icon(Icons.arrow_right,),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportScreen(),
                  ));
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    getWifiNetworks();
    super.initState();
  }

  Future<void> getWifiNetworks() async {
    List<WifiNetwork?> networks = await WiFiForIoTPlugin.loadWifiList();
    setState(() {
      wifiNetworks = networks;
    });
    print(networks);
  }
}
