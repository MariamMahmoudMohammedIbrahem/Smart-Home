import 'commons.dart';

class GlowGrid extends StatelessWidget {
  const GlowGrid({super.key});

  @override
  Widget build(BuildContext context) {
    isConnectedToInternet().then((value) => {if(value){
      checkFirmwareVersion('firmware-update/switch', 'firmware_version.txt', context)}});

    return Platform.isIOS
        ? CupertinoApp(
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      theme: Provider.of<AuthProvider>(context).isDarkMode
          ? cupertinoDarkTheme
          : cupertinoLightTheme,
      title: 'GlowGrid',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    )
        : MaterialApp(
      theme: materialLightTheme,
      darkTheme: materialDarkTheme,
      navigatorObservers: [],
      themeMode: Provider.of<AuthProvider>(context).isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      title: 'GlowGrid',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
