/// Builds and reads the public facility link, `/facilities/<id>`
/// (FR-024, FR-025). Pure: the full URL (origin, base href) is the share
/// provider's job.
abstract final class FacilityLink {
  static const _prefix = '/facilities/';

  static String path(String id) => '$_prefix$id';

  /// The facility id in [location], or null when it is not a facility link.
  /// A trailing slash, a query, a fragment and a `/schedule` suffix are
  /// ignored; anything else (a different path, no id, a nested path) is not a
  /// facility link.
  static String? parse(String location) {
    var path = location;
    final query = path.indexOf('?');
    if (query >= 0) path = path.substring(0, query);
    final fragment = path.indexOf('#');
    if (fragment >= 0) path = path.substring(0, fragment);

    if (!path.startsWith(_prefix)) return null;
    var rest = path.substring(_prefix.length);
    if (rest.endsWith('/schedule')) {
      rest = rest.substring(0, rest.length - '/schedule'.length);
    }
    if (rest.endsWith('/')) rest = rest.substring(0, rest.length - 1);
    if (rest.isEmpty || rest.contains('/')) return null;
    return Uri.decodeComponent(rest);
  }
}
