/// An opaque, signed-looking token for a booking's QR code (NFR-07 is met for
/// real by the backend later). It is never the raw booking code.
String qrTokenFor(String bookingId, String code) {
  var h = 17;
  for (final c in '$bookingId|$code'.codeUnits) {
    h = (h * 31 + c) & 0x3fffffff;
  }
  return 'qr.${h.toRadixString(36)}.${bookingId.hashCode.abs().toRadixString(36)}';
}
