import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show kIsWeb, ValueListenable, ValueNotifier;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import 'platform_actions.dart';
import 'webview_setup.dart';

void main() {
  runApp(const TunaTripApp());
}

// ---- ThemeExtension for custom colors --------------------------------------

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.line,
    required this.primary,
    required this.secondary,
    required this.onBackground,
    required this.muted,
    required this.error,
    required this.accent,
  });

  final Color background;
  final Color surface;
  final Color line;
  final Color primary;
  final Color secondary;
  final Color onBackground;
  final Color muted;
  final Color error;
  final Color accent;

  static const light = AppColors(
    background: Color(0xFF0B1B27),
    surface: Color(0xFF123041),
    line: Color(0xFF1F4050),
    primary: Color(0xFF4BC2ED),
    secondary: Color(0xFFE9AF4F),
    onBackground: Color(0xFFEAF2F4),
    muted: Color(0xFF8AA5AF),
    error: Color(0xFFE0684E),
    accent: Color(0xFF97A6DD),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? line,
    Color? primary,
    Color? secondary,
    Color? onBackground,
    Color? muted,
    Color? error,
    Color? accent,
  }) =>
      AppColors(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        line: line ?? this.line,
        primary: primary ?? this.primary,
        secondary: secondary ?? this.secondary,
        onBackground: onBackground ?? this.onBackground,
        muted: muted ?? this.muted,
        error: error ?? this.error,
        accent: accent ?? this.accent,
      );

  @override
  AppColors lerp(AppColors? other, double t) => AppColors(
    background: Color.lerp(background, other?.background, t)!,
    surface: Color.lerp(surface, other?.surface, t)!,
    line: Color.lerp(line, other?.line, t)!,
    primary: Color.lerp(primary, other?.primary, t)!,
    secondary: Color.lerp(secondary, other?.secondary, t)!,
    onBackground: Color.lerp(onBackground, other?.onBackground, t)!,
    muted: Color.lerp(muted, other?.muted, t)!,
    error: Color.lerp(error, other?.error, t)!,
    accent: Color.lerp(accent, other?.accent, t)!,
  );
}

// ---- App -------------------------------------------------------------------

class TunaTripApp extends StatelessWidget {
  const TunaTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تیناتریپ',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Vazirmatn',
        extensions: const [AppColors.light],
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4BC2ED),
          secondary: Color(0xFFE9AF4F),
          surface: Color(0xFF123041),
          onSurface: Color(0xFFEAF2F4),
          error: Color(0xFFE0684E),
          outline: Color(0xFF1F4050),
        ),
        scaffoldBackgroundColor: Color(0xFF0B1B27),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF4BC2ED),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
      ),
      home: const SplashHost(),
    );
  }
}

extension BuildContextExtensions on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

// ---- Splash ----------------------------------------------------------------

class SplashHost extends StatefulWidget {
  const SplashHost({super.key});

  @override
  State<SplashHost> createState() => _SplashHostState();
}

class _SplashHostState extends State<SplashHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final ValueNotifier<bool> _startSignal = ValueNotifier(false);
  Timer? _homeTimer;
  bool _homeReady = false;
  bool _exiting = false;
  bool _gone = false;
  bool _motionChecked = false;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 3200),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && !_reducedMotion) {
            _beginExit();
          }
        });
    _controller.forward();
    _homeTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _homeReady = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionChecked) return;
    _motionChecked = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _reducedMotion = true;
      _controller.value = 1;
      _homeTimer?.cancel();
      _homeReady = true;
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && !_gone) _beginExit();
      });
    }
  }

  void _beginExit() {
    if (_exiting) return;
    _exiting = true;
    _startSignal.value = true;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 580), () {
      if (mounted) setState(() => _gone = true);
    });
  }

  @override
  void dispose() {
    _homeTimer?.cancel();
    _controller.dispose();
    _startSignal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_homeReady) HomePage(startSignal: _startSignal),
        if (!_gone)
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
                  colors.background.withValues(alpha: 0.5),
                  colors.background,
                  colors.surface,
                ],
              ),
            ),
            child: const RepaintBoundary(
              child: CustomPaint(painter: _StarfieldPainter()),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.3),
                  radius: 1.2,
                  colors: [
                    colors.primary.withValues(alpha: 0.06),
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
                          style: context.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onBackground,
                            letterSpacing: 0.8,
                          ),
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
                              painter: _FlightTrailPainter(
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
                            color: colors.muted.withValues(alpha: 0.7),
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
                      painter: _CompassPainter(color: colors.primary),
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.4),
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
                      color: colors.primary.withValues(alpha: 0.6),
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

class _CompassPainter extends CustomPainter {
  const _CompassPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = math.min(size.width, size.height) / 2 - 4;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 - math.pi / 2;
      final r = i.isEven ? outer : outer * 0.35;
      final p = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 - math.pi / 2;
      final p = Offset(
        center.dx + math.cos(angle) * (outer + 8),
        center.dy + math.sin(angle) * (outer + 8),
      );
      canvas.drawCircle(p, 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.color != color;
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
            color: colors.primary.withValues(alpha: 0.1),
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

// ---- Home ------------------------------------------------------------------

enum _ServiceAccent { primary, secondary, accent, error }

class _ServiceItem {
  final String label;
  final IconData icon;
  final String? url;
  final _ServiceAccent accent;
  final bool opensForm;

  const _ServiceItem({
    required this.label,
    required this.icon,
    this.url,
    required this.accent,
    this.opensForm = false,
  });
}

class _TravelTool {
  final String label;
  final IconData icon;
  final String url;

  const _TravelTool({
    required this.label,
    required this.icon,
    required this.url,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.startSignal});

  final ValueListenable<bool>? startSignal;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const _services = [
    _ServiceItem(
      label: 'پرواز',
      icon: Icons.flight,
      url: 'https://tinatrip.com/flight/',
      accent: _ServiceAccent.primary,
    ),
    _ServiceItem(
      label: 'هتل',
      icon: Icons.hotel,
      url: 'https://tinatrip.com/hotels/',
      accent: _ServiceAccent.secondary,
    ),
    _ServiceItem(
      label: 'تور',
      icon: Icons.explore,
      url: 'https://tinatrip.com/tours/',
      accent: _ServiceAccent.accent,
    ),
    _ServiceItem(
      label: 'گشت',
      icon: Icons.edit_calendar,
      accent: _ServiceAccent.error,
      opensForm: true,
    ),
  ];

  static const _tools = [
    _TravelTool(
      label: 'اطلاعات پرواز',
      icon: Icons.connecting_airports,
      url: 'https://fids.airport.ir/',
    ),
    _TravelTool(
      label: 'استعلام ممنوع الخروجی',
      icon: Icons.policy,
      url: 'https://my.ssaa.ir/portal/executive/inquery-exitban',
    ),
    _TravelTool(
      label: 'پرداخت عوارض خروج',
      icon: Icons.payments,
      url: 'https://sadadpsp.ir/tollpayment',
    ),
    _TravelTool(
      label: 'ارز مسافرتی',
      icon: Icons.currency_exchange,
      url: 'https://travel.ice.ir/',
    ),
    _TravelTool(
      label: 'بیمه مسافرتی',
      icon: Icons.health_and_safety,
      url: 'https://samandirect.ir/page/Load?Name=TravelInfo',
    ),
  ];

  late final AnimationController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    widget.startSignal?.addListener(_onStart);
  }

  void _onStart() {
    if (_started) return;
    _started = true;
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.startSignal != null) return;
    if (!_started) {
      _started = true;
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    widget.startSignal?.removeListener(_onStart);
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _interval(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  void _openWeb(String label, String url) {
    if (kIsWeb) {
      openExternalUrl(url);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WebViewPage(title: label, url: url),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      key: _scaffoldKey,
      drawer: _HomeDrawer(
        onBlog: () {
          Navigator.of(context).pop();
          _openWeb('وبلاگ', 'https://tinatrip.com/blog/');
        },
        onRules: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RulesPage()),
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Opacity(
          opacity: _interval(0.7, 0.9).value,
          child: FloatingActionButton.extended(
            heroTag: 'contactFab',
            backgroundColor: colors.primary,
            foregroundColor: colors.background,
            elevation: 8,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ContactPage())),
            icon: const Icon(Icons.support_agent, size: 20),
            label: Text(
              'تماس با ما',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.background,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _HomeBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(0, constraints.maxHeight - 96),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _RevealText(
                          animation: _interval(0.0, 0.18),
                          child: Column(
                            children: [
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: _MenuButton(
                                  onTap: () => _scaffoldKey.currentState
                                      ?.openDrawer(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'تیناتریپ',
                                textAlign: TextAlign.center,
                                style: context.textTheme.headlineMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'مرجع بهترین تورها، هتل‌ها و پروازهای داخلی و خارجی',
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _ServiceGrid(
                          visible: _interval(0.2, 0.5),
                          services: _services,
                          onTap: (s) {
                            if (s.opensForm) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ReserveFormPage(),
                                ),
                              );
                            } else {
                              _openWeb(s.label, s.url!);
                            }
                          },
                        ),
                        const SizedBox(height: 28),
                        _ToolsSection(
                          visible: _interval(0.54, 0.74),
                          tools: _tools,
                          onTap: (t) => _openWeb(t.label, t.url),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.background.withValues(alpha: 0.5),
            colors.background,
            colors.surface,
          ],
        ),
      ),
      child: const RepaintBoundary(
        child: CustomPaint(painter: _StarfieldPainter()),
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  const _StarfieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.18);
    for (var i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.55;
      final r = 0.4 + rng.nextDouble() * 0.8;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({
    required this.visible,
    required this.services,
    required this.onTap,
  });

  final Animation<double> visible;
  final List<_ServiceItem> services;
  final ValueChanged<_ServiceItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < services.length; i++) ...[
          _ServiceBar(
            item: services[i],
            reveal: CurvedAnimation(
              parent: visible,
              curve: Interval(
                i * 0.08,
                i * 0.08 + 0.55,
                curve: Curves.easeOutCubic,
              ),
            ),
            onTap: () => onTap(services[i]),
          ),
          if (i < services.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ServiceBar extends StatelessWidget {
  const _ServiceBar({
    required this.item,
    required this.reveal,
    required this.onTap,
  });

  final _ServiceItem item;
  final Animation<double> reveal;
  final VoidCallback onTap;

  Color _accentFor(AppColors colors) => switch (item.accent) {
        _ServiceAccent.primary => colors.primary,
        _ServiceAccent.secondary => colors.secondary,
        _ServiceAccent.accent => colors.accent,
        _ServiceAccent.error => colors.error,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = _accentFor(colors);
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.14),
        end: Offset.zero,
      ).animate(reveal),
      child: FadeTransition(
        opacity: reveal,
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 68,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.line),
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    accent.withValues(alpha: 0.18),
                    colors.surface,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(width: 4, color: accent),
                  const SizedBox(width: 16),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(item.icon, color: accent, size: 21),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.label,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onBackground,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(
                      Icons.chevron_left,
                      color: accent.withValues(alpha: 0.8),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolsSection extends StatelessWidget {
  const _ToolsSection({
    required this.visible,
    required this.tools,
    required this.onTap,
  });

  final Animation<double> visible;
  final List<_TravelTool> tools;
  final ValueChanged<_TravelTool> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final rows = <List<_TravelTool>>[
      for (var i = 0; i < tools.length; i += 2)
        tools.sublist(i, math.min(i + 2, tools.length)),
    ];

    return FadeTransition(
      opacity: visible,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'ابزارهای سفر',
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.muted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(height: 1, color: colors.line),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            FadeTransition(
              opacity: CurvedAnimation(
                parent: visible,
                curve: Interval(
                  i * 0.06,
                  i * 0.06 + 0.65,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: Row(
                children: [
                  for (var j = 0; j < rows[i].length; j++) ...[
                    Expanded(
                      child: _ToolTile(
                        tool: rows[i][j],
                        onTap: () => onTap(rows[i][j]),
                      ),
                    ),
                    if (j < rows[i].length - 1) const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            if (i < rows.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tool, required this.onTap});

  final _TravelTool tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(tool.icon, color: colors.muted, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tool.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onBackground,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevealText extends StatelessWidget {
  const _RevealText({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _FlightTrailPainter extends CustomPainter {
  const _FlightTrailPainter({
    required this.progress,
    required this.baseColor,
    required this.glowColor,
  });

  final double progress;
  final Color baseColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.02, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.08,
        size.width * 0.98,
        size.height * 0.34,
      );

    final metric = path.computeMetrics().first;
    final visible = metric.extractPath(0, metric.length * progress);

    final base = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final glow = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    _drawDashed(canvas, visible, base, dashLength: 3, gap: 10);

    if (progress > 0.02) {
      final end = metric.getTangentForOffset(metric.length * progress)!;
      canvas.save();
      canvas.translate(end.position.dx, end.position.dy);
      canvas.rotate(math.atan2(end.vector.dy, end.vector.dx));
      canvas.drawPath(_planeGlyph(), glow);
      canvas.restore();
    }
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gap,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            math.min(distance + dashLength, metric.length),
          ),
          paint,
        );
        distance += dashLength + gap;
      }
    }
  }

  Path _planeGlyph() {
    final p = Path();
    p.moveTo(-10, -3);
    p.lineTo(10, -3);
    p.lineTo(12, 0);
    p.lineTo(10, 3);
    p.lineTo(-10, 3);
    p.lineTo(-12, 0);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant _FlightTrailPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.baseColor != baseColor ||
      oldDelegate.glowColor != glowColor;
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.line),
          ),
          child: Icon(Icons.menu, color: colors.onBackground, size: 20),
        ),
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({required this.onBlog, required this.onRules});

  final VoidCallback onBlog;
  final VoidCallback onRules;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/logo.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تیناتریپ',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'منوی اصلی',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.muted.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: colors.line,
            ),
            const SizedBox(height: 12),
            _DrawerTile(
              icon: Icons.article_outlined,
              color: colors.primary,
              label: 'وبلاگ',
              onTap: onBlog,
            ),
            _DrawerTile(
              icon: Icons.description_outlined,
              color: colors.secondary,
              label: 'قوانین',
              onTap: onRules,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                'تینا تریپ، پلی به سوی دنیا',
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.muted.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          label,
          style: context.textTheme.bodyLarge?.copyWith(
            color: colors.onBackground,
          ),
        ),
        trailing: Icon(Icons.chevron_left, color: colors.muted, size: 20),
        onTap: onTap,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colors.background, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: colors.background,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.line, width: 1.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colors.secondary, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: colors.onBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Reserve form ----------------------------------------------------------

class ReserveFormPage extends StatefulWidget {
  const ReserveFormPage({super.key});

  @override
  State<ReserveFormPage> createState() => _ReserveFormPageState();
}

class _ReserveFormPageState extends State<ReserveFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _sending = false;

  static final _phoneRegExp = RegExp(r'^(09\d{9}|\+989\d{9})$');

  @override
  void dispose() {
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    final uri = Uri.parse('https://tinatrip.com/contactRequest/').replace(
      queryParameters: {
        'saleCounter': 'نرم افزار',
        'destination': _cityController.text.trim(),
        'phone': _phoneController.text.trim(),
        'type': 'normal',
      },
    );

    String message;
    bool ok;
    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(response.body);
      final status = body is Map ? body['status'] : null;
      ok = response.statusCode == 200 && status == 'success';
      if (ok) {
        message = 'درخواست شما ثبت شد؛ کارشناسان ما به‌زودی با شما تماس می‌گیرند.';
      } else {
        message = (body is Map && body['message'] is String)
            ? body['message'] as String
            : 'ثبت درخواست ممکن نشد (کد خطا: ${response.statusCode}). لطفاً دوباره تلاش کنید.';
      }
    } on TimeoutException {
      ok = false;
      message = 'ارسال درخواست بیش از حد انتظار طول کشید؛ اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.';
    } on http.ClientException {
      ok = false;
      message = 'ارتباط با سرور برقرار نشد؛ اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.';
    } on FormatException {
      ok = false;
      message = 'پاسخ سرور قابل خواندن نبود؛ لطفاً بعداً دوباره تلاش کنید.';
    } catch (_) {
      ok = false;
      message = 'خطای غیرمنتظره‌ای رخ داد؛ لطفاً دوباره تلاش کنید.';
    }

    if (!mounted) return;
    setState(() => _sending = false);

    final colors = context.appColors;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('درخواست شما ثبت شد؛ کارشناسان ما به‌زودی با شما تماس می‌گیرند.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.surface,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: _appBar(context, 'گشت'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.surface, colors.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'برای گشت، شهر مقصد و شماره تماس‌تان را بفرستید؛ کارشناسان ما با شما تماس می‌گیرند.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackground,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel('شهر مقصد'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _cityController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return 'شهر مقصد را بنویسید.';
                      return null;
                    },
                    decoration: _inputDecoration(
                      'مثلاً مشهد، استانبول یا کیش',
                      Icons.place,
                      colors,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel('شماره تماس'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge?.copyWith(
                      letterSpacing: 1,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                    ],
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return 'شماره تماس را وارد کنید.';
                      if (!_phoneRegExp.hasMatch(v)) {
                        return 'شماره موبایل معتبر نیست (مثلاً 09123456789 یا +989123456789).';
                      }
                      return null;
                    },
                    decoration: _inputDecoration(
                      'مثلاً 09123456789',
                      Icons.phone_iphone,
                      colors,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _sending
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _PrimaryButton(
                          label: 'ارسال درخواست',
                          icon: Icons.send,
                          onTap: _submit,
                        ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      text,
      style: context.textTheme.titleMedium?.copyWith(
        color: colors.onBackground,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint, IconData icon, AppColors colors) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.primary, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.error, width: 1.6),
    ),
  );
}

// ---- Contact ---------------------------------------------------------------

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const _phones = ['02191690935', '05191690935', '05135147359'];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: _appBar(context, 'تماس با ما'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.surface, colors.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'پشتیبانی تینا تریپ آماده دریافت انتقادات، پیشنهادات و نظرات شما می‌باشد.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackground,
                      height: 1.8,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                for (final phone in _phones)
                  _ContactRow(
                    icon: Icons.phone_in_talk,
                    color: colors.primary,
                    label: 'شماره ثابت',
                    value: phone,
                    onTap: () => dialNumber(phone),
                  ),
                _ContactRow(
                  icon: Icons.phone_iphone,
                  color: colors.primary,
                  label: 'شماره همراه',
                  value: '09909675218',
                  onTap: () => dialNumber('09909675218'),
                ),
                _ContactRow(
                  icon: Icons.camera_alt,
                  color: colors.error,
                  label: 'اینستاگرام',
                  value: 'tinasafar_com',
                  onTap: () =>
                      openExternalUrl('https://instagram.com/tinasafar_com'),
                ),
                _ContactRow(
                  icon: Icons.mail_outline,
                  color: colors.secondary,
                  label: 'ایمیل',
                  value: 'tinatrip24@gmail.com',
                  onTap: () => sendEmail(
                    to: 'tinatrip24@gmail.com',
                    subject: 'ارتباط با تیناتریپ',
                    body: '',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.muted.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_left, color: colors.muted, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Shared app bar & webview -------------------------------------------------

AppBar _appBar(BuildContext context, String title) {
  final colors = context.appColors;
  return AppBar(
    title: Text(title, style: context.textTheme.titleMedium),
    backgroundColor: colors.surface,
    foregroundColor: colors.onBackground,
    elevation: 0,
    centerTitle: true,
  );
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

enum _WebState { loading, ready, error }

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  _WebState _state = _WebState.loading;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    final colors = context.appColors;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(colors.background)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; SM-G991B) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _setState(_WebState.loading);
            _armTimeout();
          },
          onPageFinished: (_) {
            _timeout?.cancel();
            _setState(_WebState.ready);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) {
              _timeout?.cancel();
              _setState(_WebState.error);
            }
          },
        ),
      );
    configureWebViewController(_controller).then((_) {
      _controller.loadRequest(Uri.parse(widget.url));
    });
    _armTimeout();
  }

  void _armTimeout() {
    _timeout?.cancel();
    _timeout = Timer(const Duration(seconds: 25), () {
      if (_state == _WebState.loading) {
        _setState(_WebState.error);
      }
    });
  }

  void _setState(_WebState s) {
    if (mounted) setState(() => _state = s);
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: _appBar(context, widget.title),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_state == _WebState.loading) const _WebLoadingView(),
          if (_state == _WebState.error)
            _WebErrorView(
              onRetry: () {
                _setState(_WebState.loading);
                _armTimeout();
                _controller.reload();
              },
              onBrowser: () => openExternalUrl(widget.url),
            ),
        ],
      ),
    );
  }
}

class RulesPage extends StatefulWidget {
  const RulesPage({super.key});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesSection {
  final String title;
  final List<String> paragraphs;

  const _RulesSection({required this.title, required this.paragraphs});
}

class _RulesPageState extends State<RulesPage> {
  final ScrollController _scroll = ScrollController();
  final List<GlobalKey> _itemKeys = List.generate(14, (_) => GlobalKey());
  List<_RulesSection>? _sections;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _sections = null;
      _failed = false;
    });
    try {
      final raw = await rootBundle.loadString('assets/rules.json');
      final data = jsonDecode(raw) as List;
      final sections = <_RulesSection>[];
      for (final entry in data) {
        final map = entry as Map;
        final title = map['title'] as String;
        final paragraphs = (map['paragraphs'] as List)
            .map((p) => p.toString())
            .toList();
        sections.add(_RulesSection(title: title, paragraphs: paragraphs));
      }
      if (!mounted) return;
      setState(() => _sections = sections);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  void _jumpTo(int index) {
    final key = _itemKeys[index];
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: _appBar(context, 'قوانین'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.surface, colors.background],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(painter: _StarfieldPainter()),
              ),
            ),
            SafeArea(
              child: _failed
                  ? _RulesErrorView(onRetry: _load)
                  : _sections == null
                      ? const _RulesLoadingView()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final sections = _sections!;
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Column(
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: colors.secondary,
              ),
              const SizedBox(height: 10),
              Text(
                'قوانین و مقررات',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onBackground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'تیناتریپ | tinatrip.com',
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.muted,
                ),
              ),
            ],
          ),
        ),
        _RulesToc(
          titles: [for (final s in sections) s.title],
          onTap: _jumpTo,
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              return KeyedSubtree(
                key: _itemKeys[index],
                child: _RulesSectionCard(
                  index: index,
                  section: sections[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RulesToc extends StatelessWidget {
  const _RulesToc({required this.titles, required this.onTap});

  final List<String> titles;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: titles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => onTap(index),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: colors.line),
              ),
              child: Text(
                titles[index],
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.onBackground,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RulesSectionCard extends StatelessWidget {
  const _RulesSectionCard({
    required this.index,
    required this.section,
  });

  final int index;
  final _RulesSection section;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accentList = [colors.primary, colors.secondary, colors.accent, colors.error];
    final accent = accentList[index % accentList.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [accent.withValues(alpha: 0.15), colors.surface],
              ),
              border: Border(bottom: BorderSide(color: colors.line)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                    Icons.menu_book_outlined,
                    color: accent,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onBackground,
                      height: 1.4,
                    ),
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < section.paragraphs.length; i++) ...[
                  Text(
                    section.paragraphs[i],
                    textAlign: TextAlign.justify,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackground,
                      height: 1.85,
                    ),
                  ),
                  if (i < section.paragraphs.length - 1)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesLoadingView extends StatelessWidget {
  const _RulesLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 18),
          Text('در حال بارگذاری قوانین…'),
        ],
      ),
    );
  }
}

class _RulesErrorView extends StatelessWidget {
  const _RulesErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 52, color: colors.error),
            const SizedBox(height: 20),
            Text(
              'بارگذاری قوانین ممکن نشد',
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لطفاً دوباره تلاش کنید.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.muted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _PrimaryButton(
              label: 'تلاش دوباره',
              icon: Icons.refresh,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _WebLoadingView extends StatelessWidget {
  const _WebLoadingView();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      color: colors.background,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          Text(
            'درحال برقراری ارتباط…',
            style: context.textTheme.titleMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'لطفاً کمی صبر کنید',
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.muted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebErrorView extends StatelessWidget {
  const _WebErrorView({required this.onRetry, required this.onBrowser});

  final VoidCallback onRetry;
  final VoidCallback onBrowser;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      color: colors.background,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 52, color: colors.error),
          const SizedBox(height: 20),
          Text(
            'برقراری ارتباط ممکن نشد',
            style: context.textTheme.headlineSmall?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PrimaryButton(
                label: 'تلاش دوباره',
                icon: Icons.refresh,
                onTap: onRetry,
              ),
              const SizedBox(width: 12),
              _GhostButton(
                label: 'در مرورگر',
                icon: Icons.open_in_new,
                onTap: onBrowser,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
