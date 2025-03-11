import '../commons.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.greenDark1,
      body: Center(
        child: Image.asset(
          'assets/images/loading-animate.gif',
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<AuthProvider>(context, listen: false)
        .checkTheme();
    startListeningForNetworkChanges();
    getAllApartments().then((value) => {
      getAllMacAddresses().then(
            (value) => WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<AuthProvider>(context, listen: false)
              .checkFirstTime()
              .then((_) {
            final firstTimeCheck =
                Provider.of<AuthProvider>(context, listen: false)
                    .firstTimeCheck;
            Future.delayed(const Duration(seconds: 5), () {
              if (firstTimeCheck) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoomsScreen(),
                  ),
                );
              }
            });
          });
        }),
      ),
    });
  }
}
