import '../commons.dart';

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
  }
}
