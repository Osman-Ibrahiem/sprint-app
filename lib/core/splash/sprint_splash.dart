import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/reduced_motion.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_motion.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Shows [SprintSplash] over [child] until the sequence ends, then fades it
/// out. The native splash (step 1) is already on screen when this starts, so
/// it begins at step 2 (the transition) with the bolt and background in the
/// same place; under reduced motion it starts at step 3.
class SprintSplashGate extends StatefulWidget {
  const SprintSplashGate({
    required this.child,
    this.enabled = true,
    this.hold,
    super.key,
  });

  /// How long step 3 stays on screen: two `duration-base` and one `duration-fast`.
  static final Duration defaultHold =
      SprintMotion.durationBase * 2 + SprintMotion.durationFast;

  final Widget child;
  final bool enabled;

  /// How long the finished splash (step 3) stays before it leaves.
  final Duration? hold;

  @override
  State<SprintSplashGate> createState() => _SprintSplashGateState();
}

class _SprintSplashGateState extends State<SprintSplashGate> {
  bool _visible = true;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _visible = widget.enabled;
  }

  void _leave() {
    if (!mounted || _leaving) return;
    setState(() => _leaving = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.child;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: _leaving ? 0 : 1,
            duration: SprintMotion.durationFast,
            curve: SprintMotion.easeExit,
            onEnd: () {
              if (_leaving && mounted) setState(() => _visible = false);
            },
            child: IgnorePointer(
              ignoring: _leaving,
              child: SprintSplash(
                hold: widget.hold ?? SprintSplashGate.defaultHold,
                onDone: _leave,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The in-app splash: bolt, wordmark, tagline, lane loader and caption on the
/// brand background (`primary`, in both themes). Positions follow the
/// Figma page "Splash" and scale with the window height, never the device.
class SprintSplash extends StatefulWidget {
  const SprintSplash({this.hold, this.onDone, super.key});

  final Duration? hold;
  final VoidCallback? onDone;

  static const double boltSize = 88;

  /// Step 1 stays this long before the move (600ms, as in the Figma notes).
  static final Duration nativeHold =
      SprintMotion.durationSlow + SprintMotion.durationBase;

  static const double _boltRise = 86; // centre -> step 3 position
  static const double _wordmarkGap = 20; // bolt bottom -> wordmark top
  static const double _taglineGap = 4;
  static const double _laneHeight = 6;
  static const double _laneGap = 8;
  static const List<double> _laneWidths = [56, 36, 46];
  static const double _laneTravel = 8;
  static const double _loaderBottom = 116; // loader above the screen bottom
  static const double _captionBottom = 74; // caption above the screen bottom
  static const double _captionBottomWide = 32;
  static const double _loaderBottomWide = 72;
  static const double _wideFrom = 600; // medium window class

  static const markAsset = 'docs/design-system/logo/sprint-mark.svg';

  @override
  State<SprintSplash> createState() => _SprintSplashState();
}

class _SprintSplashState extends State<SprintSplash>
    with TickerProviderStateMixin {
  // 0..350ms bolt move + wordmark fade; then 250ms content fade.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: SprintMotion.durationSlow + SprintMotion.durationBase,
  );
  late final AnimationController _loader = AnimationController(
    vsync: this,
    duration: SprintMotion.durationPulse,
  );
  Timer? _timer;
  bool _started = false;
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = ReducedMotion.of(context);
    if (_started) return;
    _started = true;
    if (_reduced) {
      _intro.value = 1;
      _scheduleDone();
    } else {
      _loader.repeat();
      // Step 1 (the native look) stays for a moment before the bolt rises.
      _timer = Timer(SprintSplash.nativeHold, () {
        _intro.forward().whenComplete(_scheduleDone);
      });
    }
  }

  void _scheduleDone() {
    final done = widget.onDone;
    if (done == null) return;
    _timer = Timer(widget.hold ?? Duration.zero, done);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    _loader.dispose();
    super.dispose();
  }

  double _span(double from, double to, Curve curve) {
    final total = _intro.duration!.inMicroseconds;
    final t = ((_intro.value * total - from * 1000) / ((to - from) * 1000))
        .clamp(0.0, 1.0);
    return curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // One fixed look in both themes, the same as the native launch screens.
    final colors = SprintColors.light;
    final bg = colors.primary;
    final main = colors.onPrimary;
    final soft = colors.onPrimarySoft;
    final text = SprintTextStyles(main);

    return ColoredBox(
      color: bg,
      child: LayoutBuilder(
        builder: (context, box) {
          final centerY = box.maxHeight / 2;
          final wide = box.maxWidth >= SprintSplash._wideFrom;
          final top3 =
              centerY - SprintSplash.boltSize / 2 - SprintSplash._boltRise;
          return AnimatedBuilder(
            animation: _intro,
            builder: (context, _) {
              final move = _span(
                0,
                SprintMotion.durationSlow.inMilliseconds.toDouble(),
                SprintMotion.easeEnter,
              );
              final content = _span(
                SprintMotion.durationSlow.inMilliseconds.toDouble(),
                _intro.duration!.inMilliseconds.toDouble(),
                Curves.linear,
              );
              final boltTop =
                  centerY -
                  SprintSplash.boltSize / 2 -
                  SprintSplash._boltRise * move;
              final wordmarkTop =
                  top3 + SprintSplash.boltSize + SprintSplash._wordmarkGap;
              // The wordmark starts at 40% and settles 10px lower than step 3.
              final wordmarkOpacity =
                  math.min(1.0, move * 8) * 0.4 + 0.6 * move;
              final wordmarkShift = 10 * (1 - move);
              return Stack(
                children: [
                  Positioned(
                    top: boltTop,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SvgPicture.asset(
                        SprintSplash.markAsset,
                        width: SprintSplash.boltSize,
                        height: SprintSplash.boltSize,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                  Positioned(
                    top: wordmarkTop + wordmarkShift,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: wordmarkOpacity,
                      child: Semantics(
                        header: true,
                        child: Text(
                          l10n.appName,
                          textAlign: TextAlign.center,
                          style: text.display,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: wordmarkTop + 44 + SprintSplash._taglineGap,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: content,
                      child: Text(
                        l10n.splashTagline,
                        textAlign: TextAlign.center,
                        style: text.body,
                      ),
                    ),
                  ),
                  Positioned(
                    // Always at the bottom, above the caption (Osman's call).
                    bottom: wide
                        ? SprintSplash._loaderBottomWide
                        : SprintSplash._loaderBottom,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: content,
                      child: ExcludeSemantics(
                        child: Center(child: _LaneLoader(animation: _loader)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: wide
                        ? SprintSplash._captionBottomWide
                        : SprintSplash._captionBottom,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: content,
                      child: Text(
                        l10n.splashCaption,
                        textAlign: TextAlign.center,
                        style: text.micro.copyWith(color: soft),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Three volt lanes sliding like lane ropes, one cycle per `duration-pulse`.
/// Static when the controller is stopped (reduced motion).
class _LaneLoader extends StatelessWidget {
  const _LaneLoader({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final volt = SprintColors.light.volt; // the bolt is volt in both themes
    return SizedBox(
      width: SprintSplash._laneWidths.first,
      height: SprintSplash._laneHeight * 3 + SprintSplash._laneGap * 2,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < 3; i++)
              Positioned(
                top: i * (SprintSplash._laneHeight + SprintSplash._laneGap),
                left:
                    (SprintSplash._laneWidths.first -
                            SprintSplash._laneWidths[i]) /
                        2 +
                    SprintSplash._laneTravel *
                        math.sin(2 * math.pi * (animation.value + i / 3)),
                child: Container(
                  width: SprintSplash._laneWidths[i],
                  height: SprintSplash._laneHeight,
                  decoration: BoxDecoration(
                    color: volt,
                    borderRadius: BorderRadius.circular(
                      SprintSplash._laneHeight / 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
