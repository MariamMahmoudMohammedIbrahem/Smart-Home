import '../commons.dart';
// Constants for Light and Dark Themes
const CupertinoThemeData cupertinoLightTheme = CupertinoThemeData(
  brightness: Brightness.light,
  primaryColor: MyColors.greenDark1,
  scaffoldBackgroundColor: Colors.white,
  textTheme: CupertinoTextThemeData(
    textStyle: TextStyle(color: Colors.black, fontSize: 16),
    actionTextStyle: TextStyle(color: MyColors.greenDark1),
    navTitleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
  ),
);

const CupertinoThemeData cupertinoDarkTheme = CupertinoThemeData(
  brightness: Brightness.dark,
  primaryColor: MyColors.greenDark1,
  scaffoldBackgroundColor: Colors.black,
  textTheme: CupertinoTextThemeData(
    textStyle: TextStyle(color: Colors.white, fontSize: 16),
    actionTextStyle: TextStyle(color: MyColors.greenDark1),
    navTitleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  barBackgroundColor: MyColors.greenDark1
);

// Custom Light Theme
ThemeData materialLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: MyColors.greenDark1,
  colorScheme: const ColorScheme.light(
    primary: MyColors.greenDark1,
    secondary: MyColors.greenDark1,
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  textTheme: TextTheme(
    bodyMedium: const TextStyle(color: Colors.black, fontSize: 16),
    bodySmall: TextStyle(color: Colors.grey[800]),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: MyColors.greenDark1,
    selectionHandleColor: Colors.green,
  ),
  switchTheme: SwitchThemeData(
    splashRadius: 50.0,
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return MyColors.greenLight2;
      }
      return Colors.grey.shade300;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return MyColors.greenDark1;
      }
      return Colors.grey.shade800;
    }),
  ),
);

// Custom Dark Theme
ThemeData materialDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: MyColors.greenDark1,
  colorScheme: const ColorScheme.dark(
    primary: MyColors.greenDark1,
    onPrimary: Colors.white,
    secondary: MyColors.greenDark1,
  ),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  textTheme: TextTheme(
    bodyMedium: const TextStyle(color: Colors.white, fontSize: 16),
    bodySmall: TextStyle(color: Colors.grey[300]),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: MyColors.greenDark1,
    selectionHandleColor: Colors.green,
  ),
  switchTheme: SwitchThemeData(
    splashRadius: 50.0,
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return MyColors.greenLight2;
      }
      return Colors.grey.shade300;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return MyColors.greenDark1;
      }
      return Colors.grey.shade800;
    }),
  ),
);