import '../commons.dart';

/// Contains shared text styles, decorations, and shape configurations
/// used throughout the support screen and other UI elements.

/// Cupertino navigation bar title style (iOS only)
const cupertinoNavTitleStyle = TextStyle(
  color: MyColors.greenDark1,
  fontSize: 26,
  fontWeight: FontWeight.bold,
);

/// Material navigation bar title text style (Android only)
const materialNavTitleTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 26,
  fontWeight: FontWeight.bold,
);

/// FAQ item title style (used in both iOS and Android)
const titleTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 18,
  color: MyColors.greenDark1,
);

/// FAQ item subtitle style (description text)
const subtitleTextStyle = TextStyle(
  fontSize: 16,
  color: CupertinoColors.systemGrey,
);

/// Custom shape for Material AppBar (rounded bottom edges)
const appBarShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
);

/// BoxDecoration for each FAQ tile container
///
/// Applies a transparent background with a border color that changes
/// based on the app's current brightness mode.
BoxDecoration faqContainerDecoration(BuildContext context, bool isDarkMode) {
  return BoxDecoration(
    color: Colors.transparent,
    border: Border.all(
      color: isDarkMode
          ? Theme.of(context).primaryColor
          : CupertinoColors.systemGrey5,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(25.0),
  );
}