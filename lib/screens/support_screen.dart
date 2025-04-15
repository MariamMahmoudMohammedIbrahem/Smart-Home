import '../commons.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // A list to track which FAQ item is expanded
  final List<bool> _expanded = [false, false];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Platform.isIOS?
        CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: CupertinoNavigationBarBackButton(
              color: MyColors.greenDark1, // Set the back arrow color
              onPressed: () {
                Navigator.pop(context); // Pop to go back to the previous screen
              },
            ),
            middle: Text(
              'FAQs',
              style: TextStyle(
                color: MyColors.greenDark1,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: isDarkMode ?Theme.of(context).primaryColor :CupertinoColors.systemGrey5,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: _buildCupertinoListTile(
                    context,
                    index: 0,
                    title: 'What should I do if my device does not connect?',
                    description:
                    'Double-check Wi-Fi credentials and ensure you are on the same network as the device.',
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: isDarkMode ?Theme.of(context).primaryColor :CupertinoColors.systemGrey5,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: _buildCupertinoListTile(
                    context,
                    index: 1,
                    title: 'How do I delete a device?',
                    description:
                    'Long Press on the device in the room view and select the delete option.',
                  ),
                ),
              ],
            ),
          ),
        ),)
        :Scaffold(
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
          'Help and Support',
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            ExpansionTile(
              title: Text(
                'What should I do if my device does not connect?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: MyColors.greenDark1,
                ),
              ),
              collapsedShape: RoundedRectangleBorder(
                side: BorderSide.none,
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
              ),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Double-check Wi-Fi credentials and ensure you are on the same network as the device.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'How do I delete a device?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: MyColors.greenDark1,
                ),
              ),
              collapsedShape: RoundedRectangleBorder(
                side: BorderSide.none,
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
              ),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Long Press on the device in the room view and select the delete option.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertinoListTile(
      BuildContext context, {
        required int index,
        required String title,
        required String description,
      }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: CupertinoListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19,
            color: MyColors.greenDark1, // Use your custom colors here
          ),
          maxLines: 5,
        ),
        subtitle: _expanded[index]
            ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            description,
            style: TextStyle(fontSize: 16),
            maxLines: 5,
          ),
        )
            : null,
        onTap: () {
          setState(() {
            // Toggle the expanded state
            _expanded[index] = !_expanded[index];
          });
        },
      ),
    );
  }

  /*// This method is used to show a CupertinoDialog when the user taps on a tile.
  void _showCupertinoDialog(BuildContext context, String description) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Information'),
          content: Text(description),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }*/
}
