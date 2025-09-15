import '../commons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) getWifiNetworks(); // Prefetch WiFi networks on Android
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: buildCupertinoNavBar("Settings", context),
      child: SafeArea(
          child: _buildSettingsList(context, isDarkMode, true)
      ),
    )
        : Scaffold(
      appBar: buildMaterialAppBar("Settings"),
      body: _buildSettingsList(context, isDarkMode, false),
    );
  }

  /// Shared settings list (used by both Android and iOS)
  Widget _buildSettingsList(BuildContext context, bool isDarkMode, bool isIOS) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return ListView(
      children: [
        _buildSwitchTile(
          title: 'Dark Theme',
          value: isDarkMode,
          onChanged: (value) => authProvider.setTheme(value),
          isIOS: isIOS,
        ),
        _buildTapTile(
          title: 'Add New Device',
          onTap: () {
            authProvider.toggling('adding', false);
            if (!isIOS) getWifiNetworks(); // Only fetch WiFi on Android
            promptEnableLocation(context, () {
              Navigator.push(
                context,
                isIOS
                    ? CupertinoPageRoute(
                    builder: (_) => const DeviceConfigurationScreen())
                    : MaterialPageRoute(
                    builder: (_) => const DeviceConfigurationScreen()),
              );
            });
          },
          isIOS: isIOS,
        ),
        _buildTapTile(
          title: 'Export Data',
          onTap: () {
            authProvider.checkFirstTime().then((_) {
              if(!context.mounted) return;
              Navigator.push(
                context,
                isIOS
                    ? CupertinoPageRoute(
                    builder: (_) => const ExportDataScreen())
                    : MaterialPageRoute(
                    builder: (_) => const ExportDataScreen()),
              );
            });
          },
          isIOS: isIOS,
        ),
        _buildTapTile(
          title: 'Import Data',
          onTap: () {
            Navigator.push(
              context,
              isIOS
                  ? CupertinoPageRoute(builder: (_) => const ImportDataScreen())
                  : MaterialPageRoute(builder: (_) => const ImportDataScreen()),
            );
          },
          isIOS: isIOS,
        ),
        Consumer<AuthProvider>(
          builder: (context, firmwareUpdating, _) {
            return _buildTapTile(
              title: 'Firmware Updating',
              trailing: firmwareUpdating.notificationMark
                  ? const CircleAvatar(radius: 5, backgroundColor: Colors.red)
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  isIOS
                      ? CupertinoPageRoute(builder: (_) => const FirmwareScreen())
                      : MaterialPageRoute(
                      builder: (_) => const FirmwareScreen()),
                );
              },
              isIOS: isIOS,
            );
          },
        ),
        _buildTapTile(
          title: 'FAQs',
          onTap: () {
            Navigator.push(
              context,
              isIOS
                  ? CupertinoPageRoute(builder: (_) => const SupportScreen())
                  : MaterialPageRoute(builder: (_) => const SupportScreen()),
            );
          },
          isIOS: isIOS,
        ),
      ],
    );
  }

  /// Reusable switch tile (Dark Theme)
  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isIOS,
  }) {
    return isIOS
        ? Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(title),
        trailing: CupertinoSwitch(value: value, onChanged: onChanged),
      ),
    )
        : ListTile(
      title: Text(title),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  /// Reusable tap tile for navigation actions
  Widget _buildTapTile({
    required String title,
    required VoidCallback onTap,
    bool isIOS = false,
    Widget? trailing,
  }) {
    final tile = ListTile(
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );

    return isIOS
        ? Material(color: Colors.transparent, child: tile)
        : tile;
  }

/*@override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          color: MyColors.greenDark1, // Set the back arrow color
          onPressed: () => Navigator.pop(context),
        ),
        middle: Text(
          'Settings',
          style: cupertinoNavTitleStyle,
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
        shape: appBarShape,
        title: const Text('Settings'),
        titleTextStyle: materialNavTitleTextStyle,
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
              Provider.of<AuthProvider>(context, listen: false)
                  .toggling('adding', false);
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
            title: const Text('FAQs'),
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
    super.initState();
    if (Platform.isAndroid) getWifiNetworks();
  }*/
}