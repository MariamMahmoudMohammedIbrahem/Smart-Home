import '../commons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    // Shared content for both iOS and Android
    final content = SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.07),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Animated GIF illustration
            Flexible(
              child: Image.asset(
                'assets/images/light-control-light.gif',
              ),
            ),

            // Welcome text
            const Column(
              children: [
                AutoSizeText(
                  'Welcome to GlowGrid!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  minFontSize: 22,
                  maxFontSize: 24,
                ),
                AutoSizeText(
                  'your ultimate LED lighting control solution! '
                      'Effortlessly customize your space with vibrant colors and dynamic effects. '
                      'Transform your home into a captivating oasis of light and ambiance.',
                  textAlign: TextAlign.center,
                  minFontSize: 18,
                  maxFontSize: 20,
                ),
              ],
            ),

            // "Get Started" button
            Column(
              children: [
                SizedBox(
                  width: width * 0.6,
                  child: Platform.isIOS
                      ? CupertinoButton(
                    color: MyColors.greenDark2,
                    onPressed: _handleGetStarted,
                    child: const AutoSizeText(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      minFontSize: 18,
                      maxFontSize: 20,
                    ),
                  )
                      : ElevatedButton(
                    onPressed: _handleGetStarted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.greenDark2,
                      foregroundColor: MyColors.greenLight2,
                    ),
                    child: const AutoSizeText(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      minFontSize: 18,
                      maxFontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    /// Return platform-specific scaffold
    /// both share the same content
    return Platform.isIOS
        ? CupertinoPageScaffold(child: content)
        : Scaffold(body: content);
  }

  /// Handles the "Get Started" button logic:
  /// - Marks the app as no longer first-time
  /// - Inserts default apartment
  /// - Reloads apartments list
  /// - Navigates to the Rooms screen if not first-time anymore
  void _handleGetStarted() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    authProvider.setFirstTime().then((_) {
      insertApartment('My Home').then((_) {
        getAllApartments().then((_) {
          final firstTimeCheck = authProvider.firstTimeCheck;

          if (!firstTimeCheck) {
            if(!mounted) return;
            Navigator.pushReplacement(
              context,
              Platform.isIOS
                  ? CupertinoPageRoute(builder: (_) => const RoomsScreen())
                  : MaterialPageRoute(builder: (_) => const RoomsScreen()),
            );
          }
        });
      });
    });
  }

/*Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Platform.isIOS
        ?CupertinoPageScaffold(
          child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * .07,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: Image.asset(
                    'assets/images/light-control-light.gif',
                  ),
                ),
                const Column(
                  children: [
                    AutoSizeText(
                      'Welcome to GlowGrid!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      minFontSize: 22,
                      maxFontSize: 24,
                    ),
                    AutoSizeText(
                      'your ultimate LED lighting control solution! Effortlessly customize your space with vibrant colors and dynamic effects. Transform your home into a captivating oasis of light and ambiance.',
                      textAlign: TextAlign.center,
                      minFontSize: 18,
                      maxFontSize: 20,
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: width * .6,
                      child: CupertinoButton(
                        color: MyColors.greenDark2,
                        onPressed: () {
                          Provider.of<AuthProvider>(context, listen: false)
                              .setFirstTime()
                              .then((value) {
                            insertApartment('My Home').then(
                                  (value) => getAllApartments().then((value) {
                                final firstTimeCheck =
                                    Provider.of<AuthProvider>(context,
                                        listen: false)
                                        .firstTimeCheck;
                                if (!firstTimeCheck) {
                                  Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                      const RoomsScreen(),
                                    ),
                                  );
                                }
                              }),
                            );
                          });
                        },
                        child: const AutoSizeText(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          minFontSize: 18,
                          maxFontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        )
        :Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * .07,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Image.asset(
                      'assets/images/light-control-light.gif',
                    ),
                  ),
                  const Column(
                    children: [
                      AutoSizeText(
                        'Welcome to GlowGrid!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        minFontSize: 22,
                        maxFontSize: 24,
                      ),
                      AutoSizeText(
                        'your ultimate LED lighting control solution! Effortlessly customize your space with vibrant colors and dynamic effects. Transform your home into a captivating oasis of light and ambiance. ',
                        textAlign: TextAlign.center,
                        minFontSize: 18,
                        maxFontSize: 20,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: width * .6,
                        child: ElevatedButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false)
                                .setFirstTime()
                                .then((value) {
                              insertApartment('My Home').then(
                                      (value) => getAllApartments().then((value) {
                                    final firstTimeCheck =
                                        Provider.of<AuthProvider>(context,
                                            listen: false)
                                            .firstTimeCheck;
                                    if (!firstTimeCheck) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const RoomsScreen(),
                                        ),
                                      );
                                    }
                                  }));
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.greenDark2,
                            foregroundColor: MyColors.greenLight2,
                          ),
                          child: const AutoSizeText(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            minFontSize: 18,
                            maxFontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
  }*/
}
