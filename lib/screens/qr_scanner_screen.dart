import 'package:glow_grid/commons.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String) onDetect;

  const QRScannerScreen({super.key, required this.onDetect});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  MobileScannerController cameraController = MobileScannerController();

  final double scanBoxSize = 300;

  @override
  void initState() {
    super.initState();

    // Scan line animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: _buildScannerStack(isCupertino: true),
    )
        : Scaffold(
      backgroundColor: Colors.black,
      body: _buildScannerStack(),
    );
  }

  /// Main QR scanner UI layout
  Widget _buildScannerStack({bool isCupertino = false}) {
    return Stack(
      children: [
        // Fullscreen camera preview
        MobileScanner(
          controller: cameraController,
          onDetect: (BarcodeCapture capture) {
            for (final barcode in capture.barcodes) {
              final String? code = barcode.rawValue;
              if (code != null) {
                widget.onDetect(code);
                break;
              }
            }
          },
        ),

        // Transparent overlay with hole
        Positioned.fill(
          child: CustomPaint(painter: CameraHolePainter(scanBoxSize)),
        ),

        // Top-left: Close/Cancel button
        Positioned(
          top: 50,
          left: 20,
          child: isCupertino
              ? _buildCupertinoIconButton(CupertinoIcons.clear, () => Navigator.pop(context))
              : _buildMaterialIconButton(Icons.close, () => Navigator.pop(context)),
        ),

        // Top-right: Switch camera
        Positioned(
          top: 50,
          right: 20,
          child: isCupertino
              ? _buildCupertinoIconButton(CupertinoIcons.camera_rotate, () => cameraController.switchCamera())
              : _buildMaterialIconButton(Icons.flip_camera_android, () => cameraController.switchCamera()),
        ),

        // Bottom-right: Flashlight
        Positioned(
          bottom: 100,
          right: 20,
          child: isCupertino
              ? _buildCupertinoIconButton(CupertinoIcons.light_max, () => cameraController.toggleTorch())
              : _buildMaterialIconButton(Icons.flash_on, () => cameraController.toggleTorch()),
        ),

        // Scan animation
        Center(
          child: SizedBox(
            width: scanBoxSize,
            height: scanBoxSize,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: scanBoxSize * _animation.value,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // Bottom instruction
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: const Center(
            child: Text(
              'Align QR code within the frame',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Cupertino style icon button
  Widget _buildCupertinoIconButton(IconData icon, VoidCallback onPressed) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }

  /// Material style icon button
  Widget _buildMaterialIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 30),
      onPressed: onPressed,
    );
  }
}