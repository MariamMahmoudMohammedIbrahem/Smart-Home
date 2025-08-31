import 'package:glow_grid/commons.dart';

class CameraHolePainter extends CustomPainter {
  final double holeSize;

  CameraHolePainter(this.holeSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.6);

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final holeRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: holeSize,
      height: holeSize,
    );

    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectXY(holeRect, 12, 12))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CornerZoomPainter extends CustomPainter {
  final double animationPadding;

  CornerZoomPainter(this.animationPadding);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MyColors.greenDark1
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;

    final qrCodePadding = 30.0 + animationPadding;

    canvas.drawLine(Offset(qrCodePadding, qrCodePadding),
        Offset(qrCodePadding + cornerLength, qrCodePadding), paint);
    canvas.drawLine(Offset(qrCodePadding, qrCodePadding),
        Offset(qrCodePadding, qrCodePadding + cornerLength), paint);

    canvas.drawLine(
        Offset(size.width - qrCodePadding, qrCodePadding),
        Offset(size.width - qrCodePadding - cornerLength, qrCodePadding),
        paint);
    canvas.drawLine(
        Offset(size.width - qrCodePadding, qrCodePadding),
        Offset(size.width - qrCodePadding, qrCodePadding + cornerLength),
        paint);

    canvas.drawLine(
        Offset(qrCodePadding, size.height - qrCodePadding),
        Offset(qrCodePadding + cornerLength, size.height - qrCodePadding),
        paint);
    canvas.drawLine(
        Offset(qrCodePadding, size.height - qrCodePadding),
        Offset(qrCodePadding, size.height - qrCodePadding - cornerLength),
        paint);

    canvas.drawLine(
        Offset(size.width - qrCodePadding, size.height - qrCodePadding),
        Offset(size.width - qrCodePadding - cornerLength,
            size.height - qrCodePadding),
        paint);
    canvas.drawLine(
        Offset(size.width - qrCodePadding, size.height - qrCodePadding),
        Offset(size.width - qrCodePadding,
            size.height - qrCodePadding - cornerLength),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
