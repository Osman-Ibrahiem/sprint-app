import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// Paints a QR code from the `qr` module matrix in [ink] on [ground], with a
/// quiet [margin] around it (research R5). Safe on empty or oversized tokens:
/// [SprintQrPainter.canEncode] says whether a token fits, and the painter draws only
/// the ground when it does not.
class SprintQrPainter extends CustomPainter {
  SprintQrPainter({
    required this.token,
    required this.ink,
    required this.ground,
    required this.margin,
  });

  final String token;
  final Color ink;
  final Color ground;
  final double margin;

  static QrImage? _image(String token) {
    if (token.isEmpty) return null;
    try {
      return QrImage(QrCode(
        payload: QrPayload.fromString(token),
        errorCorrectLevel: QrErrorCorrectLevel.medium,
      ));
    } on Object {
      return null;
    }
  }

  /// True when [token] is non-empty and small enough for a QR code.
  static bool canEncode(String token) => _image(token) != null;

  /// The module matrix, for tests (true = dark module).
  static List<List<bool>>? matrix(String token) {
    final image = _image(token);
    if (image == null) return null;
    return [
      for (var y = 0; y < image.moduleCount; y++)
        [for (var x = 0; x < image.moduleCount; x++) image.isDark(y, x)],
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = ground);
    final image = _image(token);
    if (image == null) return;
    final side = size.shortestSide - margin * 2;
    if (side <= 0) return;
    final cell = side / image.moduleCount;
    final paint = Paint()..color = ink;
    for (var y = 0; y < image.moduleCount; y++) {
      for (var x = 0; x < image.moduleCount; x++) {
        if (image.isDark(y, x)) {
          canvas.drawRect(
            Rect.fromLTWH(margin + x * cell, margin + y * cell, cell + 0.5, cell + 0.5),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(SprintQrPainter old) =>
      old.token != token ||
      old.ink != ink ||
      old.ground != ground ||
      old.margin != margin;
}
