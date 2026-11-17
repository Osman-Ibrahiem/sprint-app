import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/widgets/booking_ticket/qr_painter.dart';
import 'package:sprint/features/booking/domain/qr_token.dart';
import 'package:zxing2/qrcode.dart';

/// SC-007: what the painter draws decodes back to the token.
void main() {
  final tokens = <String>[
    for (var i = 0; i < 20; i++) qrTokenFor('b-$i', 'SPR-${4000 + i}'),
    'qr.a.b',
    'x' * 120,
  ];

  Future<ui.Image> render(String token, SprintColors c) async {
    const side = 400.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    SprintQrPainter(
      token: token,
      ink: c.qrInk,
      ground: c.qrGround,
      margin: SprintExtras.qrQuietMargin,
    ).paint(canvas, const Size(side, side));
    return recorder.endRecording().toImage(side.toInt(), side.toInt());
  }

  for (final (name, colors) in [
    ('light', SprintColors.light),
    ('dark', SprintColors.dark),
  ]) {
    testWidgets('every token decodes in $name', (tester) async {
      await tester.runAsync(() async {
        for (final token in tokens) {
          final image = await render(token, colors);
          final bytes = (await image.toByteData())!.buffer.asUint8List();
          final pixels = Int32List.fromList([
            for (var i = 0; i < bytes.length; i += 4)
              0xFF000000 |
                  (bytes[i] << 16) |
                  (bytes[i + 1] << 8) |
                  bytes[i + 2],
          ]);
          final source = RGBLuminanceSource(image.width, image.height, pixels);
          final bitmap = BinaryBitmap(HybridBinarizer(source));
          final result = QRCodeReader().decode(bitmap);
          expect(result.text, token);
        }
      });
    });
  }

  test('module matrix matches the qr package', () {
    for (final token in tokens) {
      final expected = QrImage(QrCode.fromData(
        data: token,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      ));
      final m = SprintQrPainter.matrix(token)!;
      expect(m.length, expected.moduleCount);
      expect(m[0][0], expected.isDark(0, 0));
    }
  });

  test('empty and oversized tokens are not encodable and never throw', () {
    expect(SprintQrPainter.canEncode(''), isFalse);
    expect(SprintQrPainter.canEncode('x' * 5000), isFalse);
    expect(SprintQrPainter.matrix('x' * 5000), isNull);
  });
}
