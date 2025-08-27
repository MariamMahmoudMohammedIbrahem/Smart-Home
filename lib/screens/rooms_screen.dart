import '../commons.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen>
    with SingleTickerProviderStateMixin{

  /// Returns the current apartment name or a default
  String get apartmentName =>
      apartmentMap.isNotEmpty ? apartmentMap.first['ApartmentName'] : 'My Home';
  late NetworkService _networkService;

  /// Returns the settings icon button for both Cupertino and Material
  Widget buildSettingsIconButton(BuildContext context, AuthProvider toggleProvider, bool isCupertino) {
    final icon = isCupertino
        ? CupertinoIcons.settings
        : Icons.settings_rounded;

    final iconWidget = Icon(icon, color: MyColors.greenDark1);

    final buttonIcon = toggleProvider.notificationMark
        ? Badge(
      label: null,
      backgroundColor: Colors.red,
      child: iconWidget,
    )
        : iconWidget;

    return IconButton(
      onPressed: () {
        getAllMacAddresses().then(
              (value) => Navigator.push(
            context,
            isCupertino
                ? CupertinoPageRoute(builder: (_) => const SettingsScreen())
                : MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        );
      },
      icon: buttonIcon,
    );
  }

  /// Builds CupertinoNavigationBar
  ObstructingPreferredSizeWidget? buildCupertinoNavBar() {
    return CupertinoNavigationBar(
      leading: Text(apartmentName, style: cupertinoNavTitleStyle),
      trailing: Consumer<AuthProvider>(
        builder: (context, toggleProvider, _) =>
            buildSettingsIconButton(context, toggleProvider, true),
      ),
    );
  }

  /// Builds Material AppBar
  PreferredSizeWidget buildMaterialAppBar() {
    return AppBar(
      shape: appBarShape,
      title: Text(apartmentName),
      titleTextStyle: cupertinoNavTitleStyle,
      actions: [
        Consumer<AuthProvider>(
          builder: (context, toggleProvider, _) =>
              buildSettingsIconButton(context, toggleProvider, false),
        ),
      ],
    );
  }

  @override
  Widget build(context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: buildCupertinoNavBar(),
      child:  scaffoldBody(width, height, isDarkMode),
    )
        : Scaffold(
        appBar: buildMaterialAppBar(),
        body: scaffoldBody(width, height, isDarkMode)
    );
  }

  @override
  void initState() {
    _networkService = NetworkService();
    _networkService.startMonitoring(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SocketManager().startListen(context);
    });
    getRoomsByApartmentID(context, apartmentMap.first['ApartmentID'])
        .then((value) {
      setState(() {
        Provider.of<AuthProvider>(context, listen: false).toggling(
          'loading',
          false,
        );
      });
    });
    super.initState();
  }

  Widget scaffoldBody(double width, double height, bool isDarkMode) {
    final isIos = Platform.isIOS;
    final textColor = isDarkMode ? MyColors.greenDark1 : Colors.white;
    final containerColor = isDarkMode ? Colors.transparent : Theme.of(context).primaryColor;
    final borderStyle = isDarkMode ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .05, vertical: 10),
        child: Column(
          children: [
            _buildHeader(width, isIos),
            if (Provider.of<AuthProvider>(context, listen: false).socketBindFailed)
              Container(
                padding: EdgeInsets.symmetric(horizontal: width*.07, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),   // light red background
                  border: Border.all(color: Colors.red), // red border
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Failed to bind to port. Another app may be using it.",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Consumer<AuthProvider>(
              builder: (context, loadingProvider, _) {
                if (loadingProvider.isLoading) {
                  return Flexible(
                    child: Center(
                      child: isIos
                          ? CupertinoActivityIndicator(color: MyColors.greenDark1)
                          : const CircularProgressIndicator(color: MyColors.greenDark1),
                    ),
                  );
                }

                if (rooms.isEmpty) {
                  return const Flexible(
                    child: Center(
                      child: Text(
                        'There is no data to show',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: MyColors.greenDark1,
                        ),
                      ),
                    ),
                  );
                }

                final toggle = Provider.of<AuthProvider>(context).toggle;

                return Flexible(
                  child: toggle
                      ? _buildGridView(width, textColor, containerColor, borderStyle, isDarkMode, isIos)
                      : _buildListView(width, textColor, containerColor, borderStyle, isDarkMode, isIos),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double width, bool isIos) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Rooms',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 26,
            color: MyColors.greenDark1,
          ),
        ),
        Consumer<AuthProvider>(
          builder: (context, toggleProvider, _) {
            return IconButton(
              onPressed: () {
                toggleProvider.toggling('toggling', !toggleProvider.toggle);
              },
              icon: Icon(
                toggleProvider.toggle
                    ? Icons.grid_view_rounded
                    : (isIos ? CupertinoIcons.list_bullet : Icons.list_outlined),
                color: MyColors.greenDark1,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGridView(double width, Color textColor, Color containerColor, BoxBorder? borderStyle, bool isDarkMode, bool isIos) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width * 0.45,
        mainAxisSpacing: 15.0,
        crossAxisSpacing: 15.0,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        return _roomTile(
          context: context,
          room: rooms[index],
          width: width,
          isGrid: true,
          textColor: textColor,
          containerColor: containerColor,
          borderStyle: borderStyle,
          isIos: isIos,
        );
      },
    );
  }

  Widget _buildListView(double width, Color textColor, Color containerColor, BoxBorder? borderStyle, bool isDarkMode, bool isIos) {
    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 8.0),
          child: _roomTile(
            context: context,
            room: rooms[index],
            width: width,
            isGrid: false,
            textColor: textColor,
            containerColor: containerColor,
            borderStyle: borderStyle,
            isIos: isIos,
          ),
        );
      },
    );
  }

  Widget _roomTile({
    required BuildContext context,
    required dynamic room,
    required double width,
    required bool isGrid,
    required Color textColor,
    required Color containerColor,
    required BoxBorder? borderStyle,
    required bool isIos,
  }) {
    final content = isGrid
        ? Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: AutoSizeText(
            room.name,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            minFontSize: 23.0,
            maxFontSize: 25.0,
            maxLines: 2,
          ),
        ),
        Icon(room.icon, color: textColor, size: width * .25),
      ],
    )
        : Row(
      children: [
        Icon(room.icon, color: textColor, size: 30),
        const SizedBox(width: 5),
        AutoSizeText(
          room.name,
          style: TextStyle(fontSize: 18.0, color: textColor, fontWeight: FontWeight.bold),
          minFontSize: 16.0,
          maxFontSize: 18.0,
          maxLines: 2,
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        getDeviceDetailsByRoomID(room.id!).then((value) {
          Navigator.push(
            context,
            isIos
                ? CupertinoPageRoute(builder: (_) => RoomDetailsScreen(roomDetail: room))
                : MaterialPageRoute(builder: (_) => RoomDetailsScreen(roomDetail: room)),
          );
        });
      },
      onLongPress: () => isIos? showCupertinoCustomizedOptions(context, rooms.indexOf(room)): showMaterialCustomizedOptions(context, rooms.indexOf(room)),
      child: Container(
        height: isGrid ? null : 50.0,
        decoration: BoxDecoration(
          color: containerColor,
          border: borderStyle,
          borderRadius: BorderRadius.circular(25.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: isGrid ? 0 : 15),
        child: Center(child: content),
      ),
    );
  }

}