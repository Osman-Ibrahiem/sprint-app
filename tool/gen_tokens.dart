// Generates lib/core/tokens/*.g.dart from docs/design-system/tokens.json.
//
// Run: dart run tool/gen_tokens.dart
// Contract: specs/001-foundation/contracts/tokens.md
//
// `generateTokens` is pure so the drift test can regenerate in memory.
import 'dart:convert';
import 'dart:io';

const tokensPath = 'docs/design-system/tokens.json';
const outDir = 'lib/core/tokens';

const _header = '''// GENERATED CODE - DO NOT EDIT.
// Source: docs/design-system/tokens.json (run `dart run tool/gen_tokens.dart`).
// dart format off
''';

void main() {
  final json =
      jsonDecode(File(tokensPath).readAsStringSync()) as Map<String, dynamic>;
  final files = generateTokens(json);
  Directory(outDir).createSync(recursive: true);
  files.forEach((name, content) {
    File('$outDir/$name').writeAsStringSync(content);
  });
  stdout.writeln('Wrote ${files.length} token files to $outDir');
}

/// Returns file name -> generated source for every token file.
Map<String, String> generateTokens(Map<String, dynamic> json) {
  return {
    'sprint_colors.g.dart': _colors(json),
    'sprint_spacing.g.dart': _spacing(json),
    'sprint_radius.g.dart': _radius(json),
    'sprint_size.g.dart': _size(json),
    'sprint_motion.g.dart': _motion(json),
    'sprint_text.g.dart': _text(json),
  };
}

// ---------------------------------------------------------------- helpers

String camel(String kebab) {
  final parts = kebab.split('-');
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

num _px(String v) => num.parse(v.replaceAll('px', '').replaceAll('ms', ''));

String _num(num v) {
  final d = v.toDouble();
  return d == d.roundToDouble() ? d.toStringAsFixed(1) : d.toString();
}

List<Map<String, dynamic>> _tokens(Map<String, dynamic> json, String group) =>
    ((json[group] as Map<String, dynamic>)['tokens'] as List)
        .cast<Map<String, dynamic>>();

String _color(String v) {
  final s = v.trim();
  if (s.startsWith('#')) {
    final hex = s.substring(1).toUpperCase();
    return 'Color(0xFF$hex)';
  }
  final m = RegExp(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)').firstMatch(s);
  if (m != null) {
    final a = (double.parse(m.group(4)!) * 255).round();
    String h(String x) => int.parse(x).toRadixString(16).padLeft(2, '0');
    final hex = '${a.toRadixString(16).padLeft(2, '0')}'
            '${h(m.group(1)!)}${h(m.group(2)!)}${h(m.group(3)!)}'
        .toUpperCase();
    return 'Color(0x$hex)';
  }
  throw FormatException('Unsupported colour: $v');
}

// ----------------------------------------------------------------- colors

String _colors(Map<String, dynamic> json) {
  final tokens = _tokens(json, 'color');
  final names = tokens.map((t) => t['name'] as String).toList();

  String resolve(Map<String, dynamic> t, String theme) {
    final raw = t['value'];
    var v = raw is Map ? raw[theme] as String : raw as String;
    if (v.startsWith('{') && v.endsWith('}')) {
      final ref = v.substring(1, v.length - 1);
      final target = tokens.firstWhere((x) => x['name'] == ref);
      final tv = target['value'];
      v = tv is Map ? tv[theme] as String : tv as String;
    }
    return _color(v);
  }

  final shadows = _tokens(json, 'shadow');

  String boxShadows(String value) {
    if (value.trim() == 'none') return '<BoxShadow>[]';
    final layers = RegExp(
      r'(-?\d+)(?:px)?\s+(-?\d+)(?:px)?\s+(\d+)(?:px)?\s+(rgba\([^)]*\))',
    ).allMatches(value);
    final items = layers.map((m) {
      return 'BoxShadow(offset: Offset(${_num(num.parse(m.group(1)!))}, '
          '${_num(num.parse(m.group(2)!))}), blurRadius: '
          '${_num(num.parse(m.group(3)!))}, color: ${_color(m.group(4)!)})';
    }).join(',\n    ');
    return '<BoxShadow>[\n    $items,\n  ]';
  }

  final b = StringBuffer(_header)
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln()
    ..writeln('@immutable')
    ..writeln('class SprintColors extends ThemeExtension<SprintColors> {')
    ..writeln('  const SprintColors({');
  for (final n in names) {
    b.writeln('    required this.${camel(n)},');
  }
  for (final s in shadows) {
    b.writeln('    required this.${camel(s['name'] as String)},');
  }
  b.writeln('  });\n');
  for (final n in names) {
    b.writeln('  final Color ${camel(n)};');
  }
  for (final s in shadows) {
    b.writeln('  final List<BoxShadow> ${camel(s['name'] as String)};');
  }

  for (final theme in ['light', 'dark']) {
    b.writeln('\n  static const SprintColors $theme = SprintColors(');
    for (final t in tokens) {
      b.writeln('    ${camel(t['name'] as String)}: ${resolve(t, theme)},');
    }
    for (final s in shadows) {
      final v = (s['value'] as Map)[theme] as String;
      b.writeln('    ${camel(s['name'] as String)}: ${boxShadows(v)},');
    }
    b.writeln('  );');
  }

  b
    ..writeln('\n  @override')
    ..writeln('  SprintColors copyWith({');
  for (final n in names) {
    b.writeln('    Color? ${camel(n)},');
  }
  for (final s in shadows) {
    b.writeln('    List<BoxShadow>? ${camel(s['name'] as String)},');
  }
  b.writeln('  }) {\n    return SprintColors(');
  for (final n in names) {
    b.writeln('      ${camel(n)}: ${camel(n)} ?? this.${camel(n)},');
  }
  for (final s in shadows) {
    final c = camel(s['name'] as String);
    b.writeln('      $c: $c ?? this.$c,');
  }
  b
    ..writeln('    );\n  }\n')
    ..writeln('  @override')
    ..writeln('  SprintColors lerp(ThemeExtension<SprintColors>? other, double t) {')
    ..writeln('    if (other is! SprintColors) return this;')
    ..writeln('    return SprintColors(');
  for (final n in names) {
    final c = camel(n);
    b.writeln('      $c: Color.lerp($c, other.$c, t)!,');
  }
  for (final s in shadows) {
    final c = camel(s['name'] as String);
    b.writeln('      $c: BoxShadow.lerpList($c, other.$c, t)!,');
  }
  b
    ..writeln('    );')
    ..writeln('  }')
    ..writeln('}');
  return b.toString();
}

// ------------------------------------------------------- spacing / radius

String _spacing(Map<String, dynamic> json) {
  final b = StringBuffer(_header)
    ..writeln('abstract final class SprintSpacing {');
  for (final t in _tokens(json, 'spacing')) {
    final n = (t['name'] as String).replaceFirst('space-', 'space');
    b.writeln('  static const double $n = ${_num(_px(t['value'] as String))};');
  }
  b.writeln('}');
  return b.toString();
}

String _radius(Map<String, dynamic> json) {
  final b = StringBuffer(_header)
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln('abstract final class SprintRadius {');
  for (final t in _tokens(json, 'radius')) {
    final n = (t['name'] as String).replaceFirst('radius-', '');
    final v = _num(_px(t['value'] as String));
    b
      ..writeln('  static const double $n = $v;')
      ..writeln('  static const Radius ${n}Radius = Radius.circular($v);')
      ..writeln(
        '  static const BorderRadius ${n}Border = '
        'BorderRadius.all(${n}Radius);',
      );
  }
  b.writeln('}');
  return b.toString();
}

// -------------------------------------------------------------- size / bp

String _size(Map<String, dynamic> json) {
  final b = StringBuffer(_header)..writeln('abstract final class SprintSize {');
  for (final t in _tokens(json, 'size')) {
    b.writeln(
      '  static const double ${camel(t['name'] as String)} = '
      '${_num(_px(t['value'] as String))};',
    );
  }
  b.writeln();
  for (final t in _tokens(json, 'breakpoint')) {
    final n = camel((t['name'] as String).replaceFirst('bp-', 'bp-'));
    b.writeln(
      '  static const double $n = ${_num(_px(t['value'] as String))};',
    );
  }
  b.writeln('}');
  return b.toString();
}

// ----------------------------------------------------------------- motion

String _motion(Map<String, dynamic> json) {
  final b = StringBuffer(_header)
    ..writeln("import 'package:flutter/animation.dart';")
    ..writeln()
    ..writeln('abstract final class SprintMotion {');
  for (final t in _tokens(json, 'motion')) {
    final name = t['name'] as String;
    final v = t['value'] as String;
    if (name.startsWith('duration-')) {
      b.writeln(
        '  static const Duration ${camel(name)} = '
        'Duration(milliseconds: ${_px(v).toInt()});',
      );
    } else {
      final m = RegExp(r'cubic-bezier\(([^)]*)\)').firstMatch(v)!;
      final p = m.group(1)!.split(',').map((e) => _num(num.parse(e.trim())));
      b.writeln('  static const Cubic ${camel(name)} = Cubic(${p.join(', ')});');
    }
  }
  b.writeln('}');
  return b.toString();
}

// ------------------------------------------------------------------- text

String _text(Map<String, dynamic> json) {
  final type = json['type'] as Map<String, dynamic>;
  final families = type['families'] as Map<String, dynamic>;
  String family(String key) {
    final m = RegExp(r'"([^"]+)"').firstMatch(families[key] as String)!;
    return m.group(1)!;
  }

  final b = StringBuffer(_header)
    ..writeln("import 'package:flutter/painting.dart';")
    ..writeln()
    ..writeln('abstract final class SprintText {');
  for (final g in (type['groups'] as List).cast<Map<String, dynamic>>()) {
    final fam = family(g['family'] as String);
    for (final s in (g['styles'] as List).cast<Map<String, dynamic>>()) {
      final size = _px(s['fontSize'] as String);
      final lh = _px(s['lineHeight'] as String);
      final w = s['fontWeight'] as int;
      final ls = s['letterSpacing'] as String?;
      b
        ..writeln('  static const TextStyle ${camel(s['name'] as String)} = '
            'TextStyle(')
        ..writeln("    fontFamily: '$fam',")
        ..writeln('    fontSize: ${_num(size)},')
        ..writeln('    fontWeight: FontWeight.w$w,')
        ..writeln('    height: ${_num(lh / size)},');
      if (ls != null && ls.endsWith('em')) {
        final em = double.parse(ls.replaceAll('em', ''));
        b.writeln('    letterSpacing: ${_num(em * size)},');
      }
      b.writeln('  );');
    }
  }
  b.writeln('}');
  return b.toString();
}
