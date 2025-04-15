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
    return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          color: MyColors.greenDark1, // Set the back arrow color
          onPressed: () {
            Navigator.pop(context); // Pop to go back to the previous screen
          },
        ),
        middle: Text(
          'Settings',
          style: TextStyle(
            color: MyColors.greenDark1,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            Material(
              color: Colors.transparent,
              child: ListTile(
                title: const Text('Dark Theme'),
                trailing: CupertinoSwitch(
                    value: isDarkMode,
                    onChanged: (value) {
                      Provider.of<AuthProvider>(context, listen: false)
                          .setTheme(value);
                    }),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                title: const Text('Add New Device'),
                onTap: () {
                  Provider.of<AuthProvider>(context, listen: false)
                      .toggling('adding', false);
                  promptEnableLocation(context, (){
                    Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const DeviceConfigurationScreen(),
                    ),
                  );}
                  );

                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                title: const Text('Export Data'),
                onTap: () {
                  Provider.of<AuthProvider>(context, listen: false)
                      .checkFirstTime()
                      .then(
                        (value) => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const ExportDataScreen(),
                      ),
                    ),
                  );
                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                title: const Text('Import Data'),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const ImportDataScreen(),
                    ),
                  );
                },
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, firmwareUpdating, child) {
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
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
                        CupertinoPageRoute(
                          builder: (context) => const FirmwareScreen(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                title: const Text('FAQs'),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const SupportScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
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
        title: const Text('Settings'),
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
              },
            ),
          ),
          ListTile(
            title: const Text('Add New Device'),
            onTap: () {
              getWifiNetworks();
              print("1");
              Provider.of<AuthProvider>(context, listen: false)
                  .toggling('adding', false);
              print("2");
              promptEnableLocation(context, (){
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeviceConfigurationScreen(),
                ),
              );});
            },
          ),
          ListTile(
            title: const Text('Export Data'),
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
            title: const Text('Import Data'),
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
                    ),
                  );
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
                ),
              );
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
}
