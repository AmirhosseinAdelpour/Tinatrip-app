import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../theme/app_build_context.dart';
import '../theme/app_colors.dart';
import '../models/service_item.dart';
import '../widgets/app_background.dart';
import '../widgets/reveal_widget.dart';
import '../widgets/section_divider.dart';
import '../widgets/home_drawer.dart';
import '../platform_actions.dart';
import 'webview_screen.dart';
import 'reserve_form_screen.dart';
import 'contact_screen.dart';
import 'rules_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _services = [
    ServiceItem(
      label: 'پرواز',
      icon: Icons.flight,
      url: 'https://tinatrip.com/flight/',
      accent: ServiceAccent.primary,
    ),
    ServiceItem(
      label: 'هتل',
      icon: Icons.hotel,
      url: 'https://tinatrip.com/hotels/',
      accent: ServiceAccent.secondary,
    ),
    ServiceItem(
      label: 'تور',
      icon: Icons.explore,
      url: 'https://tinatrip.com/tours/',
      accent: ServiceAccent.accent,
    ),
    ServiceItem(
      label: 'گشت',
      icon: Icons.edit_calendar,
      accent: ServiceAccent.error,
      opensForm: true,
    ),
  ];

  static const _tools = [
    TravelTool(
      label: 'اطلاعات پرواز',
      icon: Icons.connecting_airports,
      url: 'https://fids.airport.ir/',
    ),
    TravelTool(
      label: 'استعلام ممنوع الخروجی',
      icon: Icons.policy,
      url: 'https://my.ssaa.ir/portal/executive/inquery-exitban',
    ),
    TravelTool(
      label: 'پرداخت عوارض خروج',
      icon: Icons.payments,
      url: 'https://sadadpsp.ir/tollpayment',
    ),
    TravelTool(
      label: 'ارز مسافرتی',
      icon: Icons.currency_exchange,
      url: 'https://travel.ice.ir/',
    ),
    TravelTool(
      label: 'بیمه مسافرتی',
      icon: Icons.health_and_safety,
      url: 'https://samandirect.ir/page/Load?Name=TravelInfo',
    ),
  ];

  late final AnimationController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
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
          builder: (_) => WebViewScreen(title: label, url: url),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      key: _scaffoldKey,
      drawer: HomeDrawer(
        onBlog: () {
          Navigator.of(context).pop();
          _openWeb('وبلاگ', 'https://tinatrip.com/blog/');
        },
        onRules: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RulesScreen()),
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
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ContactScreen()),
            ),
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
          const Positioned.fill(child: AppBackground()),
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
                        RevealWidget(
                          animation: _interval(0.0, 0.18),
                          child: Column(
                            children: [
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: _MenuButton(
                                  onTap: () =>
                                      _scaffoldKey.currentState?.openDrawer(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'تیناتریپ',
                                textAlign: TextAlign.center,
                                style: context.textTheme.headlineMedium?.copyWith(
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
                                  color: colors.primary.withAlpha(25),
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
                                  builder: (_) => const ReserveFormScreen(),
                                ),
                              );
                            } else {
                              _openWeb(s.label, s.url!);
                            }
                          },
                        ),
                        const SizedBox(height: 28),
                        RevealWidget(
                          animation: _interval(0.54, 0.74),
                          child: Column(
                            children: [
                              SectionDivider(label: 'ابزارهای سفر'),
                              const SizedBox(height: 14),
                              _ToolsGrid(
                                tools: _tools,
                                onTap: (t) => _openWeb(t.label, t.url),
                              ),
                            ],
                          ),
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

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({
    required this.visible,
    required this.services,
    required this.onTap,
  });

  final Animation<double> visible;
  final List<ServiceItem> services;
  final ValueChanged<ServiceItem> onTap;

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

  final ServiceItem item;
  final Animation<double> reveal;
  final VoidCallback onTap;

  Color _accentFor(AppColors colors) => switch (item.accent) {
        ServiceAccent.primary => colors.primary,
        ServiceAccent.secondary => colors.secondary,
        ServiceAccent.accent => colors.accent,
        ServiceAccent.error => colors.error,
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
                    accent.withAlpha(45),
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
                      color: accent.withAlpha(35),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: accent.withAlpha(102),
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
                      color: accent.withAlpha(204),
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

class _ToolsGrid extends StatelessWidget {
  const _ToolsGrid({
    required this.tools,
    required this.onTap,
  });

  final List<TravelTool> tools;
  final ValueChanged<TravelTool> onTap;

  @override
  Widget build(BuildContext context) {
    final rows = <List<TravelTool>>[
      for (var i = 0; i < tools.length; i += 2)
        tools.sublist(i, math.min(i + 2, tools.length)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          Row(
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
          if (i < rows.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tool, required this.onTap});

  final TravelTool tool;
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
                  color: colors.accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: colors.accent.withAlpha(64),
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
