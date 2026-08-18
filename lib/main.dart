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
        colorScheme: const ColorScheme.dark(
          primary: kTurquoise,
          secondary: kGold,
          surface: kNightRaised,
          onSurface: kMist,
        ),
        scaffoldBackgroundColor: kNight,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: kTurquoise,
        ),
      ),
      home: const SplashHost(),
    );
  }
}

// ---- Design tokens ---------------------------------------------------------

const kNight = Color(0xFF0B1B27);
const kNightRaised = Color(0xFF123041);
const kLine = Color(0xFF1F4050);
const kTurquoise = Color(0xFF4BC2ED);
const kGold = Color(0xFFE9AF4F);
const kMist = Color(0xFFEAF2F4);
const kMuted = Color(0xFF8AA5AF);
const kVermilion = Color(0xFFE0684E);
const kPeriwinkle = Color(0xFF97A6DD);

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
          duration: const Duration(milliseconds: 3600),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && !_reducedMotion) {
            _beginExit();
          }
        });
    _controller.forward();
    _homeTimer = Timer(const Duration(milliseconds: 950), () {
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
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (mounted && !_gone) _beginExit();
      });
    }
  }

  void _beginExit() {
    if (_exiting) return;
    _exiting = true;
    _startSignal.value = true;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 620), () {
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
                duration: const Duration(milliseconds: 520),
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
    final emblemFade = _interval(0.04, 0.22);
    final emblemScale = _interval(0.10, 0.30, curve: Curves.easeOutBack);
    final emblemTurn = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.06, 0.86, curve: Curves.linear),
    );
    final word = _interval(0.22, 0.40);
    final tag = _interval(0.32, 0.48);
    final arc = _interval(0.36, 0.68);
    final card = _interval(0.56, 0.78);
    final chips = _interval(0.66, 0.84);
    final foot = _interval(0.74, 0.90);

    return Material(
      color: kNight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF081420), kNight, Color(0xFF10303F)],
              ),
            ),
            child: CustomPaint(painter: _StarsPainter()),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(flex: 3),
                      _SplashEmblem(
                        fade: emblemFade,
                        scale: emblemScale,
                        turn: emblemTurn,
                      ),
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: word,
                        child: const Text(
                          'تیناتریپ',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: kGold,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: tag,
                        child: const Text(
                          'مرجع بهترین تورها، هتل‌ها و پروازهای داخلی و خارجی',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: kMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 96,
                        child: FadeTransition(
                          opacity: arc,
                          child: CustomPaint(
                            painter: FlightArcPainter(
                              progress: CurvedAnimation(
                                parent: controller,
                                curve: const Interval(
                                  0.36,
                                  0.68,
                                  curve: Curves.easeInOut,
                                ),
                              ).value,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FadeTransition(
                        opacity: card,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.25),
                            end: Offset.zero,
                          ).animate(card),
                          child: const _SplashSearchCard(),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 14),
                      FadeTransition(
                        opacity: foot,
                        child: const Text(
                          'تینا تریپ، پلی به سوی دنیا',
                          style: TextStyle(fontSize: 12, color: kMuted),
                        ),
                      ),
                      const SizedBox(height: 14),
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

class _SplashEmblem extends StatelessWidget {
  const _SplashEmblem({
    required this.fade,
    required this.scale,
    required this.turn,
  });

  final Animation<double> fade;
  final Animation<double> scale;
  final Animation<double> turn;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: AnimatedBuilder(
          animation: turn,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Transform.rotate(
                  angle: turn.value * math.pi * 2,
                  child: CustomPaint(
                    size: const Size(150, 150),
                    painter: _EightPointStarPainter(
                      color: kGold.withValues(alpha: 0.9),
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kGold.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                  ),
                ),
                const _LogoBadge(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset('assets/logo.jpg', fit: BoxFit.contain),
      ),
    );
  }
}

class _SplashSearchCard extends StatelessWidget {
  const _SplashSearchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kNightRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kLine),
        boxShadow: [
          BoxShadow(
            color: kTurquoise.withValues(alpha: 0.14),
            blurRadius: 34,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),
          Icon(Icons.flight_takeoff, color: kTurquoise, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'کجا می‌خواهید بروید؟',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kMist,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'شهر، فرودگاه یا نام هتل',
                  style: TextStyle(fontSize: 12, color: kMuted),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: kTurquoise,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: kNight, size: 22),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: kNightRaised,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: kLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.place, size: 14, color: kTurquoise),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: kMist),
          ),
        ],
      ),
    );
  }
}

// ---- Persian girih star motif ----------------------------------------------

class _EightPointStarPainter extends CustomPainter {
  const _EightPointStarPainter({required this.color, this.strokeWidth = 1.6});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = math.min(size.width, size.height) / 2 - strokeWidth;
    final inner = outer * 0.42;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi / 8 - math.pi / 2;
      final r = i.isEven ? outer : inner;
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
  }

  @override
  bool shouldRepaint(covariant _EightPointStarPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

// ---- Home ------------------------------------------------------------------

class _ServiceItem {
  final String label;
  final IconData icon;
  final String? url;
  final Color accent;
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
      icon: Icons.flight_takeoff,
      url: 'https://tinatrip.com/flight/',
      accent: kTurquoise,
    ),
    _ServiceItem(
      label: 'هتل',
      icon: Icons.hotel,
      url: 'https://tinatrip.com/hotels/',
      accent: kGold,
    ),
    _ServiceItem(
      label: 'تور',
      icon: Icons.explore,
      url: 'https://tinatrip.com/tours/',
      accent: kVermilion,
    ),
    _ServiceItem(
      label: 'گشت',
      icon: Icons.edit_calendar,
      accent: kPeriwinkle,
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
      label: 'پرداخت عوارض خروج از کشور',
      icon: Icons.payments,
      url: 'https://sadadpsp.ir/tollpayment',
    ),
    _TravelTool(
      label: 'دریافت ارز مسافرتی',
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
      duration: const Duration(milliseconds: 2800),
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
          opacity: _interval(0.72, 0.92).value,
          child: FloatingActionButton.extended(
            heroTag: 'contactFab',
            backgroundColor: kTurquoise,
            foregroundColor: kNight,
            elevation: 6,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ContactPage())),
            icon: const Icon(Icons.support_agent, size: 20),
            label: const Text(
              'تماس با ما',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _StarfieldBackground()),
          const Positioned.fill(child: _HomeWatermark()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 96),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(0, constraints.maxHeight - 96),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _RevealText(
                          animation: _interval(0.0, 0.20),
                          child: Column(
                            children: [
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: _MenuButton(
                                  onTap: () => _scaffoldKey.currentState
                                      ?.openDrawer(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'تیناتریپ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: kTurquoise,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'مرجع بهترین تورها، هتل‌ها و پروازهای داخلی و خارجی',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: kMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        _GatesColumn(
                          visible: _interval(0.22, 0.52),
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
                        const SizedBox(height: 26),
                        _ToolsSection(
                          visible: _interval(0.56, 0.76),
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

class _StarfieldBackground extends StatelessWidget {
  const _StarfieldBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF081420), kNight, Color(0xFF10303F)],
        ),
      ),
      child: const CustomPaint(painter: _StarsPainter()),
    );
  }
}

class _HomeWatermark extends StatelessWidget {
  const _HomeWatermark();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: CustomPaint(
          size: const Size(340, 340),
          painter: const _EightPointStarPainter(
            color: Color(0x0DE9AF4F),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  const _StarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.26);
    for (var i = 0; i < 46; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.62;
      final r = 0.5 + rng.nextDouble() * 0.9;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GatesColumn extends StatelessWidget {
  const _GatesColumn({
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
          _GateBar(
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

class _GateBar extends StatelessWidget {
  const _GateBar({
    required this.item,
    required this.reveal,
    required this.onTap,
  });

  final _ServiceItem item;
  final Animation<double> reveal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.16),
        end: Offset.zero,
      ).animate(reveal),
      child: Material(
        color: kNightRaised,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 78,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kLine),
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  item.accent.withValues(alpha: 0.16),
                  kNightRaised,
                ],
              ),
            ),
            child: Row(
              children: [
                Container(width: 5, color: item.accent),
                const SizedBox(width: 16),
                _GateIcon(item: item),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kMist,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(
                    Icons.chevron_left,
                    color: item.accent.withValues(alpha: 0.9),
                    size: 24,
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

class _GateIcon extends StatelessWidget {
  const _GateIcon({required this.item});

  final _ServiceItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(52, 52),
            painter: _EightPointStarPainter(
              color: item.accent.withValues(alpha: 0.55),
              strokeWidth: 1.3,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: item.accent.withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
            child: Icon(item.icon, color: item.accent, size: 20),
          ),
        ],
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
              Container(width: 24, height: 1.2, color: kLine),
              const SizedBox(width: 10),
              const Text(
                'ابزارهای سفر',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: kMuted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 1.2, color: kLine)),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            FadeTransition(
              opacity: CurvedAnimation(
                parent: visible,
                curve: Interval(
                  i * 0.06,
                  i * 0.06 + 0.7,
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
    return Material(
      color: kNight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kLine),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: kTurquoise.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: kTurquoise.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(tool.icon, color: kMuted, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tool.label,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: kMist,
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
          begin: const Offset(0, 0.18),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class FlightArcPainter extends CustomPainter {
  const FlightArcPainter({required this.progress});

  final double progress;

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
      ..color = kLine.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final glow = Paint()
      ..color = kGold.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;

    _drawDashed(canvas, visible, base, dashLength: 3, gap: 11);

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
    p.moveTo(-11, -4);
    p.lineTo(11, -4);
    p.lineTo(13, 0);
    p.lineTo(11, 4);
    p.lineTo(-11, 4);
    p.lineTo(-13, 0);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant FlightArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kNightRaised,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kLine),
          ),
          child: const Icon(Icons.menu, color: kMist, size: 22),
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
    return Drawer(
      backgroundColor: kNightRaised,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 26),
            const Center(
              child: Column(
                children: [
                  _EightPointStarGlyph(),
                  SizedBox(height: 10),
                  Text(
                    'تیناتریپ',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: kGold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'منوی اصلی',
                    style: TextStyle(fontSize: 12, color: kMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Divider(color: kLine, height: 1, thickness: 1),
            const SizedBox(height: 8),
            _DrawerTile(
              icon: Icons.article_outlined,
              color: kTurquoise,
              label: 'وبلاگ',
              onTap: onBlog,
            ),
            _DrawerTile(
              icon: Icons.description_outlined,
              color: kGold,
              label: 'قوانین',
              onTap: onRules,
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Text(
                'تینا تریپ، پلی به سوی دنیا',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: kMuted),
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
    return Material(
      color: Colors.transparent,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
        title: Text(
          label,
          style: const TextStyle(color: kMist, fontSize: 15),
        ),
        trailing: const Icon(Icons.chevron_left, color: kMuted, size: 20),
        onTap: onTap,
      ),
    );
  }
}

class _EightPointStarGlyph extends StatelessWidget {
  const _EightPointStarGlyph();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(34, 34),
      painter: const _EightPointStarPainter(
        color: kTurquoise,
        strokeWidth: 1.6,
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
    return Material(
      color: kTurquoise,
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
                color: kTurquoise.withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: kNight, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: kNight,
                  fontSize: 14,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kLine, width: 1.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: kGold, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: kMist,
                  fontSize: 14,
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

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('درخواست شما ثبت شد؛ کارشناسان ما به‌زودی با شما تماس می‌گیرند.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: kNightRaised,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: kVermilion,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, 'گشت'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF10303F), kNight],
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
                  const Text(
                    'برای گشت، شهر مقصد و شماره تماس‌تان را بفرستید؛ کارشناسان ما با شما تماس می‌گیرند.',
                    style: TextStyle(color: kMuted, fontSize: 14, height: 1.7),
                  ),
                  const SizedBox(height: 24),
                  const _FieldLabel('شهر مقصد'),
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
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _FieldLabel('شماره تماس'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, letterSpacing: 1),
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
                    ),
                  ),
                  const SizedBox(height: 32),
                  _sending
                      ? const Center(
                          child: CircularProgressIndicator(color: kTurquoise),
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
    return Text(
      text,
      style: const TextStyle(
        color: kMist,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: kMuted),
    filled: true,
    fillColor: kNight,
    prefixIcon: Icon(icon, color: kTurquoise, size: 20),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kLine),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kTurquoise, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kVermilion),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kVermilion, width: 1.6),
    ),
    errorStyle: const TextStyle(color: kVermilion, fontSize: 12.5),
  );
}

// ---- Contact ---------------------------------------------------------------

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const _phones = ['02191690935', '05191690935', '05135147359'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, 'تماس با ما'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF10303F), kNight],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kTurquoise.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kTurquoise.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Text(
                    'پشتیبانی تینا تریپ آماده دریافت انتقادات، پیشنهادات و نظرات شما می‌باشد.',
                    style: TextStyle(color: kMist, fontSize: 14.5, height: 1.8),
                  ),
                ),
                const SizedBox(height: 24),
                for (final phone in _phones)
                  _ContactRow(
                    icon: Icons.phone_in_talk,
                    color: kTurquoise,
                    label: 'شماره ثابت',
                    value: phone,
                    onTap: () => dialNumber(phone),
                  ),
                _ContactRow(
                  icon: Icons.phone_iphone,
                  color: kTurquoise,
                  label: 'شماره همراه',
                  value: '09909675218',
                  onTap: () => dialNumber('09909675218'),
                ),
                _ContactRow(
                  icon: Icons.camera_alt,
                  color: kVermilion,
                  label: 'اینستاگرام',
                  value: 'tinasafar_com',
                  onTap: () =>
                      openExternalUrl('https://instagram.com/tinasafar_com'),
                ),
                _ContactRow(
                  icon: Icons.mail_outline,
                  color: kGold,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: kNightRaised,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kLine),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(color: kMuted, fontSize: 12.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          color: kMist,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_left, color: kMuted, size: 22),
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
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
    ),
    backgroundColor: kNightRaised,
    foregroundColor: kMist,
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
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(kNight)
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
    return Scaffold(
      backgroundColor: kNight,
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

  static const _accents = [kTurquoise, kGold, kPeriwinkle, kVermilion];

  static const _icons = {
    'general': Icons.gavel_outlined,
    'privacy': Icons.privacy_tip_outlined,
    'flight-tickets': Icons.flight_takeoff,
    'charter-flights': Icons.flight_land,
    'local-flights': Icons.local_airport,
    'international-flights': Icons.public,
    'international-airlines': Icons.airlines,
    'pet': Icons.pets,
    'visa': Icons.contact_page_outlined,
    'local-hotels': Icons.hotel_outlined,
    'international-hotels': Icons.apartment,
    'notes': Icons.lightbulb_outline,
    'tour': Icons.explore_outlined,
    'passenger': Icons.assignment_ind_outlined,
  };

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
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, 'قوانین'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF10303F), kNight],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _StarsPainter()),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _RulesHero(),
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
                  accent: _accents[index % _accents.length],
                  icon: _rulesIcon(index),
                  section: sections[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _rulesIcon(int index) {
    final id = _rulesIds[index];
    return _icons[id] ?? Icons.menu_book_outlined;
  }

  static const _rulesIds = [
    'general',
    'privacy',
    'flight-tickets',
    'charter-flights',
    'local-flights',
    'international-flights',
    'international-airlines',
    'pet',
    'visa',
    'local-hotels',
    'international-hotels',
    'notes',
    'tour',
    'passenger',
  ];
}

class _RulesHero extends StatelessWidget {
  const _RulesHero();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CustomPaint(
              painter: _EightPointStarPainter(
                color: kGold,
                strokeWidth: 1.5,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'قوانین و مقررات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kMist,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'تیناتریپ | tinatrip.com',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: kMuted),
          ),
        ],
      ),
    );
  }
}

class _RulesToc extends StatelessWidget {
  const _RulesToc({required this.titles, required this.onTap});

  final List<String> titles;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
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
                color: kNightRaised,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: kLine),
              ),
              child: Text(
                titles[index],
                style: const TextStyle(fontSize: 12, color: kMist),
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
    required this.accent,
    required this.icon,
    required this.section,
  });

  final int index;
  final Color accent;
  final IconData icon;
  final _RulesSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: kNightRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kLine),
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
                colors: [accent.withValues(alpha: 0.20), kNightRaised],
              ),
              border: Border(bottom: BorderSide(color: kLine)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: kMist,
                      height: 1.4,
                    ),
                  ),
                ),
                Container(
                  width: 5,
                  height: 5,
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
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: kMist,
                      height: 1.85,
                      fontWeight: FontWeight.w400,
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
            child: CircularProgressIndicator(color: kTurquoise, strokeWidth: 3),
          ),
          SizedBox(height: 18),
          Text(
            'در حال بارگذاری قوانین…',
            style: TextStyle(color: kMuted, fontSize: 14),
          ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 52, color: kVermilion),
            const SizedBox(height: 20),
            const Text(
              'بارگذاری قوانین ممکن نشد',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kMist,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لطفاً دوباره تلاش کنید.',
              style: TextStyle(color: kMuted, fontSize: 13.5),
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
    return Container(
      color: kNight,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(color: kTurquoise, strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          const Text(
            'درحال برقراری ارتباط…',
            style: TextStyle(
              color: kMist,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'لطفاً کمی صبر کنید',
            style: TextStyle(color: kMuted, fontSize: 13),
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
    return Container(
      color: kNight,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 52, color: kVermilion),
          const SizedBox(height: 20),
          const Text(
            'برقراری ارتباط ممکن نشد',
            style: TextStyle(
              color: kMist,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.',
            style: TextStyle(color: kMuted, fontSize: 13.5),
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
