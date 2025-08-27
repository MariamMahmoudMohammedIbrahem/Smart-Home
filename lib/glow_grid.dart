import 'commons.dart';

class GlowGrid extends StatelessWidget {
  const GlowGrid({super.key});

  @override
  Widget build(BuildContext context) {

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
      title: 'Mega Touch',
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
      title: 'Mega Touch',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
