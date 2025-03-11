import 'commons.dart';

class GlowGrid extends StatelessWidget {
  const GlowGrid({super.key});

  @override
  Widget build(BuildContext context) {
    isConnectedToInternet().then((value) => {if(value){
      checkFirmwareVersion('firmware-update/switch', 'firmware_version.txt', context)}});
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<AuthProvider>(context).isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      title: 'GlowGrid',
      debugShowCheckedModeBanner: false,
      home: const LoadingScreen(),
    );
  }
}
