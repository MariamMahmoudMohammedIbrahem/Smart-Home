import '../commons.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      title: "What should I do if my device does not connect?",
      description:
          "Double-check Wi-Fi credentials and ensure you are on the same network as the device.",
    ),
    FAQItem(
      title: "How do I delete a device?",
      description:
          "Long Press on the device in the room view and select the delete option.",
      customSubtitle: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
          children: [
            const TextSpan(
              text: "Long Press on the device in the room view and select the ",
            ),
            const TextSpan(
              text: "\"",
              style: TextStyle(
                color: MyColors.greenDark1,
                fontWeight: FontWeight.bold,
              ),
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Platform.isIOS ? CupertinoIcons.delete : Icons.delete,
                size: 18,
                color: MyColors.greenDark1,
              ),
            ),
            const TextSpan(
              text: " Delete\"",
              style: TextStyle(
                color: MyColors.greenDark1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: " option."),
          ],
        ),
      ),
    ),
    FAQItem(
      title: "How do I add a new device or room to the grid?",
      customSubtitle: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
          children: [
            const TextSpan(text: "Tap the "),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Platform.isIOS ? CupertinoIcons.settings : Icons.settings,
                size: 18,
                color: MyColors.greenDark1,
              ),
            ),
            const TextSpan(
              text: " button at the top/right of the screen. Then tap on",
            ),
            const TextSpan(
              text: " \"Add New Device\"",
              style: TextStyle(
                color: MyColors.greenDark1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text:
                  ".\nBy following the steps declared, you will be able to add a new device to a new or existing room.",
            ),
          ],
        ),
      ),
    ),
    // ...continue adding other items
    FAQItem(
      title: "Can I edit or rename a room?",
      customSubtitle: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
          children: [
            const TextSpan(text: "Yes. Tap and hold any room, then choose "),
            const TextSpan(
              text: "\"",
              style: TextStyle(
                color: MyColors.greenDark1,
                fontWeight: FontWeight.bold,
              ),
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.edit, size: 18, color: MyColors.greenDark1),
            ),
            const TextSpan(
              text: " Edit\"",
              style: TextStyle(
                color: MyColors.greenDark1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: ". You can change its name and icon."),
          ],
        ),
      ),
    ),
    FAQItem(
      title: "Why isn't my room responding when I tap it?",
      description:
          "Ensure the room is properly configured. "
          "If it's linked to at least a device, check the device connection. \n"
          "For non-functional rooms, delete them and try to reconfigure them.",
    ),
    FAQItem(
      title: "Can I change the icon of a room after creating it?",
      customSubtitle: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
          children: [
            const TextSpan(text: "Yes! Tap and hold the tile, then select "),
            const TextSpan(
              text: "\"",
              style: TextStyle(
                color: MyColors.greenDark1,
                fontWeight: FontWeight.bold,
              ),
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.edit, size: 18, color: MyColors.greenDark1),
            ),
            const TextSpan(
              text: " Edit\"",
              style: TextStyle(
                color: MyColors.greenDark1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: " and pick a new icon from the list."),
          ],
        ),
      ),
    ),
    FAQItem(
      title: "Can I change the color or style of grid tiles?",
      description:
          "Currently, you can customize icons and names. "
          "Advanced styling like colors and themes will be added in future updates.",
    ),
    FAQItem(
      title: "How do I back up or restore my grid layout?",
      description:
          "GlowGrid doesn't use automatic backups, but you can manually transfer your data between devices.\n"
          "Just export the data from one device and import it on another. "
          "This is useful if you're switching phones or resetting a device.",
    ),
    FAQItem(
      title: "Why do I get an error when trying to save changes?",
      description:
          "Make sure you’ve filled out all required fields (e.g., name, icon). \n"
          "If the issue persists, restarting the app usually fixes temporary glitches.",
    ),
    FAQItem(
      title: "Can I create automations like \"Turn on all lights at night\"?",
      description:
          "Automation features are under development. "
          "For now you can control the switches when you want",
    ),
  ];

  // A list to track which FAQ item is expanded
  late List<bool> _expanded;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // check platform to choose correct widget
    final bool isIos = Platform.isIOS;

    /// Builds the platform-specific FAQ screen layout.
    ///
    /// Uses `CupertinoPageScaffold` for iOS and `Scaffold` for other platforms.
    /// Both layouts share the same body content via `scaffoldBody(isDarkMode)`,
    /// but use platform-specific AppBar styles and navigation elements.
    return isIos
        ? CupertinoPageScaffold(
      navigationBar: buildCupertinoNavBar("FAQs", context),
      child: scaffoldBody(isDarkMode),
    )
        : Scaffold(
      appBar: buildMaterialAppBar("FAQs"),
      body: scaffoldBody(isDarkMode),
    );

  }

  @override
  void initState() {
    super.initState();

    _expanded = List.generate(_faqItems.length, (_) => false);
  }

  /// Builds the scrollable body for the FAQ screen.
  ///
  /// Displays a vertical list of expandable FAQ items inside styled containers.
  /// Each item uses `_buildListTile` to render platform-specific list tiles
  /// with expand/collapse behavior. List appearance adapts based on the theme mode.
  Widget scaffoldBody(bool isDarkMode) {
    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: _faqItems.length,
        itemBuilder: (context, index) {
          final item = _faqItems[index];

          return buildStyledFaqContainer(
            context: context,
            isDarkMode: isDarkMode,
            child: _buildListTile(
              context,
              index: index,
              title: item.title,
              description: item.description,
              customSubtitle: item.customSubtitle,
            ),
          );
        },
      ),
    );
  }

  /// Builds a rounded container with themed border around a child widget.
  ///
  /// Useful for wrapping FAQ list tiles with consistent padding, margin,
  /// and border styling that adapts to dark/light mode.
  Widget buildStyledFaqContainer({
    required BuildContext context,
    required bool isDarkMode,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 16.0,
      ),
      padding: const EdgeInsets.only(left: 4.0, top: 4.0,),
      decoration: faqContainerDecoration(context, isDarkMode),
      child: child,
    );
  }


  /// Builds a platform-adaptive, expandable list tile for an FAQ item.
  ///
  /// On iOS, uses `CupertinoListTile` for a native Cupertino look.
  /// On Android and others, uses `ListTile` with Material styling.
  ///
  /// Each tile can expand or collapse to reveal additional information,
  /// using `AnimatedCrossFade` for smooth UI transitions.
  Widget _buildListTile(
    BuildContext context, {
    required int index,
    required String title,
    String? description,
    Widget? customSubtitle,
  }) {
    final bool isIOS = Platform.isIOS;
    final bool isExpanded = _expanded[index];

    // Subtitle widget shown/hidden with animation
    final Widget descriptionWidget = AnimatedCrossFade(
      firstChild: const SizedBox.shrink(), // When collapsed
      secondChild: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child:
            customSubtitle ??
            RichText(
              text: TextSpan(
                text:description ?? '',
                style: subtitleTextStyle,
              ),
              maxLines: 10,
            ),
      ),
      crossFadeState:
          isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst, // Toggle visibility
      duration: const Duration(milliseconds: 200), // Smooth animation duration
    );

    // Handles tapping the tile to toggle expansion
    onTap() {
      setState(() {
        _expanded[index] = !_expanded[index];
      });
    }

    // Return platform-specific list tile with shared content
    return isIOS
        ? CupertinoListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleTextStyle, maxLines: 5,),
              descriptionWidget,
            ],
          ),
          onTap: onTap,
        )
        : ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleTextStyle, maxLines: 5,),
              descriptionWidget,
            ],
          ),
          onTap: onTap,
        );
  }
}
