import '../commons.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Begin app initialization logic
    _initializeApp();
  }

  /// Initializes the app by:
  /// - Applying the saved or default theme
  /// - Fetching apartment data and MAC addresses
  /// - Checking if it's the user's first time using the app
  /// - Navigating to Onboarding or Rooms screen after a short splash delay
  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Set app theme from storage or defaults
    authProvider.checkTheme();

    // Load apartments and network data (e.g. MAC addresses)
    await getAllApartments();
    await getAllMacAddresses();

    // Wait until the current frame is rendered before continuing
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check if this is the user's first time opening the app
      await authProvider.checkFirstTime();
      final isFirstTime = authProvider.firstTimeCheck;

      // Delay for splash effect before navigating
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
            isFirstTime ? const OnboardingScreen() : const RoomsScreen(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Shared splash UI used for both iOS and Android
    final splashWidget = Center(
      child: Image.asset(
        'assets/images/splash.gif',
      ),
    );

    /// Builds platform-specific scaffold
    /// Both scaffolds share common content `splashWidget`
    return Platform.isIOS
        ? CupertinoPageScaffold(
      backgroundColor: MyColors.greenDark1,
      child: splashWidget,
    )
        : Scaffold(
      backgroundColor: MyColors.greenDark1,
      body: splashWidget,
    );
  }
}
