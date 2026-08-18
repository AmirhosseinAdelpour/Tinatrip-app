import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_build_context.dart';
import '../painters/compass_painter.dart';
import '../painters/flight_trail_painter.dart';
import '../painters/starfield_painter.dart';

class SplashHost extends StatefulWidget {
  const SplashHost({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SplashHost> createState() => _SplashHostState();
}

class _SplashHostState extends State<SplashHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _exiting = false;
  bool _gone = false;
  bool _motionChecked = false;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_reducedMotion) {
          _beginExit();
        }
      });
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionChecked) return;
    _motionChecked = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _reducedMotion = true;
      _controller.value = 1;
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && !_gone) _beginExit();
      });
    }
  }

  void _beginExit() {
    if (_exiting) return;
    _exiting = true;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 580), () {
      if (mounted) {
        setState(() => _gone = true);
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gone) return const SizedBox.shrink();
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _exiting,
            child: AnimatedOpacity(
              opacity: _exiting ? 0 : 1,
              duration: const Duration(milliseconds: 480),
              curve: Curves.easeOut,
              child: _SplashView(controller: _controller),
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView({required this.controller});

  final AnimationController controller;

  Animation<double> _interval(
    double begin,
    double end, {
    Curve curve = Curves.easeOutCubic,
  }) {
    return CurvedAnimation(
      parent: controller,
      curve: Interval(begin, end, curve: curve),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final compassFade = _interval(0.0, 0.25);
    final compassSpin = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.75, curve: Curves.linear),
    );
    final titleFade = _interval(0.18, 0.38);
    final arc = _interval(0.34, 0.66);
    final card = _interval(0.52, 0.74);
    final chips = _interval(0.62, 0.82);
    final foot = _interval(0.72, 0.90);

    return Material(
      color: colors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.background,
                  colors.background,
                  colors.surface,
                ],
              ),
            ),
            child: const RepaintBoundary(
              child: CustomPaint(painter: StarfieldPainter()),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.3),
                  radius: 1.2,
                  colors: [
                    colors.primary.withAlpha(15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(flex: 3),
                      _CompassRose(
                        fade: compassFade,
                        spin: compassSpin,
                      ),
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: titleFade,
                        child: Text(
                          'تیناتریپ',
                          style: context.textTheme.displaySmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: FadeTransition(
                          opacity: arc,
                          child: RepaintBoundary(
                            child: CustomPaint(
                              painter: FlightTrailPainter(
                                progress: CurvedAnimation(
                                  parent: controller,
                                  curve: const Interval(
                                    0.34,
                                    0.66,
                                    curve: Curves.easeInOut,
                                  ),
                                ).value,
                                baseColor: colors.line,
                                glowColor: colors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: card,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(card),
                          child: const _SplashSearchCard(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: chips,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _SplashChip('مشهد'),
                            SizedBox(width: 10),
                            _SplashChip('کیش'),
                            SizedBox(width: 10),
                            _SplashChip('استانبول'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: foot,
                        child: Text(
                          'تینا تریپ، پلی به سوی دنیا',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.muted.withAlpha(178),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassRose extends StatelessWidget {
  const _CompassRose({required this.fade, required this.spin});

  final Animation<double> fade;
  final Animation<double> spin;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.6, end: 1.0).animate(
          CurvedAnimation(parent: fade, curve: Curves.easeOutBack),
        ),
        child: AnimatedBuilder(
          animation: spin,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Transform.rotate(
                  angle: spin.value * math.pi * 2,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: const Size(140, 140),
                      painter: CompassPainter(color: colors.primary),
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primary.withAlpha(102),
                      width: 1.5,
                    ),
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.background,
                    border: Border.all(
                      color: colors.primary.withAlpha(153),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    Icons.explore,
                    color: colors.primary,
                    size: 32,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplashSearchCard extends StatelessWidget {
  const _SplashSearchCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.line),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withAlpha(25),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),
          Icon(Icons.flight_takeoff, color: colors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'کجا می‌خواهید بروید؟',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onBackground,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'شهر، فرودگاه یا نام هتل',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.accent],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search, color: colors.background, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SplashChip extends StatelessWidget {
  const _SplashChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place, size: 14, color: colors.secondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}
